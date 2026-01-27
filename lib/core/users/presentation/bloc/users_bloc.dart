import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/core/users/domain/usecases/check_cpf_exists_usecase.dart';
import 'package:app/core/users/domain/usecases/check_cnpj_exists_usecase.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUserDataUseCase getUserDataUseCase;
  final GetUserUidUseCase getUserUidUseCase;
  final CheckCpfExistsUseCase checkCpfExistsUseCase;
  final CheckCnpjExistsUseCase checkCnpjExistsUseCase;

  UsersBloc({
    required this.getUserDataUseCase,
    required this.getUserUidUseCase,
    required this.checkCpfExistsUseCase,
    required this.checkCnpjExistsUseCase,

  }) : super(UsersInitial()) {
    on<GetUserDataEvent>(_onGetUserDataEvent);
    on<CheckCpfExistsEvent>(_onCheckCpfExistsEvent);
    on<CheckCnpjExistsEvent>(_onCheckCnpjExistsEvent);
    on<ResetUsersEvent>(_onResetUsersEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET USER DATA ====================

  Future<void> _onGetUserDataEvent(
    GetUserDataEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(GetUserDataLoading());

    final uid = await _getCurrentUserId();

    if (uid == null) {
      emit(GetUserDataFailure(error: 'Usuário não autenticado'));
      emit(UsersInitial());
      return;
    }

    final result = await getUserDataUseCase.call(uid);

    result.fold(
      (failure) {
        emit(GetUserDataFailure(error: failure.message));
        emit(UsersInitial());
      },
      (user) {
        print('🟢 [UsersBloc] Usuário carregado: ${user.uid}');
        emit(GetUserDataSuccess(user: user));
      },
    );
  }

  // ==================== CHECK CPF EXISTS ====================

  Future<void> _onCheckCpfExistsEvent(
    CheckCpfExistsEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(DocumentValidationLoading(document: event.cpf));
    
    final result = await checkCpfExistsUseCase.call(event.cpf);
    
    result.fold(
      (failure) {
        emit(DocumentValidationFailure(
          document: event.cpf,
          error: failure.message,
        ));
        emit(UsersInitial());
      },
      (exists) {
        emit(DocumentValidationSuccess(
          document: event.cpf,
          exists: exists,
        ));
        emit(UsersInitial());
      },
    );
  }

  // ==================== CHECK CNPJ EXISTS ====================

  Future<void> _onCheckCnpjExistsEvent(
    CheckCnpjExistsEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(DocumentValidationLoading(document: event.cnpj));
    
    final result = await checkCnpjExistsUseCase.call(event.cnpj);
    
    result.fold(
      (failure) {
        emit(DocumentValidationFailure(
          document: event.cnpj,
          error: failure.message,
        ));
        emit(UsersInitial());
      },
      (exists) {
        emit(DocumentValidationSuccess(
          document: event.cnpj,
          exists: exists,
        ));
        emit(UsersInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetUsersEvent(
    ResetUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersInitial());
  }
}

