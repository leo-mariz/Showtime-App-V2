import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar nova disponibilidade
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Validar dados da disponibilidade
/// - Adicionar disponibilidade no repositório
/// - Retornar ID da disponibilidade criada
class AddAvailabilityUseCase {
  final IAvailabilityRepository availabilityRepository;
  final GetUserUidUseCase getUserUidUseCase;

  AddAvailabilityUseCase({
    required this.availabilityRepository,
    required this.getUserUidUseCase,
  });

  Future<Either<Failure, String>> call(AvailabilityEntity availability) async {
    try {
      // Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => null,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(ServerFailure('Usuário não encontrado'));
      }

      // Validar dados básicos da disponibilidade
      if (availability.dataInicio.isAfter(availability.dataFim)) {
        return const Left(ValidationFailure('Data de início deve ser anterior à data de fim'));
      }

      // Adicionar disponibilidade
      final result = await availabilityRepository.addAvailability(uid, availability);

      return result.fold(
        (failure) => Left(failure),
        (availabilityId) => Right(availabilityId),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

