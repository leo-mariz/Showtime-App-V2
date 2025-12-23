import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo endereço
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Validar dados do endereço
/// - Adicionar endereço no repositório
/// - Retornar ID do endereço criado
class AddAddressUseCase {
  final IAddressesRepository repository;

  AddAddressUseCase({
    required this.repository,
  });

  Future<Either<Failure, String>> call(String uid, AddressInfoEntity address) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      // Validar dados do endereço
      if (address.zipCode.isEmpty) {
        return const Left(ValidationFailure('CEP não pode ser vazio'));
      }

      // Adicionar endereço
      final result = await repository.addAddress(uid, address);

      return result.fold(
        (failure) => Left(failure),
        (addressId) => Right(addressId),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

