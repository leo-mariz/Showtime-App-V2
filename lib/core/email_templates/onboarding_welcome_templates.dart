import 'package:app/core/email_templates/contract_flow_templates.dart' show wrapEmailBody;

// ==================== BOAS-VINDAS E ONBOARDING ====================

/// Boas-vindas ao cadastrar: informa que a conta foi criada e que um e-mail de verificação foi enviado (pode estar no spam).
String welcomeOnSignUpTemplate({
  required String userName,
}) {
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$userName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Bem-vindo(a) ao Showtime! Sua conta foi criada com sucesso.
    </p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Enviamos um e-mail de <strong>verificação</strong> para o endereço que você informou. Por favor, acesse o link no e-mail para confirmar sua conta.
    </p>
    <p style="margin:0 0 16px; font-size: 14px; line-height: 1.5; color: #666; padding: 12px; background-color: #f8f8f8; border-radius: 8px;">
      Não encontrou o e-mail? Confira sua pasta de <strong>spam</strong> ou <strong>lixo eletrônico</strong>. O e-mail de verificação pode ter sido classificado lá.
    </p>
    <p style="margin:0; font-size: 14px; color: #666;">
      Após verificar seu e-mail, você poderá usar o app normalmente. Qualquer dúvida, estamos à disposição pelo suporte no app.
    </p>''';
  return wrapEmailBody(content);
}

/// Boas-vindas após onboarding de <strong>cliente/anfitrião</strong>: benefícios do Showtime e como buscar artistas.
String welcomeAfterClientOnboardingTemplate({
  required String userName,
}) {
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$userName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Parabéns por concluir seu cadastro como anfitrião no Showtime! Agora você pode contratar artistas para animar sua festa ou evento.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;"><strong>O que o Showtime oferece:</strong></p>
    <ul style="margin:0 0 16px; padding-left: 20px; font-size: 15px; color: #444; line-height: 1.6;">
      <li>Busca por <strong>data</strong>, <strong>local</strong> e <strong>tipo de apresentação</strong></li>
      <li>Perfis de artistas com fotos, vídeos e avaliações</li>
      <li>Pagamento seguro e acompanhamento do pedido pelo app</li>
      <li>Comunicação direta com o artista dentro do app</li>
    </ul>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;"><strong>Como buscar artistas:</strong></p>
    <p style="margin:0 0 16px; font-size: 14px; line-height: 1.5; color: #444;">
      No app, vá em <strong>Explorar</strong>, escolha a data do seu evento e o endereço. Você verá os artistas disponíveis para essa data. Toque no perfil que interessar, confira horários e valores e envie seu pedido. O artista receberá a solicitação e poderá aceitar ou recusar — você será avisado por e-mail e no app.
    </p>
    <p style="margin:0; font-size: 14px; color: #666;">
      Qualquer dúvida, use o suporte no app. Bom evento!
    </p>''';
  return wrapEmailBody(content);
}

/// Boas-vindas após onboarding de <strong>artista</strong>: como usar o app e benefícios.
String welcomeAfterArtistOnboardingTemplate({
  required String artistName,
}) {
  final content = '''
    <p style="margin:0 0 16px; font-size: 16px; color: #333;">Olá, <strong>$artistName</strong>!</p>
    <p style="margin:0 0 16px; font-size: 15px; line-height: 1.5; color: #444;">
      Parabéns por concluir seu cadastro como artista no Showtime! Agora você pode receber pedidos de anfitriões e divulgar suas apresentações.
    </p>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;"><strong>Benefícios do Showtime para você:</strong></p>
    <ul style="margin:0 0 16px; padding-left: 20px; font-size: 15px; color: #444; line-height: 1.6;">
      <li>Anfitriões te encontram por <strong>data</strong>, <strong>local</strong> e tipo de show</li>
      <li>Seu perfil com fotos, vídeos e avaliações ajuda a conquistar mais contratos</li>
      <li>Pagamento seguro: o valor é pago pelo app e você recebe após a apresentação</li>
      <li>Tudo combinado e conversado dentro do app, de forma organizada</li>
    </ul>
    <p style="margin:0 0 8px; font-size: 15px; color: #444;"><strong>Como usar o app:</strong></p>
    <p style="margin:0 0 16px; font-size: 14px; line-height: 1.5; color: #444;">
      Mantenha sua <strong>disponibilidade</strong> e <strong>preços</strong> atualizados no calendário. Quando um anfitrião enviar um pedido, você receberá uma notificação — aceite ou recuse pelo app. Após o pagamento, combine os detalhes com o cliente pelas mensagens do app. No dia do evento, confirme a realização no app para liberar o repasse do cachê.
    </p>
    <p style="margin:0; font-size: 14px; color: #666;">
      Qualquer dúvida, use o suporte no app. Boa sorte com suas apresentações!
    </p>''';
  return wrapEmailBody(content);
}
