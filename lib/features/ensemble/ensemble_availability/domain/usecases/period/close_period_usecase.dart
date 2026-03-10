import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para fechar um período de disponibilidade
/// 
/// Recebe um OpenPeriodDto e atualiza cada dia usando as informações
/// de DayOverlapInfo. Dias com slots reservados são ignorados.
class CloseEnsemblePeriodUseCase {
  final UpdateEnsembleAvailabilityDayUseCase updateAvailabilityDayUseCase;

  CloseEnsemblePeriodUseCase({
    required this.updateAvailabilityDayUseCase,
  });

  /// Fecha o período de disponibilidade
  /// 
  /// **Parâmetros:**
  /// - `ensembleId`: ID do conjunto
  /// - `dto`: DTO com informações de overlaps para cada dia
  /// 
  /// **Retorna:**
  /// - `Right(List<AvailabilityDayEntity>)` com os dias atualizados
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String ensembleId,
    OpenPeriodDto dto,
  ) async {
    try {
        
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ID do conjunto é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Criar mapa de dias com slots reservados para busca rápida
      // ════════════════════════════════════════════════════════════════
      final bookedSlotMap = <DateTime, AvailabilityDayEntity>{};
      for (final dayEntity in dto.daysWithBookedSlot) {
        // Normalizar a data (remover hora) para comparação
        final normalizedDate = DateTime(
          dayEntity.date.year,
          dayEntity.date.month,
          dayEntity.date.day,
        );
        bookedSlotMap[normalizedDate] = dayEntity;
      }

      // ════════════════════════════════════════════════════════════════
      // 2. Processar cada DayOverlapInfo e atualizar o dia
      // ════════════════════════════════════════════════════════════════
      final updatedDays = <AvailabilityDayEntity>[];

      for (var i = 0; i < dto.dayOverlapInfos.length; i++) {
        final overlapInfo = dto.dayOverlapInfos[i];
        // Normalizar a data para comparação
        final normalizedDate = DateTime(
          overlapInfo.date.year,
          overlapInfo.date.month,
          overlapInfo.date.day,
        );

        // ════════════════════════════════════════════════════════════
        // 2.1. Verificar se o dia tem slot reservado - se sim, pular
        // ════════════════════════════════════════════════════════════
        if (bookedSlotMap.containsKey(normalizedDate)) {
          // Dia tem slot reservado, não modificar
          continue;
        }

        // ════════════════════════════════════════════════════════════
        // 2.2. Criar AvailabilityDayEntity a partir do DayOverlapInfo
        // ════════════════════════════════════════════════════════════
        final updatedDay = _createDayFromOverlapInfo(
          baseDay: dto.baseAvailabilityDay,
          overlapInfo: overlapInfo,
          date: normalizedDate,
        );

        // ════════════════════════════════════════════════════════════
        // 2.3. Atualizar o dia usando o usecase
        // ════════════════════════════════════════════════════════════
        final updateResult = await updateAvailabilityDayUseCase(
          ensembleId,
          updatedDay,
        );

        updateResult.fold(
          (failure) {
            throw failure;
          },
          (updatedDayEntity) {
            updatedDays.add(updatedDayEntity);
          },
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 3. Retornar lista de dias atualizados
      // ════════════════════════════════════════════════════════════════
      return Right(updatedDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Cria um AvailabilityDayEntity a partir das informações de overlap
  AvailabilityDayEntity _createDayFromOverlapInfo({
    required AvailabilityDayEntity baseDay,
    required DayOverlapInfo overlapInfo,
    required DateTime date,
  }) {
    // Usar novos slots se disponíveis, senão usar slots antigos
    final slots = overlapInfo.newTimeSlots ?? overlapInfo.oldTimeSlots ?? [];

    // ════════════════════════════════════════════════════════════════
    // REGRA: Se não houver slots, o dia DEVE estar inativo
    // ════════════════════════════════════════════════════════════════
    final isActive = slots.isNotEmpty ? baseDay.isActive : false;
    
    if (slots.isEmpty) {
    }

    // Usar novo endereço se disponível, senão usar endereço antigo ou base
    final endereco = overlapInfo.newAddress ??
        overlapInfo.oldAddress ??
        baseDay.endereco;

    // Usar novo raio se disponível, senão usar raio antigo ou base
    final raioAtuacao = overlapInfo.newRadius ??
        overlapInfo.oldRadius ??
        baseDay.raioAtuacao;

    final createdDay = baseDay.copyWith(
      date: date,
      slots: slots,
      endereco: endereco,
      raioAtuacao: raioAtuacao,
      updatedAt: DateTime.now(),
      isActive: isActive,
    );

    return createdDay;
  }
}
