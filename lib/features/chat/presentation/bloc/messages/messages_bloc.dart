import 'dart:async';

import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/usecases/get_messages_paginated_usecase.dart';
import 'package:app/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:app/features/chat/domain/usecases/update_typing_status_usecase.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:app/features/chat/presentation/bloc/messages/events/messages_events.dart';
import 'package:app/features/chat/presentation/bloc/messages/states/messages_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado das mensagens de um chat
/// 
/// RESPONSABILIDADES:
/// - Gerenciar stream de mensagens em tempo real
/// - Enviar mensagens
/// - Carregar mais mensagens (paginação)
/// - Marcar mensagens como lidas
/// - Atualizar status de digitação
/// - Emitir estados de loading, success e failure
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final GetUserUidUseCase getUserUidUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesPaginatedUseCase getMessagesPaginatedUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;
  final UpdateTypingStatusUseCase updateTypingStatusUseCase;
  final IChatRepository chatRepository;

  // Stream subscription para gerenciar lifecycle
  StreamSubscription? _messagesSubscription;

  // Timer para resetar status de digitação
  Timer? _typingTimer;

  MessagesBloc({
    required this.getUserUidUseCase,
    required this.sendMessageUseCase,
    required this.getMessagesPaginatedUseCase,
    required this.markMessagesAsReadUseCase,
    required this.updateTypingStatusUseCase,
    required this.chatRepository,
  }) : super(MessagesInitial()) {
    on<LoadMessagesEvent>(_onLoadMessagesEvent);
    on<MessagesUpdatedEvent>(_onMessagesUpdatedEvent);
    on<MessagesStreamErrorEvent>(_onMessagesStreamErrorEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessagesEvent);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsReadEvent);
    on<UpdateTypingStatusEvent>(_onUpdateTypingStatusEvent);
    on<ResetMessagesEvent>(_onResetMessagesEvent);
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

  // ==================== LOAD MESSAGES ====================

  /// Carrega mensagens de um chat e inicia stream em tempo real
  Future<void> _onLoadMessagesEvent(
    LoadMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    emit(MessagesLoading());

    try {
      // Cancelar subscription anterior se existir
      await _messagesSubscription?.cancel();

      // Criar nova subscription ao stream de mensagens
      // onError não pode chamar emit() aqui: o handler já terá completado quando o stream falhar.
      // Disparamos um evento para que um novo handler emita o estado de falha.
      _messagesSubscription = chatRepository
          .getMessagesStream(chatId: event.chatId, limit: 50)
          .listen(
        (messages) {
          if (!isClosed) add(MessagesUpdatedEvent(messages: messages));
        },
        onError: (error) {
          if (!isClosed) add(MessagesStreamErrorEvent(error: 'Erro ao carregar mensagens: $error'));
        },
      );
    } catch (e) {
      emit(MessagesFailure(error: 'Erro ao carregar mensagens: $e'));
      emit(MessagesInitial());
    }
  }

  /// Trata erro do stream de mensagens (chamado por callback assíncrono via evento)
  void _onMessagesStreamErrorEvent(
    MessagesStreamErrorEvent event,
    Emitter<MessagesState> emit,
  ) {
    emit(MessagesFailure(error: event.error));
    emit(MessagesInitial());
  }

  /// Atualiza estado quando stream de mensagens emite novos dados
  void _onMessagesUpdatedEvent(
    MessagesUpdatedEvent event,
    Emitter<MessagesState> emit,
  ) {
    // As mensagens vêm ordenadas por createdAt DESC (mais recentes primeiro)
    // Inverter para ordem crescente (mais antigas primeiro) para exibição no chat
    final reversedMessages = event.messages.reversed.toList();
    
    // Se houver estado atual com mensagens otimistas, mesclar com as mensagens do stream
    // Isso garante que mensagens otimistas sejam substituídas pelas reais quando chegarem
    final currentState = state is MessagesSuccess ? state as MessagesSuccess : null;
    List<MessageEntity> finalMessages = reversedMessages;
    
    if (currentState != null && currentState.messages.isNotEmpty) {
      // Identificar mensagens otimistas (têm messageId começando com "temp_")
      final optimisticMessages = currentState.messages
          .where((m) => m.messageId.startsWith('temp_'))
          .toList();
      
      // Para cada mensagem otimista, verificar se há uma mensagem real correspondente
      // Uma mensagem real corresponde se tiver mesmo texto, senderId e timestamp próximo (dentro de 10 segundos)
      final realMessageSet = reversedMessages.map((m) => '${m.senderId}_${m.text}').toSet();
      final messagesToKeep = optimisticMessages.where((optimistic) {
        final key = '${optimistic.senderId}_${optimistic.text}';
        // Se não há mensagem real correspondente, manter a otimista
        if (!realMessageSet.contains(key)) return true;
        
        // Se há mensagem real, verificar se o timestamp é próximo (dentro de 10 segundos)
        final correspondingReal = reversedMessages.firstWhere(
          (real) => real.senderId == optimistic.senderId && 
                   real.text == optimistic.text,
          orElse: () => optimistic,
        );
        
        // Se a mensagem real existe e o timestamp é próximo, remover a otimista
        final timeDiff = (correspondingReal.createdAt.difference(optimistic.createdAt)).abs();
        return timeDiff.inSeconds > 10; // Manter apenas se a diferença for maior que 10 segundos
      }).toList();
      
      // Combinar: mensagens otimistas que ainda não chegaram + mensagens reais do stream
      finalMessages = [...messagesToKeep, ...reversedMessages]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    // Assumir que há mais mensagens se retornou o limite completo (50)
    final hasMore = event.messages.length >= 50;

    emit(MessagesSuccess(
      messages: finalMessages,
      hasMore: hasMore,
      isLoadingMore: false,
    ));
  }

  // ==================== SEND MESSAGE ====================

  /// Envia uma mensagem no chat
  Future<void> _onSendMessageEvent(
    SendMessageEvent event,
    Emitter<MessagesState> emit,
  ) async {

    final userId = await _getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      emit(SendMessageFailure(error: 'Usuário não autenticado'));
      return;
    }

    // Manter estado atual se existir
    final currentState = state is MessagesSuccess ? state as MessagesSuccess : null;

    // Criar mensagem otimista para aparecer imediatamente na UI
    // A mensagem otimista será substituída pela real quando o stream atualizar
    final optimisticMessage = MessageEntity(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}_${userId}',
      senderId: userId,
      text: event.input.text,
      createdAt: DateTime.now(),
      status: 'sent',
      type: 'text',
    );

    // Adicionar mensagem otimista ao estado atual imediatamente
    if (currentState != null) {
      final updatedMessages = [...currentState.messages, optimisticMessage]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      emit(currentState.copyWith(messages: updatedMessages));
    }

    // Enviar mensagem passando DTO do event para o UseCase
    final result = await sendMessageUseCase.call(event.input, userId);

    result.fold(
      (failure) {
        // Em caso de erro, remover mensagem otimista e manter estado anterior
        if (currentState != null) {
          emit(currentState);
        } else {
          emit(SendMessageFailure(error: failure.message));
        }
      },
      (_) {
        // Mensagem enviada com sucesso
        // A mensagem otimista já foi adicionada acima
        // O stream vai atualizar automaticamente com a mensagem real do Firestore
        // Quando a mensagem real chegar, ela substituirá a otimista no _onMessagesUpdatedEvent
        if (currentState == null) {
          // Se não havia estado, criar um novo com a mensagem otimista
          emit(MessagesSuccess(
            messages: [optimisticMessage],
            hasMore: false,
            isLoadingMore: false,
          ));
        }
        // Se já havia estado, ele já foi atualizado acima com a mensagem otimista
      },
    );
  }

  // ==================== LOAD MORE MESSAGES (PAGINAÇÃO) ====================

  /// Carrega mais mensagens antigas (scroll infinito)
  Future<void> _onLoadMoreMessagesEvent(
    LoadMoreMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    // Só carregar se o estado atual for MessagesSuccess
    if (state is! MessagesSuccess) return;

    final currentState = state as MessagesSuccess;

    // Não carregar se já estiver carregando ou não houver mais mensagens
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    // Emitir estado de loading more
    emit(currentState.copyWith(isLoadingMore: true));

    // Buscar mais mensagens antigas (antes da data mais antiga atual)
    // A primeira mensagem da lista é a mais antiga (ordem crescente)
    final oldestMessageDate = currentState.messages.isNotEmpty
        ? currentState.messages.first.createdAt
        : event.beforeDate;

    final result = await getMessagesPaginatedUseCase.call(
      chatId: event.chatId,
      limit: 50,
      beforeDate: oldestMessageDate,
    );

    result.fold(
      (failure) {
        // Manter mensagens atuais em caso de erro
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newMessages) {
        // As novas mensagens vêm em ordem DESC (mais recentes primeiro)
        // Inverter para ordem crescente e adicionar no INÍCIO da lista (são mais antigas)
        final reversedNewMessages = newMessages.reversed.toList();
        final allMessages = [...reversedNewMessages, ...currentState.messages];

        // Se retornou menos que o limite, não há mais mensagens
        final hasMore = newMessages.length >= 50;

        emit(MessagesSuccess(
          messages: allMessages,
          hasMore: hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  // ==================== MARK AS READ ====================

  /// Marca mensagens como lidas
  Future<void> _onMarkMessagesAsReadEvent(
    MarkMessagesAsReadEvent event,
    Emitter<MessagesState> emit,
  ) async {
    
    // Manter estado atual se existir
    final currentState = state is MessagesSuccess ? state as MessagesSuccess : null;
    
    // Obter userId do usuário atual
    final userId = await _getCurrentUserId();

    if (userId == null || userId.isEmpty) {
      // Manter estado atual em caso de erro de autenticação
      if (currentState != null) {
        emit(currentState);
      } else {
        emit(MarkAsReadFailure(error: 'Usuário não autenticado'));
      }
      return;
    }

    // Marcar como lidas
    final result = await markMessagesAsReadUseCase.call(
      chatId: event.chatId,
      userId: userId,
    );

    result.fold(
      (failure) {
        // Manter estado atual em caso de erro
        if (currentState != null) {
          emit(currentState);
        } else {
          emit(MarkAsReadFailure(error: failure.message));
        }
      },
      (_) {
          // Manter estado atual para não perder as mensagens
        if (currentState != null) {
          emit(currentState);
        } else {
          emit(MarkAsReadSuccess());
        }
      },
    );
  }

  // ==================== TYPING STATUS ====================

  /// Atualiza status de digitação
  Future<void> _onUpdateTypingStatusEvent(
    UpdateTypingStatusEvent event,
    Emitter<MessagesState> emit,
  ) async {
    // Manter estado atual se existir
    final currentState = state is MessagesSuccess ? state as MessagesSuccess : null;
    
    // Obter userId do usuário atual
    final userId = await _getCurrentUserId();

    if (userId == null || userId.isEmpty) {
      return;
    }

    // Atualizar status
    final result = await updateTypingStatusUseCase.call(
      chatId: event.chatId,
      userId: userId,
      isTyping: event.isTyping,
    );

    result.fold(
      (failure) {
        // Ignorar erro de typing status (não é crítico)
      },
      (_) {
        // Manter estado atual para não perder as mensagens
        if (currentState != null) {
          emit(currentState);
        } else {
          emit(TypingStatusUpdated(isTyping: event.isTyping));
        }

        // Se começou a digitar, agendar reset após 2 segundos
        if (event.isTyping) {
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 2), () {
            add(UpdateTypingStatusEvent(
              chatId: event.chatId,
              isTyping: false,
            ));
          });
        }
      },
    );
  }

  // ==================== RESET ====================

  /// Reseta o BLoC ao estado inicial
  /// 
  /// Cancela subscriptions, timers e emite estado inicial
  Future<void> _onResetMessagesEvent(
    ResetMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    // Cancelar subscription de mensagens
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;

    // Cancelar timer de digitação
    _typingTimer?.cancel();
    _typingTimer = null;

    // Emitir estado inicial
    emit(MessagesInitial());
  }

  // ==================== CLEANUP ====================

  @override
  Future<void> close() {
    // IMPORTANTE: Cancelar subscriptions e timers ao fechar bloc
    _messagesSubscription?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}
