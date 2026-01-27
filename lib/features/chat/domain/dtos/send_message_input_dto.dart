import 'package:equatable/equatable.dart';

/// DTO para envio de mensagem
/// 
/// Agrupa dados necessários para enviar uma mensagem
/// O senderId é obtido internamente pelo UseCase
class SendMessageInputDto extends Equatable {
  final String chatId;
  final String text;

  const SendMessageInputDto({
    required this.chatId,
    required this.text,
  });

  @override
  List<Object?> get props => [chatId, text];

  /// Cria cópia com valores atualizados
  SendMessageInputDto copyWith({
    String? chatId,
    String? text,
  }) {
    return SendMessageInputDto(
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
    );
  }
}
