import 'dart:convert';

import 'package:flutter/services.dart';

/// Templates de e-mail em HTML para o fluxo de contratação e para boas-vindas/onboarding.
///
/// Inclui: pedido enviado, aceite/recusa, pagamento, show confirmado, cancelamento;
/// e boas-vindas no cadastro, após onboarding de cliente e após onboarding de artista.
/// Cada função recebe as variáveis necessárias e retorna o HTML do corpo do e-mail.
/// Use com [EmailEntity](body: html, isHtml: true).
///
/// Para exibir o logo da Showtime nos e-mails, chame [initShowtimeLogoFromAsset]
/// uma vez (por exemplo no início do app ou antes de enviar o primeiro e-mail).
/// O logo é carregado de [kShowtimeLogoAssetPath].

/// Caminho do logo nos assets (assets/icons/logo/Logo.png).
const String kShowtimeLogoAssetPath = 'assets/icons/logo/Logo.png';

String? _logoDataUri;

/// Carrega o logo da Showtime do asset e o deixa pronto para uso nos templates.
/// Chame uma vez (ex.: no init do app ou antes de enviar e-mails).
Future<void> initShowtimeLogoFromAsset() async {
  try {
    final byteData = await rootBundle.load(kShowtimeLogoAssetPath);
    final bytes = byteData.buffer.asUint8List();
    final base64 = base64Encode(bytes);
    _logoDataUri = 'data:image/png;base64,$base64';
  } catch (_) {
    _logoDataUri = null;
  }
}

/// Layout base: cabeçalho com logo (se [initShowtimeLogoFromAsset] foi chamado) ou texto, conteúdo e rodapé.
/// Exposto como [wrapEmailBody] para uso em outros arquivos de templates (ex.: onboarding).
String wrapEmailBody(String content) {
  final logoHtml = _logoDataUri != null
      ? '<img src="$_logoDataUri" alt="Showtime" style="max-height: 48px; display: block; margin: 0 auto;" />'
      : '<span style="font-size: 24px; font-weight: 700; color: #1a1a1a;">Showtime</span>';
  return '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Showtime</title>
</head>
<body style="margin:0; padding:0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #f5f5f5;">
    <tr>
      <td align="center" style="padding: 24px 16px;">
        <table role="presentation" width="100%" style="max-width: 560px; background-color: #ffffff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08);">
          <tr>
            <td style="padding: 28px 24px 16px; text-align: center; border-bottom: 1px solid #eee;">
              $logoHtml
            </td>
          </tr>
          <tr>
            <td style="padding: 24px;">
              $content
            </td>
          </tr>
          <tr>
            <td style="padding: 16px 24px 28px; font-size: 12px; color: #888; text-align: center; border-top: 1px solid #eee;">
              Showtime — Conectando artistas e anfitriões.<br>
              <a href="https://showtime.app.br" style="color: #666;">showtime.app.br</a>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>''';
}

// ==================== 1. PEDIDO ENVIADO ====================

/// Confirmação para o **cliente**: seu pedido foi enviado ao artista.
String requestSentToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty
      ? ' para <strong>$eventName</strong>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Recebemos seu pedido e ele já foi enviado ao artista <strong>$artistName</strong>$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Resumo do pedido:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      O artista receberá uma notificação e poderá aceitar ou recusar. Você será avisado assim que houver uma resposta.
    </p>''';
  return wrapEmailBody(content);
}

/// Notificação para o **artista**: você recebeu um novo pedido.
String requestSentToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty
      ? ' para <strong>$eventName</strong>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Você recebeu um novo pedido de <strong>$clientName</strong>$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Detalhes:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      Acesse o app Showtime para aceitar ou recusar o pedido.
    </p>''';
  return wrapEmailBody(content);
}

// ==================== 2. ARTISTA ACEITOU ====================

/// Notificação para o **cliente**: o artista aceitou o pedido.
String artistAcceptedToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Ótima notícia: <strong>$artistName</strong> aceitou seu pedido$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      O próximo passo é realizar o pagamento pelo app para confirmar a apresentação.
    </p>''';
  return wrapEmailBody(content);
}

/// Confirmação para o **artista**: você aceitou o pedido.
String artistAcceptedToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Confirmamos que você aceitou o pedido de <strong>$clientName</strong>$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      Aguarde o pagamento do anfitrião. Você será avisado quando o pagamento for confirmado.
    </p>''';
  return wrapEmailBody(content);
}

// ==================== 3. ARTISTA RECUSOU ====================

/// Notificação para o **cliente**: o artista recusou o pedido.
String artistRejectedToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Infelizmente <strong>$artistName</strong> não pôde aceitar seu pedido$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Pedido recusado:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      Você pode buscar outros artistas no app Showtime para a mesma data.
    </p>''';
  return wrapEmailBody(content);
}

