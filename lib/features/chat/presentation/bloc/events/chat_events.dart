import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET CONVERSATIONS EVENTS ====================

class GetConversationsEvent extends ChatEvent {
  final bool? forceRefresh;

  GetConversationsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

// ==================== GET MESSAGES EVENTS ====================

class GetMessagesEvent extends ChatEvent {
  final String contractId;
  final bool? forceRefresh;

  GetMessagesEvent({
    required this.contractId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [contractId, forceRefresh];
}

class GetMessagesStreamEvent extends ChatEvent {
  final String contractId;

  GetMessagesStreamEvent({
    required this.contractId,
  });

  @override
  List<Object?> get props => [contractId];
}

// ==================== SEND MESSAGE EVENTS ====================

class SendMessageEvent extends ChatEvent {
  final String contractId;
  final String text;
  final String? senderName;
  final String? senderAvatarUrl;

  SendMessageEvent({
    required this.contractId,
    required this.text,
    this.senderName,
    this.senderAvatarUrl,
  });

  @override
  List<Object?> get props => [contractId, text, senderName, senderAvatarUrl];
}

// ==================== MARK MESSAGES AS READ EVENTS ====================

class MarkMessagesAsReadEvent extends ChatEvent {
  final String contractId;
  final List<String>? messageIds; // Se null, marca todas como lidas

  MarkMessagesAsReadEvent({
    required this.contractId,
    this.messageIds,
  });

  @override
  List<Object?> get props => [contractId, messageIds];
}
