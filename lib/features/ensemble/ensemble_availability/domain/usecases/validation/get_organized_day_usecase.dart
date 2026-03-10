import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:app/core/domain/availability/time_slot_entity.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/availability/domain/dtos/check_overlap_on_day_dto.dart';
import 'package:app/features/availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/availability/domain/entities/check_overlap_on_day_result.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para checagem de overlaps em um único dia
/// 
/// Verifica overlaps de horários, diferenças de endereço e raio
/// para um dia específico.
class GetOrganizedEnsembleDayAfterVerificationUseCase {
  final GetEnsembleAvailabilityByDateUseCase getEnsembleAvailabilityByDateUseCase;

  GetOrganizedEnsembleDayAfterVerificationUseCase({
    required this.getEnsembleAvailabilityByDateUseCase,
  });

  /// Verifica overlaps e diferenças em um dia
  /// 
  /// **Parâmetros:**
  /// - `ensembleId`: ID do conjunto
  /// - `date`: Data do dia a verificar
  /// - `dto`: DTO com os dados do slot novo e informações de endereço/raio
  /// 
  /// **Retorna:**
  /// - `Right(CheckOverlapOnDayResult)` com informações de overlaps/diferenças
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, OrganizedDayAfterVerificationResult>> call(
    String ensembleId,
    DateTime date,
    CheckOverlapOnDayDto dto,
    bool isClose,
  ) async {
    try {
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ID do conjunto é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Obter disponibilidade do dia
      // ════════════════════════════════════════════════════════════════
      final getDayResult = await getEnsembleAvailabilityByDateUseCase(
        ensembleId,
        date,
        forceRemote: false,
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) {
          if (dayEntity == null) {
            // Dia não existe, não há overlaps nem diferenças
            return Right(OrganizedDayAfterVerificationResult.dayNotFound());
          }

          // ════════════════════════════════════════════════════════════
          // 2. Verificar diferenças de endereço e raio
          // ════════════════════════════════════════════════════════════
          final isAddressDifferent = dto.endereco != null
              ? _isAddressDifferent(
                  newAddress: dto.endereco!,
                  oldAddress: dayEntity.endereco!,
                )
              : false;

          final isRadiusDifferent = dto.raioAtuacao != null
              ? dto.raioAtuacao != dayEntity.raioAtuacao
              : false;

          // ════════════════════════════════════════════════════════════
          // 3. Processar slots existentes
          // ════════════════════════════════════════════════════════════
          bool hasOverlap = false;
          List<TimeSlot> newSlotsList = [];

          // Determinar horários do novo slot
          // Se startTime/endTime são null, significa "Todos os horários" (00:00-23:59)
          final String effectiveStartTime;
          final String effectiveEndTime;
          
          if (dto.startTime != null && dto.endTime != null) {
            effectiveStartTime = dto.startTime!;
            effectiveEndTime = dto.endTime!;
          } else {
            // "Todos os horários" = 00:00 até 23:59
            effectiveStartTime = '00:00';
            effectiveEndTime = '23:59';
          }

          final newStartTime = _parseTimeString(effectiveStartTime);
          final newEndTime = _parseTimeString(effectiveEndTime);

          // Processar cada slot existente
          for (var i = 0; i < dayEntity.slots!.length; i++) {
            final slot = dayEntity.slots![i];
            
            // ════════════════════════════════════════════════════════════
            // Se estamos atualizando um slot, ignorar ele mesmo na comparação
            // ════════════════════════════════════════════════════════════
            if (dto.slotId != null && slot.slotId == dto.slotId) {
              continue; // Pular este slot, não comparar com ele mesmo
            }
            
            final slotStartTime = _parseTimeString(slot.startTime);
            final slotEndTime = _parseTimeString(slot.endTime);


            final overlapType = AvailabilityHelpers.validateTimeSlotOverlap(
              newStart: newStartTime,
              newEnd: newEndTime,
              existingStart: slotStartTime,
              existingEnd: slotEndTime,
            );

            if (overlapType == null) {
              // Não há overlap, adiciona o slot existente
              newSlotsList.add(slot);
            } else {
              // Há overlap, gera novos slots
              hasOverlap = true;
              if (slot.status == TimeSlotStatusEnum.available) {
                final generatedSlots = AvailabilityHelpers.generateNewSlots(
                  existingSlot: slot,
                  newStart: newStartTime,
                  newEnd: newEndTime,
                  overlapType: overlapType,
                );
                for (var j = 0; j < generatedSlots.length; j++) {
                }
                newSlotsList.addAll(generatedSlots);
              } else if (slot.status == TimeSlotStatusEnum.booked) {
                return Right(OrganizedDayAfterVerificationResult.withBookedSlot(dayEntity));
              }
            }
          }

          // ════════════════════════════════════════════════════════
          // 4. Adicionar o slot novo ou atualizado (apenas se não for close e valorHora foi fornecido)
          // ════════════════════════════════════════════════════════
          if (dto.valorHora != null && !isClose) {
            // Se estamos atualizando um slot existente, usar o mesmo slotId
            // Caso contrário, criar um novo slot com novo ID
            final slotId = dto.slotId ?? const Uuid().v4();
            
            
            final newSlot = TimeSlot(
              slotId: slotId,
              startTime: effectiveStartTime,
              endTime: effectiveEndTime,
              status: TimeSlotStatusEnum.available,
              valorHora: dto.valorHora,
              sourcePatternId: dto.patternId, // Pode ser null para slots manuais
            );
            newSlotsList.add(newSlot);
          } else {
          }
          
          // ════════════════════════════════════════════════════════════
          // 5. Classificar o resultado
          // ════════════════════════════════════════════════════════════
          
          if (hasOverlap || isAddressDifferent || isRadiusDifferent) {
            final overlapInfo = DayOverlapInfo(
              date: date,
              hasOverlap: hasOverlap,
              isAddressDifferent: isAddressDifferent,
              isRadiusDifferent: isRadiusDifferent,
              newAddress: isAddressDifferent ? dto.endereco : null,
              oldAddress: isAddressDifferent ? dayEntity.endereco : null,
              newRadius: isRadiusDifferent ? dto.raioAtuacao : null,
              oldRadius: isRadiusDifferent ? dayEntity.raioAtuacao : null,
              newTimeSlots: newSlotsList,
              oldTimeSlots: dayEntity.slots,
            );

            return Right(OrganizedDayAfterVerificationResult.withChanges(overlapInfo));
          } else {
            // Criar entidade atualizada com novos slots
            final updatedDay = dayEntity.copyWith(
              slots: newSlotsList,
            );

            return Right(OrganizedDayAfterVerificationResult.withoutChanges(updatedDay));
          }
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Verifica se o endereço é diferente
  bool _isAddressDifferent({
    required AddressInfoEntity newAddress,
    required AddressInfoEntity oldAddress,
  }) {
    // Comparar por UID se disponível, senão comparar campos principais
    if (newAddress.uid != null && oldAddress.uid != null) {
      return newAddress.uid != oldAddress.uid;
    }

    // Comparar por campos principais
    return newAddress.zipCode != oldAddress.zipCode ||
        newAddress.street != oldAddress.street ||
        newAddress.number != oldAddress.number ||
        newAddress.latitude != oldAddress.latitude ||
        newAddress.longitude != oldAddress.longitude;
  }

  /// Converte string "HH:mm" para TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