/// Confirmação para o **artista**: você recusou o pedido.
String artistRejectedToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Confirmamos que você recusou o pedido de <strong>$clientName</strong>$eventDesc.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário do pedido:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      O anfitrião foi notificado e pode buscar outro artista no app.
    </p>''';
  return wrapEmailBody(content);
}

// ==================== 4. PAGAMENTO REALIZADO ====================

/// Confirmação para o **cliente**: pagamento recebido.
String paymentMadeToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
  String? valueFormatted,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final valueLine = valueFormatted != null && valueFormatted.isNotEmpty
      ? '<li><strong>Valor:</strong> $valueFormatted</li>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Seu pagamento foi confirmado. A apresentação de <strong>$artistName</strong>$eventDesc está confirmada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Resumo:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
      $valueLine
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      No dia do evento, o artista confirmará a realização pelo app. Lembre-se de avaliar a apresentação após o show.
    </p>''';
  return wrapEmailBody(content);
}

/// Notificação para o **artista**: pagamento recebido + lembrete de tempo de preparação.
String paymentMadeToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  required int preparationTimeMinutes,
  String? eventName,
  String? eventAddress,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final prepText = preparationTimeMinutes > 0
      ? 'O anfitrião reservou <strong>$preparationTimeMinutes minutos</strong> para sua preparação. Recomendamos que você chegue ao local com antecedência (por exemplo, 15 a 20 minutos antes do horário de início) para montar e se preparar com calma.'
      : 'Recomendamos que você chegue ao local com antecedência (por exemplo, 15 a 20 minutos antes do horário de início) para montar e se preparar com calma.';
  final addressLine = eventAddress != null && eventAddress.isNotEmpty
      ? '<li><strong>Local:</strong> $eventAddress</li>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      O pagamento do anfitrião <strong>$clientName</strong> foi confirmado. A apresentação$eventDesc está confirmada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário de início:</strong> $eventTime</li>
      $addressLine
    </ul>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      $prepText
    </p>
    <p style="margin:0; font-size: 14px; color: #666;">
      No dia do evento, confirme a realização pelo app ao iniciar a apresentação. Após o show, não esqueça de avaliar o anfitrião.
    </p>''';
  return wrapEmailBody(content);
}

// ==================== 5. SHOW CONFIRMADO / REALIZADO ====================

/// Notificação para o **cliente**: show foi realizado — lembrete para avaliar o artista.
String showConfirmedToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      A apresentação de <strong>$artistName</strong>$eventDesc foi confirmada como realizada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      Sua opinião é importante! Acesse o app e avalie a apresentação do artista.
    </p>''';
  return wrapEmailBody(content);
}

/// Notificação para o **artista**: show foi realizado — lembrete para avaliar o anfitrião.
String showConfirmedToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  String? eventName,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      A apresentação para <strong>$clientName</strong>$eventDesc foi confirmada como realizada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    <p style="margin:0; font-size: 14px; color: #666;">
      Sua opinião é importante! Acesse o app e avalie o anfitrião.
    </p>''';
  return wrapEmailBody(content);
}

// ==================== 6. SHOW CANCELADO ====================

/// Notificação para o **cliente**: o show foi cancelado.
String showCanceledToClientTemplate({
  required String clientName,
  required String artistName,
  required String eventDate,
  required String eventTime,
  String? eventName,
  String? cancelReason,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final reasonLine = cancelReason != null && cancelReason.isNotEmpty
      ? '<p style="margin:0 0 16px; font-size: 14px; color: #666;"><strong>Motivo:</strong> $cancelReason</p>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$clientName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Informamos que a apresentação de <strong>$artistName</strong>$eventDesc foi cancelada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário do evento cancelado:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    $reasonLine
    <p style="margin:0; font-size: 14px; color: #666;">
      Em caso de dúvidas sobre reembolso ou nova contratação, utilize o suporte no app.
    </p>''';
  return wrapEmailBody(content);
}

/// Notificação para o **artista**: o show foi cancelado.
String showCanceledToArtistTemplate({
  required String artistName,
  required String clientName,
  required String eventDate,
  required String eventTime,
  String? eventName,
  String? cancelReason,
}) {
  final eventDesc = eventName != null && eventName.isNotEmpty ? ' ($eventName)' : '';
  final reasonLine = cancelReason != null && cancelReason.isNotEmpty
      ? '<p style="margin:0 0 16px; font-size: 14px; color: #666;"><strong>Motivo:</strong> $cancelReason</p>'
      : '';
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Informamos que a apresentação para <strong>$clientName</strong>$eventDesc foi cancelada.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;">Data e horário do evento cancelado:</p>
    <ul style="margin:0 0 20px; padding-left: 20px; font-size: 15px; color: #444;">
      <li><strong>Data:</strong> $eventDate</li>
      <li><strong>Horário:</strong> $eventTime</li>
    </ul>
    $reasonLine
    <p style="margin:0; font-size: 14px; color: #666;">
      Em caso de dúvidas, utilize o suporte no app Showtime.
    </p>''';
  return wrapEmailBody(content);
}
