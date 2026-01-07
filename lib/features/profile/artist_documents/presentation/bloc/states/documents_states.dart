import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:equatable/equatable.dart';

abstract class DocumentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DocumentsInitial extends DocumentsState {}

// ==================== GET DOCUMENTS STATES ====================

class GetDocumentsLoading extends DocumentsState {}

class GetDocumentsSuccess extends DocumentsState {
  final List<DocumentsEntity> documents;

  GetDocumentsSuccess({
    required this.documents,
  });

  @override
  List<Object?> get props => [documents];
}

class GetDocumentsFailure extends DocumentsState {
  final String error;

  GetDocumentsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SET DOCUMENT STATES ====================

class SetDocumentLoading extends DocumentsState {}

class SetDocumentSuccess extends DocumentsState {}

class SetDocumentFailure extends DocumentsState {
  final String error;

  SetDocumentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

