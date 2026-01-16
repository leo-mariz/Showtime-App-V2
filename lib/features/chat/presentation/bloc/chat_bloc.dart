import 'package:app/features/chat/presentation/bloc/events/chat_events.dart';
import 'package:app/features/chat/presentation/bloc/states/chat_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc para gerenciar estado da feature Chat
/// 
/// TODO: Implementar lógica de negócio quando domain/data estiverem prontos
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    // Handlers serão implementados quando domain/data estiverem prontos
    on<GetConversationsEvent>(_onGetConversationsEvent);
    on<GetMessagesEvent>(_onGetMessagesEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsReadEvent);
  }

  Future<void> _onGetConversationsEvent(
    GetConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implementar quando domain/data estiverem prontos
    emit(GetConversationsLoading());
    // Por enquanto, apenas emite estado inicial
    emit(ChatInitial());
  }

  Future<void> _onGetMessagesEvent(
    GetMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implementar quando domain/data estiverem prontos
    emit(GetMessagesLoading());
    emit(ChatInitial());
  }

  Future<void> _onSendMessageEvent(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implementar quando domain/data estiverem prontos
    emit(SendMessageLoading());
    emit(ChatInitial());
  }

  Future<void> _onMarkMessagesAsReadEvent(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implementar quando domain/data estiverem prontos
    emit(MarkMessagesAsReadLoading());
    emit(ChatInitial());
  }
}
