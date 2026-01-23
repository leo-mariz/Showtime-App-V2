import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/create_availability_day_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para abrir um período de disponibilidade
/// 
/// Gera todas as datas do patternMetadata e para cada data:
/// - Se não existe em dayOverlapInfos: cria usando baseAvailabilityDay
/// - Se existe em dayOverlapInfos: atualiza usando informações do DayOverlapInfo
class OpenPeriodUseCase {
  final CreateAvailabilityDayUseCase createAvailabilityDayUseCase;
  final UpdateAvailabilityDayUseCase updateAvailabilityDayUseCase;

  OpenPeriodUseCase({
    required this.createAvailabilityDayUseCase,
    required this.updateAvailabilityDayUseCase,
  });

  /// Abre o período de disponibilidade
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `dto`: DTO com modelo base e informações de overlaps
  /// 
  /// **Retorna:**
  /// - `Right(List<AvailabilityDayEntity>)` com os dias criados/atualizados
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    OpenPeriodDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Gerar datas válidas do patternMetadata
      // ════════════════════════════════════════════════════════════════
      final patternMetadata = dto.baseAvailabilityDay.patternMetadata;
      if (patternMetadata == null || patternMetadata.isEmpty) {
        return const Left(
          ValidationFailure('patternMetadata é obrigatório no baseAvailabilityDay'),
        );
      }

      // Usar o primeiro patternMetadata para gerar as datas
      final firstPattern = patternMetadata.first;
      if (firstPattern.recurrence == null) {
        return const Left(
          ValidationFailure('recurrence é obrigatório no patternMetadata'),
        );
      }

      final validDates = _generateValidDatesFromPattern(firstPattern);

      if (validDates.isEmpty) {
        return const Left(
          ValidationFailure('Nenhuma data válida encontrada no padrão'),
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 2. Criar mapa de overlaps por data para busca rápida
      // ════════════════════════════════════════════════════════════════
      final overlapMap = <DateTime, DayOverlapInfo>{};
      for (final overlapInfo in dto.dayOverlapInfos) {
        // Normalizar a data (remover hora) para comparação
        final normalizedDate = DateTime(
          overlapInfo.date.year,
          overlapInfo.date.month,
          overlapInfo.date.day,
        );
        overlapMap[normalizedDate] = overlapInfo;
      }

      // ════════════════════════════════════════════════════════════════
      // 2.1. Criar mapa de dias com slots reservados para busca rápida
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
      // 3. Processar cada data
      // ════════════════════════════════════════════════════════════════
      final createdDays = <AvailabilityDayEntity>[];

      for (final date in validDates) {
        // Normalizar a data para comparação
        final normalizedDate = DateTime(
          date.year,
          date.month,
          date.day,
        );

        // ════════════════════════════════════════════════════════════
        // 3.0. Verificar se o dia tem slot reservado - se sim, pular
        // ════════════════════════════════════════════════════════════
        if (bookedSlotMap.containsKey(normalizedDate)) {
          // Dia tem slot reservado, não modificar
          continue;
        }

        final overlapInfo = overlapMap[normalizedDate];

        if (overlapInfo == null) {
          // ════════════════════════════════════════════════════════════
          // 3.1. Data não tem overlap - criar usando modelo base
          // ════════════════════════════════════════════════════════════
          final newDay = dto.baseAvailabilityDay.copyWith(
            date: normalizedDate,
            updatedAt: DateTime.now(),
            isActive: true,
          );

          final createResult = await createAvailabilityDayUseCase(
            artistId,
            newDay,
          );

          createResult.fold(
            (failure) => throw failure,
            (createdDay) => createdDays.add(createdDay),
          );
        } else {
          // ════════════════════════════════════════════════════════════
          // 3.2. Data tem overlap - criar usando informações do overlap
          // ════════════════════════════════════════════════════════════
          final updatedDay = _createDayFromOverlapInfo(
            baseDay: dto.baseAvailabilityDay,
            overlapInfo: overlapInfo,
            date: normalizedDate,
          );

          final updateResult = await updateAvailabilityDayUseCase(
            artistId,
            updatedDay,
          );

          updateResult.fold(
            (failure) => throw failure,
            (updatedDayEntity) => createdDays.add(updatedDayEntity),
          );
        }
      }

      // ════════════════════════════════════════════════════════════════
      // 4. Retornar lista de dias criados/atualizados
      // ════════════════════════════════════════════════════════════════
      return Right(createdDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Gera datas válidas a partir do patternMetadata
  List<DateTime> _generateValidDatesFromPattern(
    PatternMetadata patternMetadata,
  ) {
    if (patternMetadata.recurrence == null) {
      return [];
    }

    final recurrence = patternMetadata.recurrence!;
    return AvailabilityHelpers.generateValidDates(
      startDate: recurrence.originalStartDate,
      endDate: recurrence.originalEndDate,
      weekdays: recurrence.weekdays,
    );
  }

  /// Cria um AvailabilityDayEntity a partir das informações de overlap
  AvailabilityDayEntity _createDayFromOverlapInfo({
    required AvailabilityDayEntity baseDay,
    required DayOverlapInfo overlapInfo,
    required DateTime date,
  }) {
    // Usar novos slots se disponíveis, senão usar slots antigos
    final slots = overlapInfo.newTimeSlots ?? overlapInfo.oldTimeSlots ?? [];

    // Usar novo endereço se disponível, senão usar endereço antigo ou base
    final endereco = overlapInfo.newAddress ??
        overlapInfo.oldAddress ??
        baseDay.endereco;

    // Usar novo raio se disponível, senão usar raio antigo ou base
    final raioAtuacao = overlapInfo.newRadius ??
        overlapInfo.oldRadius ??
        baseDay.raioAtuacao;

    return baseDay.copyWith(
      date: date,
      slots: slots,
      endereco: endereco,
      raioAtuacao: raioAtuacao,
      updatedAt: DateTime.now(),
      isActive: true,
    );
  }
}
