import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar endereço e raio de atuação de um dia
/// 
/// Atualiza o endereço base e o raio de atuação da disponibilidade
/// de um dia específico. Como só temos uma entry por dia, atualiza
/// a primeira (e única) entry.
class UpdateAddressAndRadiusUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateAddressAndRadiusUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    UpdateAddressRadiusDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      final addressRadius = dto.addressRadius;

      if (addressRadius.addressId.isEmpty) {
        return const Left(ValidationFailure('ID do endereço é obrigatório'));
      }

      if (addressRadius.raioAtuacao <= 0) {
        return const Left(
          ValidationFailure('Raio de atuação deve ser maior que zero'),
        );
      }

      // Buscar disponibilidade do dia
      final getDayResult = await getByDate(
        artistId,
        GetAvailabilityByDateDto(date: dto.date, forceRemote: true),
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          if (dayEntity.availabilities.isEmpty) {
            return const Left(ValidationFailure('Dia sem disponibilidades'));
          }

          // Atualizar primeira (e única) entry
          final firstEntry = dayEntity.availabilities.first;
          final updatedEntry = firstEntry.copyWith(
            addressId: addressRadius.addressId,
            raioAtuacao: addressRadius.raioAtuacao,
            endereco: addressRadius.endereco,
          );

          // Criar lista atualizada
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
