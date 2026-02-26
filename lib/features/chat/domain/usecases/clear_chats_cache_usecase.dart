import 'package:app/core/errors/failure.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Limpar cache local de chats do usuário atual.
///
/// Obtém o UID do usuário autenticado e limpa a lista de chats em cache
/// e o contador de mensagens não lidas associados a esse usuário.
class ClearChatsCacheUseCase {
  final IChatRepository repository;
  final GetUserUidUseCase getUserUidUseCase;

  ClearChatsCacheUseCase({
    required this.repository,
    required this.getUserUidUseCase,
  });

  /// Limpa o cache de chats do usuário atual.
  /// Retorna [Right(null)] em sucesso ou [Left(Failure)] em caso de erro ou usuário não autenticado.
  Future<Either<Failure, void>> call() async {
    final uidResult = await getUserUidUseCase.call();
    return uidResult.fold(
      (failure) => Left(failure),
      (uid) async {
        if (uid == null || uid.isEmpty) {
          return const Left(AuthFailure('Usuário não autenticado'));
        }
        return repository.clearChatsCache(uid);
      },
    );
  }
}
