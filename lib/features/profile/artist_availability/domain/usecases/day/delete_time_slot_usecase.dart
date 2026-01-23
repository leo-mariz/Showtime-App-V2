import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para deletar slot de horário
/// 
/// Remove um slot de horário específico de um dia.
/// Se for o último slot, o comportamento padrão é deixar o dia vazio
/// (não deleta o documento).
class DeleteTimeSlotUseCase {
  final GetAvailabilityByDateUseCase getByDate;
  final UpdateAvailabilityDayUseCase updateAvailabilityDay;

  DeleteTimeSlotUseCase({
    required this.updateAvailabilityDay,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    DateTime date,
    String slotId,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // Buscar disponibilidade do dia
      final getDayResult = await getByDate(
        artistId,
        date,
        forceRemote: true,
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) async {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          bool isActive = dayEntity.isActive;

          // Procurar e remover slot
          final slotIndex = dayEntity.slots.indexWhere(
            (s) => s.slotId == slotId,
          );

          if (slotIndex == -1) {
            return const Left(NotFoundFailure('Slot não encontrado'));
          }

          // Criar lista atualizada de slots (removendo o slot)
          final updatedSlots = List.of(dayEntity.slots)..removeAt(slotIndex);

          // Se não restaram slots e deleteIfEmpty = true, deletar o dia
          if (updatedSlots.isEmpty) {
            final deleteResult = await updateAvailabilityDay.call(
              artistId,
              dayEntity,
            );
            
            return deleteResult.fold(
              (failure) => Left(failure),
              (_) => Right(dayEntity), // Retorna o dia antes de ser deletado
            );
          }

          if (updatedSlots.isEmpty) {
            isActive = false;
          }

          // Atualizar dia com slots restantes
          final updatedDay = dayEntity.copyWith(
            slots: updatedSlots,
            updatedAt: DateTime.now(),
            isActive: isActive,
          );

          // Atualizar no repositório
          return  updateAvailabilityDay.call(
            artistId,
            updatedDay,
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
