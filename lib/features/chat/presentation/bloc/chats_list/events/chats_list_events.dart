import 'package:app/features/chat/domain/dtos/create_chat_input_dto.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatsListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== LOAD CHATS EVENTS ====================

/// Evento para carregar lista de chats do usuário
/// 
/// Inicia stream de chats e escuta atualizações em tempo real
class LoadChatsEvent extends ChatsListEvent {}

/// Evento interno disparado quando o stream de chats atualiza
/// 
/// Não deve ser chamado diretamente pela UI
class ChatsUpdatedEvent extends ChatsListEvent {
  final List<ChatEntity> chats;

  ChatsUpdatedEvent({required this.chats});

  @override
  List<Object?> get props => [chats];
}

// ==================== REFRESH CHATS EVENTS ====================

/// Evento para forçar atualização da lista de chats
class RefreshChatsEvent extends ChatsListEvent {}

// ==================== CREATE CHAT EVENT ====================

/// Evento para criar um novo chat
/// 
/// Usa DTO para agrupar dados e facilitar manutenção
class CreateChatEvent extends ChatsListEvent {
  final CreateChatInputDto input;

  CreateChatEvent({required this.input});

  @override
  List<Object?> get props => [input];
}

// ==================== RESET EVENT ====================

/// Evento para resetar o BLoC ao estado inicial
/// 
/// Cancela subscriptions e emite estado inicial
class ResetChatsListEvent extends ChatsListEvent {}
