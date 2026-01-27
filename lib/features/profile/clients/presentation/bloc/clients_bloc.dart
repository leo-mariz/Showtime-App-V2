import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/clients/domain/usecases/add_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_preferences_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_profile_picture_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_agreement_usecase.dart';
import 'package:app/features/profile/clients/presentation/bloc/events/clients_events.dart';
import 'package:app/features/profile/clients/presentation/bloc/states/clients_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final GetClientUseCase getClientUseCase;
  final AddClientUseCase addClientUseCase;
  final UpdateClientUseCase updateClientUseCase;
  final UpdateClientPreferencesUseCase updateClientPreferencesUseCase;
  final UpdateClientProfilePictureUseCase updateClientProfilePictureUseCase;
  final UpdateClientAgreementUseCase updateClientAgreementUseCase;
  final GetUserUidUseCase getUserUidUseCase;
  
  ClientsBloc({
    required this.getClientUseCase,
    required this.addClientUseCase,
    required this.updateClientUseCase,
    required this.updateClientPreferencesUseCase,
    required this.updateClientProfilePictureUseCase,
    required this.updateClientAgreementUseCase,
    required this.getUserUidUseCase,
  }) : super(ClientsInitial()) {
    on<GetClientEvent>(_onGetClientEvent);
    on<AddClientEvent>(_onAddClientEvent);
    on<UpdateClientEvent>(_onUpdateClientEvent);
    on<UpdateClientPreferencesEvent>(_onUpdateClientPreferencesEvent);
    on<UpdateClientProfilePictureEvent>(_onUpdateClientProfilePictureEvent);
    on<UpdateClientAgreementEvent>(_onUpdateClientAgreementEvent);
    on<ResetClientsEvent>(_onResetClientsEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET CLIENT ====================

  Future<void> _onGetClientEvent(
    GetClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(GetClientLoading());

    final uid = await _getCurrentUserId();

    if (uid == null) {
      emit(GetClientFailure(error: 'Usuário não autenticado'));
      emit(ClientsInitial());
      return;
    }

    final result = await getClientUseCase.call(uid);

    result.fold(
      (failure) {
        emit(GetClientFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (client) {
        emit(GetClientSuccess(client: client));
      },
    );
  }

  // ==================== ADD CLIENT ====================

  Future<void> _onAddClientEvent(
    AddClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(AddClientLoading());

    final uid = await _getCurrentUserId();

    final result = await addClientUseCase.call(uid!);

    result.fold(
      (failure) {
        emit(AddClientFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (_) {
        emit(AddClientSuccess());
        emit(ClientsInitial());
      },
    );
  }

  // ==================== UPDATE CLIENT ====================

  Future<void> _onUpdateClientEvent(
    UpdateClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(UpdateClientLoading());

    final uid = await _getCurrentUserId();

    final result = await updateClientUseCase.call(uid!, event.client);

    result.fold(
      (failure) {
        emit(UpdateClientFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (_) {
        emit(UpdateClientSuccess());
        emit(ClientsInitial());
      },
    );
  }

  // ==================== UPDATE CLIENT PREFERENCES ====================

  Future<void> _onUpdateClientPreferencesEvent(
    UpdateClientPreferencesEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(UpdateClientPreferencesLoading());

    final uid = await _getCurrentUserId();

    final result = await updateClientPreferencesUseCase.call(
      uid!,
      event.preferences,
    );

    result.fold(
      (failure) {
        emit(UpdateClientPreferencesFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (_) {
        emit(UpdateClientPreferencesSuccess());
        emit(ClientsInitial());
      },
    );
  }

  // ==================== UPDATE CLIENT PROFILE PICTURE ====================

  Future<void> _onUpdateClientProfilePictureEvent(
    UpdateClientProfilePictureEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(UpdateClientProfilePictureLoading());

    final uid = await _getCurrentUserId();

    final result = await updateClientProfilePictureUseCase.call(
      uid!,
      event.localFilePath,
    );

    result.fold(
      (failure) {
        emit(UpdateClientProfilePictureFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (_) {
        emit(UpdateClientProfilePictureSuccess());
        emit(ClientsInitial());
      },
    );
  }

  // ==================== UPDATE CLIENT AGREEMENT ====================

  Future<void> _onUpdateClientAgreementEvent(
    UpdateClientAgreementEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(UpdateClientAgreementLoading());

    final uid = await _getCurrentUserId();

    final result = await updateClientAgreementUseCase.call(
      uid!,
      event.agreedToTerms,
    );

    result.fold(
      (failure) {
        emit(UpdateClientAgreementFailure(error: failure.message));
        emit(ClientsInitial());
      },
      (_) {
        emit(UpdateClientAgreementSuccess());
        emit(ClientsInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetClientsEvent(
    ResetClientsEvent event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsInitial());
  }
}

