import 'dart:async';

import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:app/features/chat/domain/usecases/create_chat_usecase.dart';
import 'package:app/features/chat/presentation/bloc/chats_list/events/chats_list_events.dart';
import 'package:app/features/chat/presentation/bloc/chats_list/states/chats_list_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da lista de chats
/// 
/// RESPONSABILIDADES:
/// - Gerenciar stream de chats em tempo real
/// - Criar novos chats
/// - Emitir estados de loading, success e failure
/// - Orquestrar chamadas aos UseCases e Repository
class ChatsListBloc extends Bloc<ChatsListEvent, ChatsListState> {
  final GetUserUidUseCase getUserUidUseCase;
  final CreateChatUseCase createChatUseCase;
  final IChatRepository chatRepository;

  // Stream subscription para gerenciar lifecycle
  StreamSubscription? _chatsSubscription;

  ChatsListBloc({
    required this.getUserUidUseCase,
    required this.createChatUseCase,
    required this.chatRepository,
  }) : super(ChatsListInitial()) {
    on<LoadChatsEvent>(_onLoadChatsEvent);
    on<ChatsUpdatedEvent>(_onChatsUpdatedEvent);
    on<RefreshChatsEvent>(_onRefreshChatsEvent);
    on<CreateChatEvent>(_onCreateChatEvent);
    on<ResetChatsListEvent>(_onResetChatsListEvent);
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

  // ==================== LOAD CHATS ====================

  /// Carrega lista de chats e inicia stream em tempo real
  Future<void> _onLoadChatsEvent(
    LoadChatsEvent event,
    Emitter<ChatsListState> emit,
  ) async {
    emit(ChatsListLoading());

    try {
      // Obter userId do usuário atual
      final userId = await _getCurrentUserId();

      if (userId == null || userId.isEmpty) {
        emit(ChatsListFailure(error: 'Usuário não autenticado'));
        emit(ChatsListInitial());
        return;
      }

      // Cancelar subscription anterior se existir
      await _chatsSubscription?.cancel();

      // Criar nova subscription ao stream de chats
      _chatsSubscription = chatRepository.getUserChatsStream(userId).listen(
        (chats) {
          // Disparar evento interno quando stream atualizar
          add(ChatsUpdatedEvent(chats: chats));
        },
        onError: (error) {
          // Emitir erro se stream falhar
          add(ChatsUpdatedEvent(chats: []));
        },
      );
    } catch (e) {
      emit(ChatsListFailure(error: 'Erro ao carregar chats: $e'));
      emit(ChatsListInitial());
    }
  }

  /// Atualiza estado quando stream de chats emite novos dados
  void _onChatsUpdatedEvent(
    ChatsUpdatedEvent event,
    Emitter<ChatsListState> emit,
  ) {
    emit(ChatsListSuccess(chats: event.chats));
  }

  /// Força refresh da lista de chats
  Future<void> _onRefreshChatsEvent(
    RefreshChatsEvent event,
    Emitter<ChatsListState> emit,
  ) async {
    // Recarregar chats
    add(LoadChatsEvent());
  }

  // ==================== CREATE CHAT ====================

  /// Cria um novo chat
  Future<void> _onCreateChatEvent(
    CreateChatEvent event,
    Emitter<ChatsListState> emit,
  ) async {
    emit(CreateChatLoading());

    // Criar chat passando DTO do event para o UseCase
    final result = await createChatUseCase.call(event.input);

    result.fold(
      (failure) {
        emit(CreateChatFailure(error: failure.message));
        emit(ChatsListInitial());
      },
      (chat) {
        emit(CreateChatSuccess(chat: chat));
        // Stream vai atualizar automaticamente com o novo chat
        emit(ChatsListInitial());
      },
    );
  }

  // ==================== RESET ====================

  /// Reseta o BLoC ao estado inicial
  /// 
  /// Cancela subscriptions e emite estado inicial
  Future<void> _onResetChatsListEvent(
    ResetChatsListEvent event,
    Emitter<ChatsListState> emit,
  ) async {
    // Cancelar subscription de chats
    await _chatsSubscription?.cancel();
    _chatsSubscription = null;

    // Emitir estado inicial
    emit(ChatsListInitial());
  }

  // ==================== CLEANUP ====================

  @override
  Future<void> close() {
    // IMPORTANTE: Cancelar subscription ao fechar bloc
    _chatsSubscription?.cancel();
    return super.close();
  }
}
