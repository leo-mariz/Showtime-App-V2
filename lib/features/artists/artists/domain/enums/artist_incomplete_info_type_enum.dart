/// Enum que representa os tipos de informações incompletas do artista
/// 
/// Este enum é usado para identificar tipos específicos de informações
/// que podem estar incompletas no perfil do artista. É usado no `incompleteSections`
/// do `ArtistEntity` para garantir type safety e evitar erros de digitação.
/// 
/// Os valores deste enum correspondem aos valores do `ArtistInfoType`, mas são
/// serializados como strings no Firestore.
///
/// **Uso no painel admin:** para cada chave em `artist.incompleteSections`:
/// 1. Use [ArtistIncompleteInfoType.fromString(key)] para obter o enum.
/// 2. Use [displayName] para o label e [categoryForAdmin] para agrupar (Aprovação / Visibilidade / Opcional).
/// 3. Use [adminDescription] para texto explicativo na interface.
enum ArtistIncompleteInfoType {
  documents,
  bankAccount,
  profilePicture,
  availability,
  professionalInfo,
  presentations;

  /// Categoria para exibição no admin: Aprovação, Visibilidade ou Opcional
  String get categoryForAdmin {
    switch (this) {
      case ArtistIncompleteInfoType.documents:
      case ArtistIncompleteInfoType.bankAccount:
        return 'Aprovação';
      case ArtistIncompleteInfoType.profilePicture:
      case ArtistIncompleteInfoType.availability:
        return 'Visibilidade';
      case ArtistIncompleteInfoType.professionalInfo:
      case ArtistIncompleteInfoType.presentations:
        return 'Opcional';
    }
  }

  /// Descrição curta para o painel admin (o que falta / impacto)
  String get adminDescription {
    switch (this) {
      case ArtistIncompleteInfoType.documents:
        return 'Documentos obrigatórios: identidade, comprovante de residência, currículo e antecedentes.';
      case ArtistIncompleteInfoType.bankAccount:
        return 'PIX ou conta bancária (agência, conta e tipo) para pagamentos.';
      case ArtistIncompleteInfoType.profilePicture:
        return 'Foto de perfil não enviada.';
      case ArtistIncompleteInfoType.availability:
        return 'Nenhuma disponibilidade ativa com data futura.';
      case ArtistIncompleteInfoType.professionalInfo:
        return 'Dados profissionais incompletos: especialidade, duração mínima, tempo de preparação e bio.';
      case ArtistIncompleteInfoType.presentations:
        return 'Falta vídeo de apresentação para cada talento cadastrado.';
    }
  }

  /// Retorna o nome amigável do tipo de informação
  String get displayName {
    switch (this) {
      case ArtistIncompleteInfoType.documents:
        return 'Documentos';
      case ArtistIncompleteInfoType.bankAccount:
        return 'Informações Bancárias';
      case ArtistIncompleteInfoType.profilePicture:
        return 'Foto de Perfil';
      case ArtistIncompleteInfoType.availability:
        return 'Disponibilidade';
      case ArtistIncompleteInfoType.professionalInfo:
        return 'Informações Profissionais';
      case ArtistIncompleteInfoType.presentations:
        return 'Apresentações';
    }
  }

  /// Converte de string (nome do enum) para enum
  /// Usado para deserialização do Firestore
  static ArtistIncompleteInfoType? fromString(String value) {
    try {
      return ArtistIncompleteInfoType.values.firstWhere(
        (e) => e.name == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// Converte enum para string (nome do enum)
  /// Usado para serialização no Firestore
  String toString() => name;
}
