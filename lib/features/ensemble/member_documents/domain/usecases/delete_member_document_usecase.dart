import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: remover um documento do integrante.
class DeleteMemberDocumentUseCase {
  final IMemberDocumentsRepository repository;

  DeleteMemberDocumentUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) async {
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
      if (documentType != MemberDocumentType.identity &&
          documentType != MemberDocumentType.antecedents) {
        return const Left(
          ValidationFailure('documentType deve ser identity ou antecedents'),
        );
      }
      return await repository.delete(
        artistId: artistId,
        ensembleId: ensembleId,
        memberId: memberId,
        documentType: documentType,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
