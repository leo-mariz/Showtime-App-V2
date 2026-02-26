class EmailTemplates {
  static String buildArtistWelcomeEmail(String fullName) {
    return '''
    Bem-vindo ao Showtime, $fullName! 🎭
    Estamos muito felizes em tê-lo como parte da nossa comunidade de artistas.
    Para começar, por favor, confirme seu email clicando no link que enviamos para sua caixa de entrada.
    Após a confirmação, você poderá acessar sua área de artista e começar a preencher suas informações de perfil. Isso inclui:
      
      - Detalhes pessoais e profissionais
      - Envio de documentos necessários
      - Configuração de sua área de artista
      
    Essas etapas são essenciais para que você possa ser visível no aplicativo e começar a receber solicitações de eventos.
    Se precisar de ajuda, nossa equipe de suporte está sempre à disposição!
    Atenciosamente,
    Equipe Showtime
    ''';
  }

  static String buildClientWelcomeEmail(String fullName) {
    return '''
    Bem-vindo ao Showtime, $fullName! 🎉
    Estamos muito felizes em tê-lo como parte da nossa comunidade de clientes.
    Para começar, por favor, confirme seu email clicando no link que enviamos para sua caixa de entrada.
    Após a confirmação, você poderá acessar sua conta e começar a explorar os artistas disponíveis. Recomendamos que você:
    - Complete seu perfil com suas preferências
    - Explore os artistas e eventos disponíveis
    - Entre em contato com artistas para eventos especiais
    Essas etapas ajudarão você a aproveitar ao máximo nossa plataforma.
    Se precisar de ajuda, nossa equipe de suporte está sempre à disposição!
    Atenciosamente,
    Equipe Showtime
    ''';
  }

  
}