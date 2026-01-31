import 'package:dart_mappable/dart_mappable.dart';

part 'support_request_entity.mapper.dart';

/// Entidade que representa uma solicitação de atendimento (suporte).
/// Registrada no Firestore e enviada por email para o Showtime.
@MappableClass()
class SupportRequestEntity with SupportRequestEntityMappable {
  /// ID do documento no Firestore
  final String? id;

  /// ID do usuário que enviou (uid)
  final String userId;

  /// Nome informado pelo usuário
  final String name;

  /// Email do usuário (opcional, para contato)
  final String? userEmail;

  /// Assunto (ex.: Dúvidas, Problemas técnicos, Sugestões, Outros)
  final String subject;

  /// Mensagem do usuário
  final String message;

  /// Número de protocolo (gerado a partir do id ou timestamp)
  final String? protocolNumber;

  /// Data de criação
  final DateTime? createdAt;

  /// Status (ex.: pending, in_progress, resolved)
  final String? status;

  /// ID do contrato quando a solicitação está vinculada a um contrato (ex.: cancelamento, reembolso).
  final String? contractId;

  const SupportRequestEntity({
    this.id,
    required this.userId,
    required this.name,
    this.userEmail,
    required this.subject,
    required this.message,
    this.protocolNumber,
    this.createdAt,
    this.status,
    this.contractId,
  });
}
