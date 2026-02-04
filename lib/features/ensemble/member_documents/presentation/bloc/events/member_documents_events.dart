import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MemberDocumentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ALL MEMBER DOCUMENTS ====================

class GetAllMemberDocumentsEvent extends MemberDocumentsEvent {
  final String ensembleId;
  final String memberId;
  final bool forceRemote;

  GetAllMemberDocumentsEvent({
    required this.ensembleId,
    required this.memberId,
    this.forceRemote = false,
  });

  @override
  List<Object?> get props => [ensembleId, memberId, forceRemote];
}

// ==================== GET MEMBER DOCUMENT ====================

class GetMemberDocumentEvent extends MemberDocumentsEvent {
  final String ensembleId;
  final String memberId;
  final String documentType;

  GetMemberDocumentEvent({
    required this.ensembleId,
    required this.memberId,
    required this.documentType,
  });

  @override
  List<Object?> get props => [ensembleId, memberId, documentType];
}

// ==================== SAVE MEMBER DOCUMENT ====================

class SaveMemberDocumentEvent extends MemberDocumentsEvent {
  final MemberDocumentEntity document;
  final String? localFilePath;

  SaveMemberDocumentEvent({
    required this.document,
    this.localFilePath,
  });

  @override
  List<Object?> get props => [document, localFilePath];
}

// ==================== DELETE MEMBER DOCUMENT ====================

class DeleteMemberDocumentEvent extends MemberDocumentsEvent {
  final String ensembleId;
  final String memberId;
  final String documentType;

  DeleteMemberDocumentEvent({
    required this.ensembleId,
    required this.memberId,
    required this.documentType,
  });

  @override
  List<Object?> get props => [ensembleId, memberId, documentType];
}

// ==================== CLEAR CACHE ====================

class ClearMemberDocumentsCacheEvent extends MemberDocumentsEvent {
  final String ensembleId;
  final String memberId;

  ClearMemberDocumentsCacheEvent({
    required this.ensembleId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [ensembleId, memberId];
}

// ==================== RESET ====================

class ResetMemberDocumentsEvent extends MemberDocumentsEvent {}
