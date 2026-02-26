import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Limpar cache local de contratos do usuário atual.
///
/// Obtém o UID do usuário autenticado e limpa os caches de lista
/// (por cliente e por artista) associados a esse usuário.
class ClearContractsCacheUseCase {
  final IContractRepository repository;
  final GetUserUidUseCase getUserUidUseCase;

  ClearContractsCacheUseCase({
    required this.repository,
    required this.getUserUidUseCase,
  });

  /// Limpa o cache de contratos do usuário atual.
  /// Retorna [Right(null)] em sucesso ou [Left(Failure)] em caso de erro ou usuário não autenticado.
  Future<Either<Failure, void>> call() async {
    final uidResult = await getUserUidUseCase.call();
    return uidResult.fold(
      (failure) => Left(failure),
      (uid) async {
        if (uid == null || uid.isEmpty) {
          return const Left(AuthFailure('Usuário não autenticado'));
        }
        return repository.clearContractsCache(userId: uid);
      },
    );
  }
}
