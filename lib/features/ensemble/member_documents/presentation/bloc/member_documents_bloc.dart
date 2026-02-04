
import 'package:app/features/ensemble/member_documents/domain/usecases/get_all_member_documents_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/get_member_document_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/save_member_document_usecase.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/events/member_documents_events.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/states/member_documents_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberDocumentsBloc extends Bloc<MemberDocumentsEvent, MemberDocumentsState> {
  final GetAllMemberDocumentsUseCase getAllMemberDocumentsUseCase;
  final GetMemberDocumentUseCase getMemberDocumentUseCase;
  final SaveMemberDocumentUseCase saveMemberDocumentUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  MemberDocumentsBloc({
    required this.getAllMemberDocumentsUseCase,
    required this.getMemberDocumentUseCase,
    required this.saveMemberDocumentUseCase,
    required this.getUserUidUseCase,
  }) : super(MemberDocumentsInitial()) {
    on<GetAllMemberDocumentsEvent>(_onGetAllMemberDocuments);
    on<GetMemberDocumentEvent>(_onGetMemberDocument);
    on<SaveMemberDocumentEvent>(_onSaveMemberDocument);
    on<ResetMemberDocumentsEvent>(_onResetMemberDocuments);
  }

  Future<String?> _getCurrentArtistId() async {
    final result = await getUserUidUseCase.call();
    return result.fold((_) => null, (uid) => uid);
  }

  Future<void> _onGetAllMemberDocuments(
    GetAllMemberDocumentsEvent event,
    Emitter<MemberDocumentsState> emit,
  ) async {
    emit(GetAllMemberDocumentsLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetAllMemberDocumentsFailure(error: 'Usuário não autenticado'));
      emit(MemberDocumentsInitial());
      return;
    }
    final result = await getAllMemberDocumentsUseCase.call(
      artistId,
      event.ensembleId,
      event.memberId,
      forceRemote: event.forceRemote,
    );
    result.fold(
      (failure) {
        emit(GetAllMemberDocumentsFailure(error: failure.message));
        emit(MemberDocumentsInitial());
      },
      (documents) {
        emit(GetAllMemberDocumentsSuccess(documents: documents));
        emit(MemberDocumentsInitial());
      },
    );
  }

  Future<void> _onGetMemberDocument(
    GetMemberDocumentEvent event,
    Emitter<MemberDocumentsState> emit,
  ) async {
    emit(GetMemberDocumentLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(GetMemberDocumentFailure(error: 'Usuário não autenticado'));
      emit(MemberDocumentsInitial());
      return;
    }
    final result = await getMemberDocumentUseCase.call(
      artistId,
      event.ensembleId,
      event.memberId,
      event.documentType,
    );
    result.fold(
      (failure) {
        emit(GetMemberDocumentFailure(error: failure.message));
        emit(MemberDocumentsInitial());
      },
      (document) {
        emit(GetMemberDocumentSuccess(document: document));
        emit(MemberDocumentsInitial());
      },
    );
  }

  Future<void> _onSaveMemberDocument(
    SaveMemberDocumentEvent event,
    Emitter<MemberDocumentsState> emit,
  ) async {
    emit(SaveMemberDocumentLoading());
    final artistId = await _getCurrentArtistId();
    if (artistId == null) {
      emit(SaveMemberDocumentFailure(error: 'Usuário não autenticado'));
      emit(MemberDocumentsInitial());
      return;
    }
    final documentToSave = event.document.artistId.isEmpty
        ? event.document.copyWith(artistId: artistId)
        : event.document;
    final result = await saveMemberDocumentUseCase.call(
      artistId,
      documentToSave,
      localFilePath: event.localFilePath,
    );
    result.fold(
      (failure) {
        emit(SaveMemberDocumentFailure(error: failure.message));
        emit(MemberDocumentsInitial());
      },
      (_) {
        emit(SaveMemberDocumentSuccess(document: documentToSave));
        emit(MemberDocumentsInitial());
      },
    );
  }

  void _onResetMemberDocuments(
    ResetMemberDocumentsEvent event,
    Emitter<MemberDocumentsState> emit,
  ) {
    emit(MemberDocumentsInitial());
  }
}
