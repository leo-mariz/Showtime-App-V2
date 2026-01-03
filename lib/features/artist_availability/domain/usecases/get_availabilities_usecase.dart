import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar todas as disponibilidades do artista logado
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Buscar disponibilidades do repositório (cache-first)
/// - Retornar lista de disponibilidades
class GetAvailabilitiesUseCase {
  final IAvailabilityRepository availabilityRepository;

  GetAvailabilitiesUseCase({
    required this.availabilityRepository,
  });

  Future<Either<Failure, List<AvailabilityEntity>>> call(String uid) async {
    try {
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      final result = await availabilityRepository.getAvailabilities(uid);

      return result.fold(
        (failure) => Left(failure),
        (availabilities) => Right(availabilities),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

