import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Remover contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Remover contrato do repositório
class DeleteContractUseCase {
  final IContractRepository repository;

  DeleteContractUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String contractUid) async {
    try {
      // Validar UID
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Remover contrato
      final result = await repository.deleteContract(contractUid);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

