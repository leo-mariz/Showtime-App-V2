import 'package:app/features/contracts/domain/usecases/add_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/delete_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_group_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
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
  final GetContractUseCase getContractUseCase;
  final GetContractsByClientUseCase getContractsByClientUseCase;
  final GetContractsByArtistUseCase getContractsByArtistUseCase;
  final GetContractsByGroupUseCase getContractsByGroupUseCase;
  final AddContractUseCase addContractUseCase;
  final UpdateContractUseCase updateContractUseCase;
  final DeleteContractUseCase deleteContractUseCase;

  ContractsBloc({
    required this.getContractUseCase,
    required this.getContractsByClientUseCase,
    required this.getContractsByArtistUseCase,
    required this.getContractsByGroupUseCase,
    required this.addContractUseCase,
    required this.updateContractUseCase,
    required this.deleteContractUseCase,
  }) : super(ContractsInitial()) {
    on<GetContractEvent>(_onGetContractEvent);
    on<GetContractsByClientEvent>(_onGetContractsByClientEvent);
    on<GetContractsByArtistEvent>(_onGetContractsByArtistEvent);
    on<GetContractsByGroupEvent>(_onGetContractsByGroupEvent);
    on<AddContractEvent>(_onAddContractEvent);
    on<UpdateContractEvent>(_onUpdateContractEvent);
    on<DeleteContractEvent>(_onDeleteContractEvent);
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

    final result = await getContractsByClientUseCase.call(event.clientUid);

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

    final result = await getContractsByArtistUseCase.call(event.artistUid);

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
}

