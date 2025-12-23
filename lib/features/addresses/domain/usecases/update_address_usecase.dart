import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar endereço existente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Validar ID do endereço
/// - Validar dados do endereço
/// - Atualizar endereço no repositório
class UpdateAddressUseCase {
  final IAddressesRepository repository;

  UpdateAddressUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(
    String uid,
    String addressId,
    AddressInfoEntity address,
  ) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      // Validar ID do endereço
      if (addressId.isEmpty) {
        return const Left(ValidationFailure('ID do endereço não pode ser vazio'));
      }

      // Validar dados do endereço
      if (address.zipCode.isEmpty) {
        return const Left(ValidationFailure('CEP não pode ser vazio'));
      }

      // Atualizar endereço
      final result = await repository.updateAddress(uid, addressId, address);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

