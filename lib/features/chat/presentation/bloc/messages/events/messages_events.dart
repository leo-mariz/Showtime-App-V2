import 'package:app/features/chat/domain/dtos/send_message_input_dto.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== LOAD MESSAGES EVENTS ====================

/// Evento para carregar mensagens de um chat
/// 
/// Inicia stream de mensagens e escuta atualizações em tempo real
class LoadMessagesEvent extends MessagesEvent {
  final String chatId;

  LoadMessagesEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

/// Evento interno disparado quando o stream de mensagens atualiza
/// 
/// Não deve ser chamado diretamente pela UI
class MessagesUpdatedEvent extends MessagesEvent {
  final List<MessageEntity> messages;

  MessagesUpdatedEvent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

// ==================== SEND MESSAGE EVENT ====================

/// Evento para enviar uma mensagem
/// 
/// Usa DTO para agrupar dados da mensagem
class SendMessageEvent extends MessagesEvent {
  final SendMessageInputDto input;

  SendMessageEvent({required this.input});

  @override
  List<Object?> get props => [input];
}

// ==================== LOAD MORE MESSAGES EVENT ====================

/// Evento para carregar mais mensagens (paginação)
class LoadMoreMessagesEvent extends MessagesEvent {
  final String chatId;
  final DateTime beforeDate;

  LoadMoreMessagesEvent({
    required this.chatId,
    required this.beforeDate,
  });

  @override
  List<Object?> get props => [chatId, beforeDate];
}

// ==================== MARK AS READ EVENT ====================

/// Evento para marcar mensagens como lidas
class MarkMessagesAsReadEvent extends MessagesEvent {
  final String chatId;

  MarkMessagesAsReadEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

// ==================== TYPING STATUS EVENTS ====================

/// Evento para atualizar status de digitação
class UpdateTypingStatusEvent extends MessagesEvent {
  final String chatId;
  final bool isTyping;

  UpdateTypingStatusEvent({
    required this.chatId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [chatId, isTyping];
}

// ==================== RESET EVENT ====================

/// Evento para resetar o BLoC ao estado inicial
/// 
/// Cancela subscriptions, timers e emite estado inicial
class ResetMessagesEvent extends MessagesEvent {}
