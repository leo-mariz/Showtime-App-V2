import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se o nome do conjunto já existe no banco de dados.
///
/// RESPONSABILIDADES:
/// - Validar nome do conjunto
/// - Verificar existência no banco de dados
/// - Excluir o próprio conjunto da verificação (se [excludeEnsembleId] fornecido)
class CheckEnsembleNameExistsUseCase {
  final IEnsembleRepository repository;

  CheckEnsembleNameExistsUseCase({
    required this.repository,
  });

  Future<Either<Failure, bool>> call(
    String ensembleName, {
    String? excludeEnsembleId,
  }) async {
    try {
      if (ensembleName.trim().isEmpty) {
        return const Left(ValidationFailure('Nome do conjunto não pode ser vazio'));
      }

      final result = await repository.ensembleNameExists(
        ensembleName.trim(),
        excludeEnsembleId: excludeEnsembleId,
      );

      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
