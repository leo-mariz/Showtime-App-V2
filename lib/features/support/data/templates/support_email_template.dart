import 'package:app/features/support/domain/entities/support_request_entity.dart';

/// Template do email enviado para o Showtime (contato@showtime.app.br)
/// quando o usuário submete uma solicitação de atendimento.
class SupportEmailTemplate {
  static const String showtimeEmail = 'contato@showtime.app.br';

  /// Assunto do email recebido pelo Showtime.
  static String subject(SupportRequestEntity request) {
    final protocol = request.protocolNumber ?? request.id ?? '—';
    return '[Atendimento #$protocol] ${request.subject}';
  }

  /// Corpo do email (texto plano) para a equipe Showtime.
  static String body(SupportRequestEntity request) {
    final protocol = request.protocolNumber ?? request.id ?? '—';
    final email = request.userEmail ?? 'Não informado';
    final contractLine = request.contractId != null
        ? 'Contrato (ID): ${request.contractId}\n'
        : '';
    return '''
Nova solicitação de atendimento

Protocolo: $protocol
Data: ${request.createdAt ?? DateTime.now()}
Status: ${request.status ?? 'pending'}
$contractLine---
Nome: ${request.name}
Email do usuário: $email
Assunto: ${request.subject}

Mensagem:
${request.message}
---
''';
  }
}
