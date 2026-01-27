import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatsListState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChatsListInitial extends ChatsListState {}

// ==================== LOAD CHATS STATES ====================

/// Estado de carregamento inicial da lista de chats
class ChatsListLoading extends ChatsListState {}

/// Estado de sucesso com lista de chats
class ChatsListSuccess extends ChatsListState {
  final List<ChatEntity> chats;

  ChatsListSuccess({required this.chats});

  @override
  List<Object?> get props => [chats];
}

/// Estado de erro ao carregar chats
class ChatsListFailure extends ChatsListState {
  final String error;

  ChatsListFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CREATE CHAT STATES ====================

/// Estado de carregamento ao criar chat
class CreateChatLoading extends ChatsListState {}

/// Estado de sucesso ao criar chat
class CreateChatSuccess extends ChatsListState {
  final ChatEntity chat;

  CreateChatSuccess({required this.chat});

  @override
  List<Object?> get props => [chat];
}

/// Estado de erro ao criar chat
class CreateChatFailure extends ChatsListState {
  final String error;

  CreateChatFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
