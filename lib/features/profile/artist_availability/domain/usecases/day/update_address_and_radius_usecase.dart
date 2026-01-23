import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar endereço e raio de atuação de um dia
/// 
/// Atualiza o endereço base e o raio de atuação da disponibilidade
/// de um dia específico. Como só temos uma entry por dia, atualiza
/// a primeira (e única) entry.
class UpdateAddressAndRadiusUseCase {
  final UpdateAvailabilityDayUseCase updateAvailabilityDay;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateAddressAndRadiusUseCase({
    required this.updateAvailabilityDay,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    DateTime date,
    double radius,
    AddressInfoEntity address,
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

          // Atualizar endereço e raio de atuação diretamente no dia
          final updatedDay = dayEntity.copyWith(
            raioAtuacao: radius,
            endereco: address,
            updatedAt: DateTime.now(),
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
