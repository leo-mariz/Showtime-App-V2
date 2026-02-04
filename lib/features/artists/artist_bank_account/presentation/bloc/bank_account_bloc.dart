import 'package:app/features/artists/artist_bank_account/domain/usecases/delete_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/get_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/save_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/presentation/bloc/events/bank_account_events.dart';
import 'package:app/features/artists/artist_bank_account/presentation/bloc/states/bank_account_states.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankAccountBloc extends Bloc<BankAccountEvent, BankAccountState> {
  final GetBankAccountUseCase getBankAccountUseCase;
  final SaveBankAccountUseCase saveBankAccountUseCase;
  final DeleteBankAccountUseCase deleteBankAccountUseCase;
  final GetUserUidUseCase getUserUidUseCase;

  BankAccountBloc({
    required this.getBankAccountUseCase,
    required this.saveBankAccountUseCase,
    required this.deleteBankAccountUseCase,
    required this.getUserUidUseCase,
  }) : super(BankAccountInitial()) {
    on<GetBankAccountEvent>(_onGetBankAccountEvent);
    on<SaveBankAccountEvent>(_onSaveBankAccountEvent);
    on<DeleteBankAccountEvent>(_onDeleteBankAccountEvent);
    on<ResetBankAccountEvent>(_onResetBankAccountEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET BANK ACCOUNT ====================

  Future<void> _onGetBankAccountEvent(
    GetBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(GetBankAccountLoading());

    final uid = await _getCurrentUserId();

    if (uid == null || uid.isEmpty) {
      emit(GetBankAccountFailure(error: 'Usuário não autenticado'));
      emit(BankAccountInitial());
      return;
    }

    final result = await getBankAccountUseCase.call(uid);

    result.fold(
      (failure) {
        emit(GetBankAccountFailure(error: failure.message));
        emit(BankAccountInitial());
      },
      (bankAccount) {
        emit(GetBankAccountSuccess(bankAccount: bankAccount));
      },
    );
  }

  // ==================== SAVE BANK ACCOUNT ====================

  Future<void> _onSaveBankAccountEvent(
    SaveBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(SaveBankAccountLoading());

    final uid = await _getCurrentUserId();

    if (uid == null || uid.isEmpty) {
      emit(SaveBankAccountFailure(error: 'Usuário não autenticado'));
      emit(BankAccountInitial());
      return;
    }

    final result = await saveBankAccountUseCase.call(uid, event.bankAccount);

    result.fold(
      (failure) {
        emit(SaveBankAccountFailure(error: failure.message));
        emit(BankAccountInitial());
      },
      (_) {
        emit(SaveBankAccountSuccess());
        emit(BankAccountInitial());
      },
    );
  }

  // ==================== DELETE BANK ACCOUNT ====================

  Future<void> _onDeleteBankAccountEvent(
    DeleteBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(DeleteBankAccountLoading());

    final uid = await _getCurrentUserId();

    if (uid == null || uid.isEmpty) {
      emit(DeleteBankAccountFailure(error: 'Usuário não autenticado'));
      emit(BankAccountInitial());
      return;
    }

    final result = await deleteBankAccountUseCase.call(uid);

    result.fold(
      (failure) {
        emit(DeleteBankAccountFailure(error: failure.message));
        emit(BankAccountInitial());
      },
      (_) {
        emit(DeleteBankAccountSuccess());
        emit(BankAccountInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetBankAccountEvent(
    ResetBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(BankAccountInitial());
  }
}

