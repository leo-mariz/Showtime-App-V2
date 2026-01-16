/// Entidade que representa uma conversa (agregação de contrato + última mensagem)
/// 
/// Usada para exibir a lista de conversas na tela de chat
class ConversationEntity {
  /// UID do contrato ao qual esta conversa pertence
  final String contractId;
  
  /// Nome do outro participante da conversa
  final String recipientName;
  
  /// URL do avatar do outro participante
  final String? recipientAvatar;
  
  /// Texto da última mensagem (pode ser null se não houver mensagens)
  final String? lastMessage;
  
  /// Timestamp da última mensagem (pode ser null se não houver mensagens)
  final DateTime? lastMessageTimestamp;
  
  /// Quantidade de mensagens não lidas
  final int unreadCount;
  
  /// Referência formatada do contrato (ex: "Bodas 31/01/26 11h")
  final String contractReference;
  
  /// Se o outro participante está online (pode ser implementado depois)
  final bool isOnline;

  ConversationEntity({
    required this.contractId,
    required this.recipientName,
    this.recipientAvatar,
    this.lastMessage,
    this.lastMessageTimestamp,
    required this.unreadCount,
    required this.contractReference,
    this.isOnline = false,
  });
}
