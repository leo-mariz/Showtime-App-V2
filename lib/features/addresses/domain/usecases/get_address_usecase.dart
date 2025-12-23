import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase para obter um endereço específico
/// 
/// Valida o UID e o addressId antes de chamar o repositório
class GetAddressUseCase {
  final IAddressesRepository repository;

  GetAddressUseCase({required this.repository});

  Future<Either<Failure, AddressInfoEntity>> call(String uid, String addressId) async {
    try {
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      if (addressId.isEmpty) {
        return const Left(ValidationFailure('ID do endereço não pode ser vazio'));
      }

      return await repository.getAddress(uid, addressId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

