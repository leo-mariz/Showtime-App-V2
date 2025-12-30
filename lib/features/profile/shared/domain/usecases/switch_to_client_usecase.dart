import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/clients/domain/usecases/get_client_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se o usuário pode trocar para perfil de cliente
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Verificar se perfil de cliente já existe
/// - Retornar resultado indicando se perfil existe ou não
class SwitchToClientUseCase {
  final GetUserUidUseCase getUserUidUseCase;
  final GetClientUseCase getClientUseCase;

  SwitchToClientUseCase({
    required this.getUserUidUseCase,
    required this.getClientUseCase,
  });

  Future<Either<Failure, bool>> call() async {
    try {
      // 1. Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não encontrado'));
      }

      // 2. Verificar se cliente já existe
      final clientResult = await getClientUseCase.call(uid);

      return clientResult.fold(
        (failure) {
          // Para cliente, NotFoundFailure indica que não existe
          // Se for NotFoundFailure, retornar false (perfil não existe)
          // Se for outro tipo de erro, retornar o erro
          if (failure is NotFoundFailure) {
            return const Right(false);
          }
          return Left(failure);
        },
        (_) {
          // Se chegou aqui, o cliente existe
          return const Right(true);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

