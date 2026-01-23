import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para ativar/desativar disponibilidade de um dia
/// 
/// Permite alternar o status de ativo/inativo de toda a disponibilidade
/// de um dia específico sem deletar os dados.
class ToggleAvailabilityStatusUseCase {
  final UpdateAvailabilityDayUseCase updateAvailabilityDay;
  final GetAvailabilityByDateUseCase getByDate;

  ToggleAvailabilityStatusUseCase({
    required this.updateAvailabilityDay,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    DateTime date,
    bool isActive,
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
        (dayEntity) {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          // Atualizar status
          final updatedDay = dayEntity.copyWith(
            isActive: isActive,
          );

          // Atualizar no repositório
          return updateAvailabilityDay.call(
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
