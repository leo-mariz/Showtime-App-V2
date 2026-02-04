import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Use Case para adicionar disponibilidade de um dia completo
/// 
/// Cria um novo dia de disponibilidade com os slots fornecidos.
/// **Não realiza validações** - apenas cria e salva o dia.
/// 
/// **Uso:**
/// ```dart
/// final dto = AddAvailabilityDayDto(
///   date: DateTime(2026, 1, 15),
///   slots: [
///     TimeSlotDto.create(
///       startTime: '14:00',
///       endTime: '18:00',
///       valorHora: 300.0,
///     ),
///     TimeSlotDto.create(
///       startTime: '19:00',
///       endTime: '22:00',
///       valorHora: 350.0,
///     ),
///   ],
///   raioAtuacao: 50.0,
///   endereco: addressInfo,
///   isManualOverride: true,
/// );
/// 
/// final result = await addAvailabilityDayUseCase(artistId, dto);
/// ```
class CreateAvailabilityDayUseCase {
  final IAvailabilityRepository repository;

  CreateAvailabilityDayUseCase({
    required this.repository,
  });

  /// Adiciona disponibilidade de um dia
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `dto`: DTO com os dados do dia a ser criado
  /// 
  /// **Retorna:**
  /// - `Right(AvailabilityDayEntity)` em caso de sucesso
  /// - `Left(Failure)` em caso de erro
  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    AvailabilityDayEntity dayEntity,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════
      // 1. Atualizar a entidade do dia
      // ════════════════════════════════════════════════════════════
      final newDayEntity = dayEntity.copyWith(
        updatedAt: DateTime.now(),
        isActive: true,
      );

      // ════════════════════════════════════════════════════════════
      // 3. Salvar no repositório
      // ════════════════════════════════════════════════════════════
      return await repository.createAvailability(
        artistId: artistId,
        day: newDayEntity,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
