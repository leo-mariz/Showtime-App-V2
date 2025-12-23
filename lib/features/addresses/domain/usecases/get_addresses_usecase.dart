import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar lista de endereços do usuário
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Buscar endereços do repositório (cache primeiro, depois remoto)
/// - Retornar lista de endereços
class GetAddressesUseCase {
  final IAddressesRepository repository;

  GetAddressesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<AddressInfoEntity>>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      // Buscar endereços
      final result = await repository.getAddresses(uid);

      return result.fold(
        (failure) => Left(failure),
        (addresses) => Right(addresses),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

