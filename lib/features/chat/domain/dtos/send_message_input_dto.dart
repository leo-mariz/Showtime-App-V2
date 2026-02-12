import 'package:equatable/equatable.dart';

/// DTO para envio de mensagem
/// 
/// Agrupa dados necessários para enviar uma mensagem
/// O senderId é obtido internamente pelo UseCase
/// [chatStatus] opcional: usado pelo use case para bloquear envio se chat encerrado.
class SendMessageInputDto extends Equatable {
  final String chatId;
  final String text;
  /// Status atual do chat ('active', 'closed'). Se 'closed', o use case bloqueia o envio.
  final String? chatStatus;

  const SendMessageInputDto({
    required this.chatId,
    required this.text,
    this.chatStatus,
  });

  @override
  List<Object?> get props => [chatId, text, chatStatus];

  /// Cria cópia com valores atualizados
  SendMessageInputDto copyWith({
    String? chatId,
    String? text,
    String? chatStatus,
  }) {
    return SendMessageInputDto(
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      chatStatus: chatStatus ?? this.chatStatus,
    );
  }
}
