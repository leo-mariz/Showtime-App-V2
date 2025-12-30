import 'package:app/features/artist_documents/domain/usecases/get_documents_usecase.dart';
import 'package:app/features/artist_documents/domain/usecases/set_document_usecase.dart';
import 'package:app/features/artist_documents/presentation/bloc/events/documents_events.dart';
import 'package:app/features/artist_documents/presentation/bloc/states/documents_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final GetDocumentsUseCase getDocumentsUseCase;
  final SetDocumentUseCase setDocumentUseCase;

  DocumentsBloc({
    required this.getDocumentsUseCase,
    required this.setDocumentUseCase,
  }) : super(DocumentsInitial()) {
    on<GetDocumentsEvent>(_onGetDocumentsEvent);
    on<SetDocumentEvent>(_onSetDocumentEvent);
  }

  // ==================== GET DOCUMENTS ====================

  Future<void> _onGetDocumentsEvent(
    GetDocumentsEvent event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(GetDocumentsLoading());

    final result = await getDocumentsUseCase.call();

    result.fold(
      (failure) {
        emit(GetDocumentsFailure(error: failure.message));
        emit(DocumentsInitial());
      },
      (documents) {
        emit(GetDocumentsSuccess(documents: documents));
      },
    );
  }

  // ==================== SET DOCUMENT ====================

  Future<void> _onSetDocumentEvent(
    SetDocumentEvent event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(SetDocumentLoading());

    final result = await setDocumentUseCase.call(
      event.document,
      localFilePath: event.localFilePath,
    );

    result.fold(
      (failure) {
        emit(SetDocumentFailure(error: failure.message));
        emit(DocumentsInitial());
      },
      (_) {
        emit(SetDocumentSuccess());
        emit(DocumentsInitial());
      },
    );
  }
}

