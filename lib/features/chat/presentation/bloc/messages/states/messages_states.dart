import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MessagesInitial extends MessagesState {}

// ==================== LOAD MESSAGES STATES ====================

/// Estado de carregamento inicial de mensagens
class MessagesLoading extends MessagesState {}

/// Estado de sucesso com lista de mensagens
class MessagesSuccess extends MessagesState {
  final List<MessageEntity> messages;
  final bool hasMore;
  final bool isLoadingMore;

  MessagesSuccess({
    required this.messages,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [messages, hasMore, isLoadingMore];

  /// Cria cópia do estado com valores atualizados
  MessagesSuccess copyWith({
    List<MessageEntity>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MessagesSuccess(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Estado de erro ao carregar mensagens
class MessagesFailure extends MessagesState {
  final String error;

  MessagesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SEND MESSAGE STATES ====================

/// Estado de carregamento ao enviar mensagem
class SendMessageLoading extends MessagesState {}

/// Estado de sucesso ao enviar mensagem
class SendMessageSuccess extends MessagesState {}

/// Estado de erro ao enviar mensagem
class SendMessageFailure extends MessagesState {
  final String error;

  SendMessageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== MARK AS READ STATES ====================

/// Estado de sucesso ao marcar mensagens como lidas
class MarkAsReadSuccess extends MessagesState {}

/// Estado de erro ao marcar mensagens como lidas
class MarkAsReadFailure extends MessagesState {
  final String error;

  MarkAsReadFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== TYPING STATUS STATES ====================

/// Estado de sucesso ao atualizar status de digitação
class TypingStatusUpdated extends MessagesState {
  final bool isTyping;

  TypingStatusUpdated({required this.isTyping});

  @override
  List<Object?> get props => [isTyping];
}
