import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar todos os documentos do artista logado
/// 
/// RESPONSABILIDADES:
/// - Obter UID do usuário logado
/// - Buscar documentos do repositório (cache-first)
/// - Retornar lista de documentos
class GetDocumentsUseCase {
  final IDocumentsRepository documentsRepository;
  final GetUserUidUseCase getUserUidUseCase;

  GetDocumentsUseCase({
    required this.documentsRepository,
    required this.getUserUidUseCase,
  });

  Future<Either<Failure, List<DocumentsEntity>>> call() async {
    try {
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('UID do artista não encontrado'));
      }

      final result = await documentsRepository.getDocuments(uid);

      return result.fold(
        (failure) => Left(failure),
        (documents) => Right(documents),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

