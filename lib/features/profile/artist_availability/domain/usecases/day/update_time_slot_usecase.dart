import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar slot de horário
/// 
/// Atualiza um slot de horário existente.
/// **Não realiza validações** - apenas atualiza o slot.
class UpdateTimeSlotUseCase {
  final UpdateAvailabilityDayUseCase updateAvailabilityDay;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateTimeSlotUseCase({
    required this.updateAvailabilityDay,
    required this.getByDate,
  });

  /// Atualiza slot de horário
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `date`: Data do dia
  /// - `slotId`: ID do slot a ser atualizado
  /// - `slotDto`: DTO com os campos a serem atualizados
  /// 
  /// **Retorna:**
  /// - `Right(AvailabilityDayEntity)` em caso de sucesso
  /// - `Left(Failure)` em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    DateTime date,
    String slotId,
    TimeSlot timeSlot,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      if (slotId.isEmpty) {
        return const Left(ValidationFailure('ID do slot é obrigatório'));
      }

      // Validar que pelo menos um campo foi fornecido
      if (timeSlot.startTime.isEmpty && 
          timeSlot.endTime.isEmpty && 
          timeSlot.valorHora == 0) {
        return const Left(
          ValidationFailure('Pelo menos um campo deve ser atualizado'),
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Buscar disponibilidade do dia
      // ════════════════════════════════════════════════════════════════
      final getDayResult = await getByDate(
        artistId,
        date,
        forceRemote: false,
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) async {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          // ════════════════════════════════════════════════════════════
          // 2. Encontrar o slot a ser atualizado
          // ════════════════════════════════════════════════════════════
          final slotIndex = dayEntity.slots.indexWhere(
            (s) => s.slotId == slotId,
          );

          if (slotIndex == -1) {
            return const Left(NotFoundFailure('Slot não encontrado'));
          }

          final oldSlot = dayEntity.slots[slotIndex];

          // ════════════════════════════════════════════════════════════
          // 3. Atualizar o slot
          // ════════════════════════════════════════════════════════════
          final updatedSlot = oldSlot.copyWith(
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime,
            valorHora: timeSlot.valorHora,
          );

          // ════════════════════════════════════════════════════════════
          // 4. Atualizar lista de slots
          // ════════════════════════════════════════════════════════════
          final updatedSlots = List.of(dayEntity.slots);
          updatedSlots[slotIndex] = updatedSlot;

          final updatedDay = dayEntity.copyWith(
            slots: updatedSlots,
            updatedAt: DateTime.now(),
          );

          // ════════════════════════════════════════════════════════════
          // 5. Salvar no repositório
          // ════════════════════════════════════════════════════════════
          final updateResult = await updateAvailabilityDay.call(
            artistId,
            updatedDay,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (savedDay) => Right(savedDay),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
