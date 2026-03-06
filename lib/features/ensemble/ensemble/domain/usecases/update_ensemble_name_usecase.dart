import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_name_exists_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar nome do conjunto.
///
/// RESPONSABILIDADES:
/// - Validar artistId, ensembleId e ensembleName
/// - Verificar se o nome já está em uso por outro conjunto
/// - Buscar conjunto atual
/// - Atualizar apenas o campo ensembleName
/// - Persistir e sincronizar completude (via [UpdateEnsembleUseCase])
class UpdateEnsembleNameUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final CheckEnsembleNameExistsUseCase checkEnsembleNameExistsUseCase;

  UpdateEnsembleNameUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.checkEnsembleNameExistsUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    String ensembleName,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      final name = ensembleName.trim();
      if (name.isEmpty) {
        return const Left(ValidationFailure('Nome do conjunto não pode ser vazio'));
      }

      final checkResult = await checkEnsembleNameExistsUseCase(
        name,
        excludeEnsembleId: ensembleId,
      );

      return await checkResult.fold(
        (failure) => Left(failure),
        (nameExists) async {
          if (nameExists) {
            return const Left(
              ValidationFailure('Este nome de conjunto já está em uso'),
            );
          }

          final getResult = await getEnsembleUseCase(artistId, ensembleId);
          return getResult.fold(
            (failure) => Left(failure),
            (currentEnsemble) async {
              if (currentEnsemble == null) {
                return const Left(ValidationFailure('Conjunto não encontrado'));
              }
              final updated = currentEnsemble.copyWith(ensembleName: name);
              final updateResult = await updateEnsembleUseCase(artistId, updated);
              return updateResult.fold(
                (f) => Left(f),
                (_) => Right(updated),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
