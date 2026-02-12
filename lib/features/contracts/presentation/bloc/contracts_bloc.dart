import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/contracts/domain/usecases/accept_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/add_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/cancel_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/confirm_show_usecase.dart';
import 'package:app/features/contracts/domain/usecases/delete_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/rate_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/rate_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/skip_rating_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/skip_rating_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_group_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_for_artist_including_ensembles_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_ids_by_owner_usecase.dart';
import 'package:app/features/contracts/domain/usecases/make_payment_usecase.dart';
import 'package:app/features/contracts/domain/usecases/reject_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/verify_payment_usecase.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Contracts
/// 
/// RESPONSABILIDADES:
/// - Gerenciar operações CRUD de contratos
/// - Gerenciar busca de contratos por cliente, artista ou grupo
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas aos UseCases
class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
  final GetUserUidUseCase getUserUidUseCase;
  final GetContractUseCase getContractUseCase;
  final GetContractsByClientUseCase getContractsByClientUseCase;
  final GetContractsByArtistUseCase getContractsByArtistUseCase;
  final GetContractsByGroupUseCase getContractsByGroupUseCase;
  final GetContractsForArtistIncludingEnsemblesUseCase getContractsForArtistIncludingEnsemblesUseCase;
  final GetEnsembleIdsByOwnerUseCase getEnsembleIdsByOwnerUseCase;
  final AddContractUseCase addContractUseCase;
  final UpdateContractUseCase updateContractUseCase;
  final DeleteContractUseCase deleteContractUseCase;
  final AcceptContractUseCase acceptContractUseCase;
  final RejectContractUseCase rejectContractUseCase;
  final MakePaymentUseCase makePaymentUseCase;
  final CancelContractUseCase cancelContractUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final ConfirmShowUseCase confirmShowUseCase;
  final RateArtistUseCase rateArtistUseCase;
  final SkipRatingArtistUseCase skipRatingArtistUseCase;
  final SkipRatingClientUseCase skipRatingClientUseCase;
  final RateClientUseCase rateClientUseCase;

  ContractsBloc({
    required this.getUserUidUseCase,
    required this.getContractUseCase,
    required this.getContractsByClientUseCase,
    required this.getContractsByArtistUseCase,
    required this.getContractsByGroupUseCase,
    required this.getContractsForArtistIncludingEnsemblesUseCase,
    required this.getEnsembleIdsByOwnerUseCase,
    required this.addContractUseCase,
    required this.updateContractUseCase,
    required this.deleteContractUseCase,
    required this.acceptContractUseCase,
    required this.rejectContractUseCase,
    required this.makePaymentUseCase,
    required this.cancelContractUseCase,
    required this.verifyPaymentUseCase,
    required this.confirmShowUseCase,
    required this.rateArtistUseCase,
    required this.skipRatingArtistUseCase,
    required this.skipRatingClientUseCase,
    required this.rateClientUseCase,
  }) : super(ContractsInitial()) {
    on<GetContractEvent>(_onGetContractEvent);
    on<GetContractsByClientEvent>(_onGetContractsByClientEvent);
    on<GetContractsByArtistEvent>(_onGetContractsByArtistEvent);
    on<GetContractsByGroupEvent>(_onGetContractsByGroupEvent);
    on<AddContractEvent>(_onAddContractEvent);
    on<UpdateContractEvent>(_onUpdateContractEvent);
    on<DeleteContractEvent>(_onDeleteContractEvent);
    on<AcceptContractEvent>(_onAcceptContractEvent);
    on<RejectContractEvent>(_onRejectContractEvent);
    on<MakePaymentEvent>(_onMakePaymentEvent);
    on<CancelContractEvent>(_onCancelContractEvent);
    on<VerifyPaymentEvent>(_onVerifyPaymentEvent);
    on<ConfirmShowEvent>(_onConfirmShowEvent);
    on<RateArtistEvent>(_onRateArtistEvent);
    on<SkipRatingArtistEvent>(_onSkipRatingArtistEvent);
    on<SkipRatingClientEvent>(_onSkipRatingClientEvent);
    on<RateClientEvent>(_onRateClientEvent);
    on<ResetContractsEvent>(_onResetContractsEvent);
  }

  // ==================== HELPERS ====================

  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== GET CONTRACT ====================

  Future<void> _onGetContractEvent(
    GetContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(GetContractLoading());

    final result = await getContractUseCase.call(event.contractUid);

    result.fold(
      (failure) {
        emit(GetContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (contract) {
        emit(GetContractSuccess(contract: contract));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== GET CONTRACTS BY CLIENT ====================

  Future<void> _onGetContractsByClientEvent(
    GetContractsByClientEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(GetContractsByClientLoading());

    final uid = await _getCurrentUserId();

    final result = await getContractsByClientUseCase.call(uid!, forceRefresh: event.forceRefresh ?? false);

    result.fold(
      (failure) {
        emit(GetContractsByClientFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (contracts) {
        emit(GetContractsByClientSuccess(contracts: contracts));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== GET CONTRACTS BY ARTIST ====================

  Future<void> _onGetContractsByArtistEvent(
    GetContractsByArtistEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(GetContractsByArtistLoading());

    final uid = await _getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      emit(GetContractsByArtistFailure(error: 'Usuário não identificado'));
      emit(ContractsInitial());
      return;
    }

    final ensembleIdsResult = await getEnsembleIdsByOwnerUseCase.call(
      uid,
      forceRemote: event.forceRefresh ?? false,
    );
    final ensembleIds = ensembleIdsResult.fold(
      (_) => <String>[],
      (ids) => ids,
    );

    final result = await getContractsForArtistIncludingEnsemblesUseCase.call(
      uid,
      ensembleIds: ensembleIds,
      forceRefresh: event.forceRefresh ?? false,
    );

    result.fold(
      (failure) {
        emit(GetContractsByArtistFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (contracts) {
        emit(GetContractsByArtistSuccess(contracts: contracts));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== GET CONTRACTS BY GROUP ====================

  Future<void> _onGetContractsByGroupEvent(
    GetContractsByGroupEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(GetContractsByGroupLoading());

    final result = await getContractsByGroupUseCase.call(event.groupUid);

    result.fold(
      (failure) {
        emit(GetContractsByGroupFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (contracts) {
        emit(GetContractsByGroupSuccess(contracts: contracts));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== ADD CONTRACT ====================

  Future<void> _onAddContractEvent(
    AddContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(AddContractLoading());

    final result = await addContractUseCase.call(event.contract);

    result.fold(
      (failure) {
        emit(AddContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (contractUid) {
        emit(AddContractSuccess(
          contractUid: contractUid,
          contract: event.contract.copyWith(uid: contractUid),
        ));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== UPDATE CONTRACT ====================

  Future<void> _onUpdateContractEvent(
    UpdateContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(UpdateContractLoading());

    final result = await updateContractUseCase.call(event.contract);

    result.fold(
      (failure) {
        emit(UpdateContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(UpdateContractSuccess(contract: event.contract));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== DELETE CONTRACT ====================

  Future<void> _onDeleteContractEvent(
    DeleteContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(DeleteContractLoading());

    final result = await deleteContractUseCase.call(event.contractUid);

    result.fold(
      (failure) {
        emit(DeleteContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(DeleteContractSuccess(contractUid: event.contractUid));
        emit(ContractsInitial());
      },
    );
  }

  // ==================== ACCEPT CONTRACT ====================

  Future<void> _onAcceptContractEvent(
    AcceptContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(AcceptContractLoading());

    final result = await acceptContractUseCase.call(contractUid: event.contractUid);

    result.fold(
      (failure) {
        emit(AcceptContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(AcceptContractSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== REJECT CONTRACT ====================

  Future<void> _onRejectContractEvent(
    RejectContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(RejectContractLoading());

    final result = await rejectContractUseCase.call(contractUid: event.contractUid);

    result.fold(
      (failure) {
        emit(RejectContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(RejectContractSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== MAKE PAYMENT ====================

  Future<void> _onMakePaymentEvent(
    MakePaymentEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(MakePaymentLoading());

    final result = await makePaymentUseCase.call(linkPayment: event.linkPayment, contractUid: event.contractUid);

    result.fold(
      (failure) {
        emit(MakePaymentFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(MakePaymentSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== CANCEL CONTRACT ====================

  Future<void> _onCancelContractEvent(
    CancelContractEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(CancelContractLoading());

    final result = await cancelContractUseCase.call(
      contractUid: event.contractUid,
      canceledBy: event.canceledBy,
      cancelReason: event.cancelReason,
    );

    result.fold(
      (failure) {
        emit(CancelContractFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(CancelContractSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== VERIFY PAYMENT ====================

  Future<void> _onVerifyPaymentEvent(
    VerifyPaymentEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(VerifyPaymentLoading());

    final result = await verifyPaymentUseCase.call(event.contractUid);

    result.fold(
      (failure) {
        emit(VerifyPaymentFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(VerifyPaymentSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== CONFIRM SHOW ====================

  Future<void> _onConfirmShowEvent(
    ConfirmShowEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(ConfirmShowLoading());

    final result = await confirmShowUseCase.call(
      contractUid: event.contractUid,
      confirmationCode: event.confirmationCode,
    );

    result.fold(
      (failure) {
        emit(ConfirmShowFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(ConfirmShowSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== RATE ARTIST ====================

  Future<void> _onRateArtistEvent(
    RateArtistEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(RateArtistLoading());

    final result = await rateArtistUseCase.call(
      contractUid: event.contractUid,
      rating: event.rating,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        emit(RateArtistFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(RateArtistSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== SKIP RATING ARTIST ====================

  Future<void> _onSkipRatingArtistEvent(
    SkipRatingArtistEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(SkipRatingArtistLoading());

    final result = await skipRatingArtistUseCase.call(
      contractUid: event.contractUid,
    );

    result.fold(
      (failure) {
        emit(SkipRatingArtistFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(SkipRatingArtistSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== SKIP RATING CLIENT ====================

  Future<void> _onSkipRatingClientEvent(
    SkipRatingClientEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(SkipRatingClientLoading());

    final result = await skipRatingClientUseCase.call(
      contractUid: event.contractUid,
    );

    result.fold(
      (failure) {
        emit(SkipRatingClientFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(SkipRatingClientSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== RATE CLIENT ====================

  Future<void> _onRateClientEvent(
    RateClientEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(RateClientLoading());

    final result = await rateClientUseCase.call(
      contractUid: event.contractUid,
      rating: event.rating,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        emit(RateClientFailure(error: failure.message));
        emit(ContractsInitial());
      },
      (_) {
        emit(RateClientSuccess());
        emit(ContractsInitial());
      },
    );
  }

  // ==================== RESET ====================

  Future<void> _onResetContractsEvent(
    ResetContractsEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(ContractsInitial());
  }
}

