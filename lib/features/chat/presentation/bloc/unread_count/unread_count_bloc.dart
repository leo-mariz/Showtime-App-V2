import 'dart:async';

import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/chat/domain/usecases/get_unread_count_usecase.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/events/unread_count_events.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/states/unread_count_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar contador de mensagens não lidas
/// 
/// RESPONSABILIDADES:
/// - Gerenciar stream otimizado de contador total (apenas campo totalUnread)
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas ao UseCase
/// 
/// OTIMIZAÇÃO:
/// Este BLoC usa getUnreadCountStream que escuta apenas o campo totalUnread
/// do documento user_chats/{userId}, sem precisar buscar todos os chats completos.
/// Isso reduz drasticamente os custos de leitura do Firestore.
class UnreadCountBloc extends Bloc<UnreadCountEvent, UnreadCountState> {
  final GetUserUidUseCase getUserUidUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;

  // Stream subscription para gerenciar lifecycle
  StreamSubscription<int>? _unreadCountSubscription;

  UnreadCountBloc({
    required this.getUserUidUseCase,
    required this.getUnreadCountUseCase,
  }) : super(UnreadCountInitial()) {
    on<LoadUnreadCountEvent>(_onLoadUnreadCountEvent);
    on<UnreadCountUpdatedEvent>(_onUnreadCountUpdatedEvent);
    on<ResetUnreadCountEvent>(_onResetUnreadCountEvent);
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

  // ==================== LOAD UNREAD COUNT ====================

  /// Carrega contador de mensagens não lidas e inicia stream em tempo real
  /// 
  /// Este stream é muito eficiente: escuta apenas o campo totalUnread
  /// do documento user_chats/{userId}, sem buscar chats completos
  Future<void> _onLoadUnreadCountEvent(
    LoadUnreadCountEvent event,
    Emitter<UnreadCountState> emit,
  ) async {
    emit(UnreadCountLoading());

    try {
      // Obter userId do usuário atual
      final userId = await _getCurrentUserId();

      if (userId == null || userId.isEmpty) {
        emit(UnreadCountFailure(error: 'Usuário não autenticado'));
        emit(UnreadCountInitial());
        return;
      }

      // Cancelar subscription anterior se existir
      await _unreadCountSubscription?.cancel();

      // Criar nova subscription ao stream otimizado de contador
      // Este stream escuta apenas o campo totalUnread do documento user_chats/{userId}
      // Muito mais eficiente que buscar todos os chats completos
      _unreadCountSubscription = getUnreadCountUseCase.call(userId: userId).listen(
        (count) {
          // Disparar evento interno quando stream atualizar
          add(UnreadCountUpdatedEvent(count: count));
        },
        onError: (error) {
          // Emitir erro se stream falhar
          add(UnreadCountUpdatedEvent(count: 0));
        },
      );
    } catch (e) {
      emit(UnreadCountFailure(error: 'Erro ao carregar contador: $e'));
      emit(UnreadCountInitial());
    }
  }

  /// Atualiza estado quando stream de contador emite novos dados
  void _onUnreadCountUpdatedEvent(
    UnreadCountUpdatedEvent event,
    Emitter<UnreadCountState> emit,
  ) {
    emit(UnreadCountSuccess(count: event.count));
  }

  // ==================== RESET ====================

  /// Reseta o BLoC ao estado inicial
  /// 
  /// Cancela subscriptions e emite estado inicial
  Future<void> _onResetUnreadCountEvent(
    ResetUnreadCountEvent event,
    Emitter<UnreadCountState> emit,
  ) async {
    // Cancelar subscription de contador
    await _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;

    // Emitir estado inicial
    emit(UnreadCountInitial());
  }

  // ==================== CLEANUP ====================

  @override
  Future<void> close() {
    // IMPORTANTE: Cancelar subscription ao fechar bloc
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
