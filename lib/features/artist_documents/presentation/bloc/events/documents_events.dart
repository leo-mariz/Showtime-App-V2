import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:equatable/equatable.dart';

abstract class DocumentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET DOCUMENTS EVENTS ====================

class GetDocumentsEvent extends DocumentsEvent {}

// ==================== SET DOCUMENT EVENTS ====================

class SetDocumentEvent extends DocumentsEvent {
  final DocumentsEntity document;
  final String? localFilePath;

  SetDocumentEvent({
    required this.document,
    this.localFilePath,
  });

  @override
  List<Object?> get props => [document, localFilePath];
}

