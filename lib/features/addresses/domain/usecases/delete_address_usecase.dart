import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Remover endereço
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Validar ID do endereço
/// - Remover endereço do repositório
class DeleteAddressUseCase {
  final IAddressesRepository repository;

  DeleteAddressUseCase({
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

      // Remover endereço
      final result = await repository.deleteAddress(uid, addressId);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

