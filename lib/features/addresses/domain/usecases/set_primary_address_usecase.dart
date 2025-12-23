import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Definir endereço como primário
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Validar ID do endereço
/// - Definir endereço como primário no repositório
/// - Remover primário dos outros endereços automaticamente
class SetPrimaryAddressUseCase {
  final IAddressesRepository repository;

  SetPrimaryAddressUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid, String addressId) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      // Validar ID do endereço
      if (addressId.isEmpty) {
        return const Left(ValidationFailure('ID do endereço não pode ser vazio'));
      }

      // Definir endereço como primário
      final result = await repository.setPrimaryAddress(uid, addressId);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

