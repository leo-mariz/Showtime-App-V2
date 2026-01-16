import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar nova disponibilidade
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Validar dados da disponibilidade
/// - Calcular Geohash do endereço da disponibilidade
/// - Adicionar disponibilidade no repositório com Geohash
/// - Retornar ID da disponibilidade criada
class AddAvailabilityUseCase {
  final IAvailabilityRepository availabilityRepository;
  final SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase;

  AddAvailabilityUseCase({
    required this.availabilityRepository,
    required this.syncArtistCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, String>> call(String uid, AvailabilityEntity availability) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Validar dados básicos da disponibilidade
      if (availability.dataInicio.isAfter(availability.dataFim)) {
        return const Left(ValidationFailure('Data de início deve ser anterior à data de fim'));
      }

      // Adicionar disponibilidade
      final result = await availabilityRepository.addAvailability(uid, availability);

      // Sincronizar completude apenas se mudou
      await syncArtistCompletenessIfChangedUseCase.call();

      return result.fold(
        (failure) => Left(failure),
        (availabilityId) => Right(availabilityId),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

