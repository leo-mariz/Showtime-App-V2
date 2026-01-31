import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MemberDocumentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MemberDocumentsInitial extends MemberDocumentsState {}

// ==================== GET ALL MEMBER DOCUMENTS ====================

class GetAllMemberDocumentsLoading extends MemberDocumentsState {}

class GetAllMemberDocumentsSuccess extends MemberDocumentsState {
  final List<MemberDocumentEntity> documents;

  GetAllMemberDocumentsSuccess({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class GetAllMemberDocumentsFailure extends MemberDocumentsState {
  final String error;

  GetAllMemberDocumentsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET MEMBER DOCUMENT ====================

class GetMemberDocumentLoading extends MemberDocumentsState {}

class GetMemberDocumentSuccess extends MemberDocumentsState {
  final MemberDocumentEntity? document;

  GetMemberDocumentSuccess({required this.document});

  @override
  List<Object?> get props => [document];
}

class GetMemberDocumentFailure extends MemberDocumentsState {
  final String error;

  GetMemberDocumentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SAVE MEMBER DOCUMENT ====================

class SaveMemberDocumentLoading extends MemberDocumentsState {}

class SaveMemberDocumentSuccess extends MemberDocumentsState {
  final MemberDocumentEntity document;

  SaveMemberDocumentSuccess({required this.document});

  @override
  List<Object?> get props => [document];
}

class SaveMemberDocumentFailure extends MemberDocumentsState {
  final String error;

  SaveMemberDocumentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE MEMBER DOCUMENT ====================

class DeleteMemberDocumentLoading extends MemberDocumentsState {}

class DeleteMemberDocumentSuccess extends MemberDocumentsState {
  final String memberId;
  final String documentType;

  DeleteMemberDocumentSuccess({
    required this.memberId,
    required this.documentType,
  });

  @override
  List<Object?> get props => [memberId, documentType];
}

class DeleteMemberDocumentFailure extends MemberDocumentsState {
  final String error;

  DeleteMemberDocumentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CLEAR CACHE ====================

class ClearMemberDocumentsCacheSuccess extends MemberDocumentsState {}

class ClearMemberDocumentsCacheFailure extends MemberDocumentsState {
  final String error;

  ClearMemberDocumentsCacheFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
