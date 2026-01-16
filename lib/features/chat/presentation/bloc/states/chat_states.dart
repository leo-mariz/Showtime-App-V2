import 'package:app/core/domain/chat/message_entity.dart';
import 'package:app/core/domain/chat/conversation_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChatInitial extends ChatState {}

// ==================== GET CONVERSATIONS STATES ====================

class GetConversationsLoading extends ChatState {}

class GetConversationsSuccess extends ChatState {
  final List<ConversationEntity> conversations;

  GetConversationsSuccess({required this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class GetConversationsFailure extends ChatState {
  final String error;

  GetConversationsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET MESSAGES STATES ====================

class GetMessagesLoading extends ChatState {}

class GetMessagesSuccess extends ChatState {
  final List<MessageEntity> messages;

  GetMessagesSuccess({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class GetMessagesFailure extends ChatState {
  final String error;

  GetMessagesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SEND MESSAGE STATES ====================

class SendMessageLoading extends ChatState {}

class SendMessageSuccess extends ChatState {
  final String messageId;

  SendMessageSuccess({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class SendMessageFailure extends ChatState {
  final String error;

  SendMessageFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== MARK MESSAGES AS READ STATES ====================

class MarkMessagesAsReadLoading extends ChatState {}

class MarkMessagesAsReadSuccess extends ChatState {}

class MarkMessagesAsReadFailure extends ChatState {
  final String error;

  MarkMessagesAsReadFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
