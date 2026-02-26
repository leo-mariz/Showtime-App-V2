import 'dart:async';

import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/contracts/domain/entities/user_contracts_index_entity.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/events/pending_contracts_count_events.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/states/pending_contracts_count_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar contador de contratos pendentes por tab
/// 
/// RESPONSABILIDADES:
/// - Gerenciar stream otimizado do índice user_contracts_index/{userId}
/// - Rastrear última visualização de cada tab
/// - Calcular contadores de "não vistos" por tab
/// - Marcar tabs como vistas
/// 
/// OTIMIZAÇÃO:
/// Este BLoC usa um stream que escuta apenas o documento de índice,
/// não todos os contratos. Isso reduz drasticamente os custos de leitura.
/// O índice é atualizado via Cloud Function quando status muda.
class PendingContractsCountBloc extends Bloc<PendingContractsCountEvent, PendingContractsCountState> {
  final GetUserUidUseCase getUserUidUseCase;
  final IContractRepository contractRepository;

  // Stream subscription para gerenciar lifecycle
  StreamSubscription<UserContractsIndexEntity>? _indexSubscription;
  
  // Armazenar o role atual para filtrar os contadores
  bool _currentIsArtist = false;

  PendingContractsCountBloc({
    required this.getUserUidUseCase,
    required this.contractRepository,
  }) : super(PendingContractsCountInitial()) {
    on<LoadPendingContractsCountEvent>(_onLoadPendingContractsCountEvent);
    on<PendingContractsCountUpdatedEvent>(_onPendingContractsCountUpdatedEvent);
    on<MarkTabAsSeenEvent>(_onMarkTabAsSeenEvent);
    on<ResetPendingContractsCountEvent>(_onResetPendingContractsCountEvent);
  }

  // ==================== HELPERS ====================

  /// Obtém o UID do usuário atual
  Future<String?> _getCurrentUserId() async {
    final result = await getUserUidUseCase.call();
    return result.fold(
      (_) => null,
      (uid) => uid,
    );
  }

  // ==================== LOAD PENDING CONTRACTS COUNT ====================

  /// Carrega contador de contratos pendentes e inicia stream em tempo real
  /// 
  /// Este stream é muito eficiente: escuta apenas o documento de índice
  /// user_contracts_index/{userId}, não todos os contratos
  Future<void> _onLoadPendingContractsCountEvent(
    LoadPendingContractsCountEvent event,
    Emitter<PendingContractsCountState> emit,
  ) async {
    emit(PendingContractsCountLoading());

    try {
      // Obter userId do usuário atual
      final userId = await _getCurrentUserId();

      if (userId == null || userId.isEmpty) {
        emit(PendingContractsCountFailure(error: 'Usuário não autenticado'));
        emit(PendingContractsCountInitial());
        return;
      }

      // Cancelar subscription anterior se existir
      await _indexSubscription?.cancel();

      // Armazenar o role atual
      _currentIsArtist = event.isArtist;

      // Criar subscription ao stream otimizado do índice
      // O stream do Firestore SEMPRE emite o valor atual quando você se inscreve
      // Este stream escuta apenas o documento user_contracts_index/{userId}
      // Muito mais eficiente que buscar todos os contratos
      _indexSubscription = contractRepository.getContractsIndexStream(userId).listen(
        (indexEntity) {
          // Disparar evento interno quando stream atualizar (com role atual)
          // O stream do Firestore emite o valor atual imediatamente, então o primeiro valor
          // será processado rapidamente através do evento
          add(PendingContractsCountUpdatedEvent(
            indexEntity: indexEntity,
            isArtist: _currentIsArtist,
          ));
        },
        onError: (error) {
          // Emitir erro se stream falhar - usar entidade vazia
          add(PendingContractsCountUpdatedEvent(
            indexEntity: UserContractsIndexEntity(),
            isArtist: _currentIsArtist,
          ));
        },
      );
    } catch (e) {
      emit(PendingContractsCountFailure(error: 'Erro ao carregar contador: $e'));
      emit(PendingContractsCountInitial());
    }
  }

  /// Emite estado baseado no índice (método auxiliar reutilizável)
  void _emitStateFromIndex(
    UserContractsIndexEntity indexEntity,
    bool isArtist,
    Emitter<PendingContractsCountState> emit,
  ) {
    // Usar métodos da entidade que filtram por role
    final tab0Unseen = indexEntity.getUnseenForTab(0, isArtist);
    final tab1Unseen = indexEntity.getUnseenForTab(1, isArtist);
    final tab2Unseen = indexEntity.getUnseenForTab(2, isArtist);
    
    emit(PendingContractsCountSuccess(
      tab0Unseen: tab0Unseen,
      tab1Unseen: tab1Unseen,
      tab2Unseen: tab2Unseen,
      tab0Total: indexEntity.getTotalForTab(0, isArtist),
      tab1Total: indexEntity.getTotalForTab(1, isArtist),
      tab2Total: indexEntity.getTotalForTab(2, isArtist),
    ));
  }

  /// Atualiza estado quando stream do índice emite novos dados
  void _onPendingContractsCountUpdatedEvent(
    PendingContractsCountUpdatedEvent event,
    Emitter<PendingContractsCountState> emit,
  ) {
    _emitStateFromIndex(event.indexEntity, event.isArtist, emit);
  }

  /// Marca uma tab como vista
  /// 
  /// Atualiza o timestamp de última visualização da tab especificada
  Future<void> _onMarkTabAsSeenEvent(
    MarkTabAsSeenEvent event,
    Emitter<PendingContractsCountState> emit,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) return;

      // Marcar tab como vista no Firestore (com role específico)
      final result = await contractRepository.markTabAsSeen(
        userId, 
        event.tabIndex,
        isArtist: event.isArtist,
      );
      
      result.fold(
        (_) {
          // Erro ao marcar como visto - não fazer nada
        },
        (_) {
          // Sucesso - atualizar estado local para refletir que não há mais contratos "novos" nessa tab
          final currentState = state;
          if (currentState is PendingContractsCountSuccess) {
            // Atualizar contador da tab marcada como vista para 0
            final updatedState = PendingContractsCountSuccess(
              tab0Unseen: event.tabIndex == 0 ? 0 : currentState.tab0Unseen,
              tab1Unseen: event.tabIndex == 1 ? 0 : currentState.tab1Unseen,
              tab2Unseen: event.tabIndex == 2 ? 0 : currentState.tab2Unseen,
              tab0Total: currentState.tab0Total,
              tab1Total: currentState.tab1Total,
              tab2Total: currentState.tab2Total,
            );
            emit(updatedState);
          }
        },
      );
    } catch (e) {
      // Ignorar erro silenciosamente
    }
  }

  // ==================== RESET ====================

  /// Reseta o BLoC ao estado inicial
  /// 
  /// Cancela subscriptions e emite estado inicial
  Future<void> _onResetPendingContractsCountEvent(
    ResetPendingContractsCountEvent event,
    Emitter<PendingContractsCountState> emit,
  ) async {
    // Cancelar subscription do índice
    await _indexSubscription?.cancel();
    _indexSubscription = null;

    // Emitir estado inicial
    emit(PendingContractsCountInitial());
  }

  // ==================== CLEANUP ====================

  @override
  Future<void> close() {
    // IMPORTANTE: Cancelar subscription ao fechar bloc
    _indexSubscription?.cancel();
    return super.close();
  }
}
