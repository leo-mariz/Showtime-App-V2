import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para deletar slot de horário
/// 
/// Remove um slot de horário específico de um dia.
/// Se for o último slot, o comportamento padrão é deixar o dia vazio
/// (não deleta o documento).
class DeleteTimeSlotUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  DeleteTimeSlotUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    SlotOperationDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      final slot = dto.slot;

      if (slot.slotId == null || slot.slotId!.isEmpty) {
        return const Left(ValidationFailure('ID do slot é obrigatório'));
      }

      // Buscar disponibilidade do dia
      final getDayResult = await getByDate(
        artistId,
        GetAvailabilityByDateDto(date: dto.date, forceRemote: true),
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) async {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          if (dayEntity.availabilities.isEmpty) {
            return const Left(ValidationFailure('Dia sem disponibilidades'));
          }

          // Procurar e remover slot da primeira entry
          final firstEntry = dayEntity.availabilities.first;
          final slotIndex = firstEntry.slots.indexWhere(
            (s) => s.slotId == slot.slotId,
          );

          if (slotIndex == -1) {
            return const Left(NotFoundFailure('Slot não encontrado'));
          }

          // Criar lista atualizada de slots (removendo o slot)
          final updatedSlots = List.of(firstEntry.slots)..removeAt(slotIndex);

          // Se não restaram slots e deleteIfEmpty = true, deletar o dia
          if (updatedSlots.isEmpty && dto.deleteIfEmpty) {
            final deleteResult = await repository.deleteAvailability(
              artistId: artistId,
              dayId: dayEntity.documentId,
            );
            
            return deleteResult.fold(
              (failure) => Left(failure),
              (_) => Right(dayEntity), // Retorna o dia antes de ser deletado
            );
          }

          // Atualizar entry com slots restantes
          final updatedEntry = firstEntry.copyWith(
            slots: updatedSlots,
          );

          // Criar lista atualizada de availabilities
          final updatedAvailabilities = [
            updatedEntry,
            ...dayEntity.availabilities.skip(1),
          ];

          final updatedDay = dayEntity.copyWith(
            availabilities: updatedAvailabilities,
            updatedAt: DateTime.now(),
          );

          // Atualizar no repositório
          return repository.updateAvailability(
            artistId: artistId,
            day: updatedDay,
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
