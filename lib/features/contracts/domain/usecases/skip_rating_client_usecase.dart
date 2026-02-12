import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Pular avaliação do cliente (artista escolhe "Avaliar depois").
/// Apenas chama a function; toda a escrita e validação é feita no backend.
class SkipRatingClientUseCase {
  final IContractsFunctionsService contractsFunctions;

  SkipRatingClientUseCase({required this.contractsFunctions});

  Future<Either<Failure, void>> call({
    required String contractUid,
  }) async {
    try {
      if (contractUid.trim().isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }
      await contractsFunctions.skipRatingClient(contractUid.trim());
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
