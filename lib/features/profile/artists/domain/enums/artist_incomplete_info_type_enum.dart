/// Enum que representa os tipos de informações incompletas do artista
/// 
/// Este enum é usado para identificar tipos específicos de informações
/// que podem estar incompletas no perfil do artista. É usado no `incompleteSections`
/// do `ArtistEntity` para garantir type safety e evitar erros de digitação.
/// 
/// Os valores deste enum correspondem aos valores do `ArtistInfoType`, mas são
/// serializados como strings no Firestore.
enum ArtistIncompleteInfoType {
  documents,
  bankAccount,
  profilePicture,
  availability,
  professionalInfo,
  presentations;

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
