import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: salvar/atualizar um documento do integrante.
class SaveMemberDocumentUseCase {
  final IMemberDocumentsRepository repository;

  SaveMemberDocumentUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    MemberDocumentEntity document,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (document.documentType != MemberDocumentType.identity &&
          document.documentType != MemberDocumentType.antecedents) {
        return const Left(
          ValidationFailure('documentType deve ser identity ou antecedents'),
        );
      }
      return await repository.save(
        artistId: artistId,
        document: document,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
