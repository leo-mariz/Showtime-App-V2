import 'package:app/core/email_templates/contract_flow_templates.dart' show wrapEmailBody;
import 'package:app/features/support/domain/entities/support_request_entity.dart';

/// Escapa caracteres HTML para exibição segura no corpo do email.
String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

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

  /// Corpo do email de confirmação enviado ao usuário (texto plano, fallback).
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

  // ==================== Confirmação HTML (sucesso + dados enviados) ====================

  /// Template HTML de confirmação de atendimento: informa que o envio foi feito com sucesso
  /// e exibe os dados enviados (assunto, nome, mensagem). Usa o layout padrão (logo + rodapé).
  ///
  /// [subject] Assunto do contato.
  /// [name] Nome do usuário.
  /// [message] Mensagem enviada.
  /// [protocol] Número de protocolo (opcional).
  static String bodyUserConfirmationHtml({
    required String subject,
    required String name,
    required String message,
    String? protocol,
  }) {
    final protocolBlock = protocol != null && protocol.isNotEmpty
        ? '''
    <p style="margin: 0 0 12px 0; font-size: 14px; color: #333;">
      <strong>Protocolo:</strong> #${_escapeHtml(protocol)}
    </p>'''
        : '';
    final messageHtml = _escapeHtml(message).replaceAll('\n', '<br>');
    final content = '''
    <p style="margin: 0 0 16px 0; font-size: 16px; color: #1a1a1a;">Olá, ${_escapeHtml(name)}!</p>
    <p style="margin: 0 0 20px 0; font-size: 15px; color: #333;">
      Recebemos sua solicitação de atendimento com sucesso. Abaixo estão as informações que você enviou.
    </p>
    <div style="margin: 0 0 20px 0; padding: 16px; background-color: #f8f9fa; border-radius: 8px; border-left: 4px solid #666;">
      $protocolBlock
      <p style="margin: 0 0 8px 0; font-size: 14px; color: #333;">
        <strong>Assunto:</strong> ${_escapeHtml(subject)}
      </p>
      <p style="margin: 0 0 8px 0; font-size: 14px; color: #333;">
        <strong>Nome:</strong> ${_escapeHtml(name)}
      </p>
      <p style="margin: 0 0 0 0; font-size: 14px; color: #333;">
        <strong>Mensagem:</strong>
      </p>
      <p style="margin: 8px 0 0 0; font-size: 14px; color: #555; white-space: pre-wrap;">$messageHtml</p>
    </div>
    <p style="margin: 0; font-size: 14px; color: #666;">
      Nossa equipe responderá em breve ao email informado no cadastro. Em caso de urgência, cite o número do protocolo em novos contatos.
    </p>
''';
    return wrapEmailBody(content);
  }
}
