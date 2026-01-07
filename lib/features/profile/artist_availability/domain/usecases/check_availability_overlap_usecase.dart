import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Resultado da verificação de sobreposição
class OverlapCheckResult {
  final bool hasOverlap;
  final AvailabilityEntity? overlappingAvailability;
  final String priorityReason; // Explica qual terá prioridade e por quê

  OverlapCheckResult({
    required this.hasOverlap,
    this.overlappingAvailability,
    this.priorityReason = '',
  });
}

/// UseCase: Verificar sobreposição de disponibilidade
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Buscar disponibilidades existentes
/// - Verificar se a nova disponibilidade se sobrepõe com alguma existente
/// - Determinar qual disponibilidade terá prioridade na exibição
/// - Retornar resultado com informações sobre a sobreposição
class CheckAvailabilityOverlapUseCase {
  final IAvailabilityRepository availabilityRepository;

  CheckAvailabilityOverlapUseCase({
    required this.availabilityRepository,
  });

  Future<Either<Failure, OverlapCheckResult>> call(
    String uid,
    AvailabilityEntity newAvailability, {
    String? excludeAvailabilityId,
  }) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar disponibilidades existentes
      final availabilityListResult = await availabilityRepository.getAvailabilities(uid);
      
      return availabilityListResult.fold(
        (failure) => Left(failure),
        (existingAvailabilities) {
          // Filtrar disponibilidades existentes, excluindo a que está sendo atualizada (se houver)
          final filteredAvailabilities = excludeAvailabilityId != null
              ? existingAvailabilities.where((a) => a.id != excludeAvailabilityId).toList()
              : existingAvailabilities;
          
          // Verificar sobreposições
          final overlappingAvailabilities = _findOverlaps(newAvailability, filteredAvailabilities);
          
          if (overlappingAvailabilities.isEmpty) {
            // Sem sobreposição - sucesso
            return Right(OverlapCheckResult(hasOverlap: false));
          }
          
          // Há sobreposição - determinar qual terá prioridade
          final priorityResult = _determinePriorityWithFlag(newAvailability, overlappingAvailabilities);
          final priorityAvailability = priorityResult['availability'] as AvailabilityEntity;
          final isNewPriority = priorityResult['isNew'] as bool;
          final priorityReason = _getPriorityReason(newAvailability, priorityAvailability, isNewPriority);
          
          return Right(OverlapCheckResult(
            hasOverlap: true,
            overlappingAvailability: priorityAvailability,
            priorityReason: priorityReason,
          ));
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Encontra todas as disponibilidades que se sobrepõem com a nova
  List<AvailabilityEntity> _findOverlaps(
    AvailabilityEntity newAvailability,
    List<AvailabilityEntity> existingAvailabilities,
  ) {
    final overlaps = <AvailabilityEntity>[];
    final allDaysOfWeek = AvailabilityEntityOptions.daysOfWeekList();
    
    // Converter nova disponibilidade para formato de verificação
    final newStartDate = DateTime(
      newAvailability.dataInicio.year,
      newAvailability.dataInicio.month,
      newAvailability.dataInicio.day,
    );
    final newEndDate = DateTime(
      newAvailability.dataFim.year,
      newAvailability.dataFim.month,
      newAvailability.dataFim.day,
    );
    
    final newRecurrenceDays = newAvailability.repetir
        ? newAvailability.diasDaSemana
        : allDaysOfWeek;
    
    final newStartTimeParts = newAvailability.horarioInicio.split(':');
    final newEndTimeParts = newAvailability.horarioFim.split(':');
    final newStartHour = int.parse(newStartTimeParts[0]);
    final newStartMinutes = int.parse(newStartTimeParts[1]);
    final newEndHour = int.parse(newEndTimeParts[0]);
    final newEndMinutes = int.parse(newEndTimeParts[1]);
    
    for (final existing in existingAvailabilities) {
      // Converter disponibilidade existente para formato de verificação
      final existingStartDate = DateTime(
        existing.dataInicio.year,
        existing.dataInicio.month,
        existing.dataInicio.day,
      );
      final existingEndDate = DateTime(
        existing.dataFim.year,
        existing.dataFim.month,
        existing.dataFim.day,
      );
      
      // FILTROS RÁPIDOS: Casos óbvios de NÃO sobreposição
      
      // 1. Verificar sobreposição de datas (sem sobreposição quando períodos não se tocam)
      // Usa a mesma lógica do close_availability_usecase: se não há interseção, não há sobreposição
      if (existingStartDate.isAfter(newEndDate) || existingEndDate.isBefore(newStartDate)) {
        continue; // Sem sobreposição de datas
      }
      
      final existingRecurrenceDays = existing.repetir
          ? existing.diasDaSemana
          : allDaysOfWeek;
      
      // 2. Verificar sobreposição de dias da semana (sem sobreposição quando não há dias em comum)
      final commonDays = newRecurrenceDays.where((day) => existingRecurrenceDays.contains(day)).toList();
      if (commonDays.isEmpty) {
        continue; // Sem dias em comum na recorrência
      }
      
      final existingStartTimeParts = existing.horarioInicio.split(':');
      final existingEndTimeParts = existing.horarioFim.split(':');
      final existingStartHour = int.parse(existingStartTimeParts[0]);
      final existingStartMinutes = int.parse(existingStartTimeParts[1]);
      final existingEndHour = int.parse(existingEndTimeParts[0]);
      final existingEndMinutes = int.parse(existingEndTimeParts[1]);
      
      // 3. Verificar sobreposição de horários (sem sobreposição quando horários não se tocam)
      // Usa a mesma lógica do close_availability_usecase
      if ((newEndHour < existingStartHour || 
           (newEndHour == existingStartHour && newEndMinutes <= existingStartMinutes)) ||
          (newStartHour > existingEndHour || 
           (newStartHour == existingEndHour && newStartMinutes >= existingEndMinutes))) {
        continue; // Sem sobreposição de horários
      }
      
      // VERIFICAÇÃO DETALHADA: Se passou pelos filtros, há sobreposição
      // A sobreposição existe se:
      // 1) Há interseção no período de datas (já verificado acima)
      // 2) Há dias em comum na recorrência (já verificado acima - quando repetir=false, equivale a todos os dias)
      // 3) Há interseção nos horários (já verificado acima)
      // 
      // IMPORTANTE: Quando repetir=false, tratamos como se tivesse todos os dias da semana (allDaysOfWeek)
      // Isso significa que todos os dias entre dataInicio e dataFim são considerados disponíveis
      
      overlaps.add(existing);
    }
    
    return overlaps;
  }

  /// Determina qual disponibilidade terá prioridade na exibição
  /// Prioridade: 1) Menor valor, 2) Maior raio, 3) Mais recente
  /// Retorna a disponibilidade com prioridade e um flag indicando se é a nova
  Map<String, dynamic> _determinePriorityWithFlag(
    AvailabilityEntity newAvailability,
    List<AvailabilityEntity> overlappingAvailabilities,
  ) {
    // Se não há sobreposições, a nova tem prioridade
    if (overlappingAvailabilities.isEmpty) {
      return {
        'availability': newAvailability,
        'isNew': true,
      };
    }
    
    // Adicionar a nova disponibilidade à lista para comparação
    final allAvailabilities = [newAvailability, ...overlappingAvailabilities];
    
    // Ordenar por: 1) Menor valor, 2) Maior raio, 3) Mais recente (data de início)
    allAvailabilities.sort((a, b) {
      // Prioridade 1: Menor valor
      final valueComparison = a.valorShow.compareTo(b.valorShow);
      if (valueComparison != 0) {
        return valueComparison;
      }
      
      // Prioridade 2: Maior raio
      final radiusComparison = b.raioAtuacao.compareTo(a.raioAtuacao);
      if (radiusComparison != 0) {
        return radiusComparison;
      }
      
      // Prioridade 3: Mais recente (data de início mais recente)
      return b.dataInicio.compareTo(a.dataInicio);
    });
    
    final priority = allAvailabilities.first;
    final isNew = priority == newAvailability || 
        (priority.valorShow == newAvailability.valorShow &&
         priority.raioAtuacao == newAvailability.raioAtuacao &&
         priority.dataInicio.isAtSameMomentAs(newAvailability.dataInicio));
    
    return {
      'availability': priority,
      'isNew': isNew,
    };
  }
  
  /// Gera mensagem explicando qual disponibilidade terá prioridade e por quê
  String _getPriorityReason(
    AvailabilityEntity newAvailability,
    AvailabilityEntity priorityAvailability,
    bool isNewPriority,
  ) {
    if (isNewPriority) {
      // A nova disponibilidade terá prioridade
      return 'A nova disponibilidade será exibida para os clientes, pois possui '
          'menor valor (R\$ ${newAvailability.valorShow.toStringAsFixed(2)}/h) ou maior raio de atuação (${newAvailability.raioAtuacao.toStringAsFixed(1)}km).';
    } else {
      // Uma disponibilidade existente terá prioridade
      return 'A disponibilidade existente será exibida para os clientes, pois possui '
          'menor valor (R\$ ${priorityAvailability.valorShow.toStringAsFixed(2)}/h) ou maior raio de atuação (${priorityAvailability.raioAtuacao.toStringAsFixed(1)}km). '
          'A nova disponibilidade ficará salva, mas não será exibida enquanto houver sobreposição.';
    }
  }
}

