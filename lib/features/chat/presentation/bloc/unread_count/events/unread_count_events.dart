import 'package:equatable/equatable.dart';

abstract class UnreadCountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== LOAD UNREAD COUNT EVENTS ====================

/// Evento para carregar contador de mensagens não lidas
/// 
/// Inicia stream otimizado de contador e escuta atualizações em tempo real
/// O stream escuta apenas o campo totalUnread do documento user_chats/{userId}
class LoadUnreadCountEvent extends UnreadCountEvent {}

/// Evento interno disparado quando o stream de contador atualiza
/// 
/// Não deve ser chamado diretamente pela UI
class UnreadCountUpdatedEvent extends UnreadCountEvent {
  final int count;

  UnreadCountUpdatedEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

// ==================== RESET EVENT ====================

/// Evento para resetar o BLoC ao estado inicial
/// 
/// Cancela subscriptions e emite estado inicial
class ResetUnreadCountEvent extends UnreadCountEvent {}
