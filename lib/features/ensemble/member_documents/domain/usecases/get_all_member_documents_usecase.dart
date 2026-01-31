import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: listar os documentos do integrante (identity e antecedents).
class GetAllMemberDocumentsUseCase {
  final IMemberDocumentsRepository repository;

  GetAllMemberDocumentsUseCase({required this.repository});

  Future<Either<Failure, List<MemberDocumentEntity>>> call(
    String artistId,
    String ensembleId,
    String memberId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      if (memberId.isEmpty) {
        return const Left(ValidationFailure('memberId é obrigatório'));
      }
      return await repository.getAllByMember(
        artistId: artistId,
        ensembleId: ensembleId,
        memberId: memberId,
        forceRemote: forceRemote,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
