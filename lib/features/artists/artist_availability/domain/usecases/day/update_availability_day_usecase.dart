import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar disponibilidade de um dia
/// 
/// Atualiza apenas os campos fornecidos no `dayEntity`:
/// - `slots`: Se fornecido, substitui os slots existentes
/// - `endereco`: Se fornecido, substitui o endereço existente
/// - `raioAtuacao`: Se fornecido, substitui o raio existente
/// - `isActive`: Se fornecido, atualiza o status ativo/inativo
/// 
/// Campos não fornecidos (null) são mantidos do dia existente.
/// 
/// **Uso:**
/// ```dart
/// // Atualizar apenas os slots
/// final updatedDay = existingDay.copyWith(
///   slots: newSlots,
///   updatedAt: DateTime.now(),
/// );
/// await updateAvailabilityDayUseCase(artistId, updatedDay);
/// 
/// // Atualizar apenas endereço e raio
/// final updatedDay = existingDay.copyWith(
///   endereco: newAddress,
///   raioAtuacao: newRadius,
///   updatedAt: DateTime.now(),
/// );
/// await updateAvailabilityDayUseCase(artistId, updatedDay);
/// ```
class UpdateAvailabilityDayUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateAvailabilityDayUseCase({
    required this.repository,
    required this.getByDate,
  });

  /// Atualiza disponibilidade de um dia
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `dayEntity`: Entidade com os campos a serem atualizados (null = manter existente)
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

      // ════════════════════════════════════════════════════════════════
      // 1. Buscar dia existente
      // ════════════════════════════════════════════════════════════════
      final getDayResult = await getByDate(artistId, dayEntity.date);

      return await getDayResult.fold(
        (failure) async => Left(failure),
        (existingDay) async {
          if (existingDay == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          // ════════════════════════════════════════════════════════════
          // 2. Atualizar apenas os campos fornecidos
          // ════════════════════════════════════════════════════════════
          // O copyWith do dart_mappable mantém valores quando o parâmetro não é passado
          // Se passarmos null explicitamente, pode substituir. Então usamos ?? para manter existente
          final updatedDay = existingDay.copyWith(
            // Slots: se fornecido (não null), atualiza; senão mantém existente
            slots: dayEntity.slots ?? existingDay.slots,
            // Endereço: se fornecido (não null), atualiza; senão mantém existente
            endereco: dayEntity.endereco ?? existingDay.endereco,
            // Raio: se fornecido (não null), atualiza; senão mantém existente
            raioAtuacao: dayEntity.raioAtuacao ?? existingDay.raioAtuacao,
            // isActive: sempre atualiza (bool não-nullable, sempre tem valor)
            isActive: dayEntity.isActive,
            // Sempre atualizar updatedAt
            updatedAt: DateTime.now(),
          );

          // ════════════════════════════════════════════════════════════
          // 3. Salvar no repositório
          // ════════════════════════════════════════════════════════════
          final updateResult = await repository.updateAvailability(
            artistId: artistId,
            day: updatedDay,
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
