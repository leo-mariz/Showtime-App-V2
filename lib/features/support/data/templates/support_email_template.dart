import 'package:app/features/support/domain/entities/support_request_entity.dart';

/// Template do email enviado para o Showtime (contato@showtime.app.br)
/// e de confirmação enviado ao usuário quando submete uma solicitação de atendimento.
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

  // ==================== Confirmação para o usuário ====================

  /// Assunto do email de confirmação enviado ao usuário.
  static String subjectUserConfirmation(SupportRequestEntity request) {
    final protocol = request.protocolNumber ?? request.id ?? '—';
    return 'Recebemos seu contato – Protocolo #$protocol';
  }

  /// Corpo do email de confirmação enviado ao usuário.
  /// Reflete protocolo, nome, assunto e mensagem; informa que responderemos em breve.
  static String bodyUserConfirmation(SupportRequestEntity request) {
    final protocol = request.protocolNumber ?? request.id ?? '—';
    final name = request.name;
    final subject = request.subject;
    final message = request.message;
    return '''
Olá, $name!

Recebemos sua solicitação de atendimento e ela já está em nossa fila.

Resumo do seu contato:
• Protocolo: #$protocol
• Assunto: $subject
• Sua mensagem: $message

Nossa equipe responderá em breve ao email informado no cadastro. Em caso de urgência, você pode citar o número do protocolo (#$protocol) em novos contatos.

Atenciosamente,
Equipe Showtime
''';
  }
}
