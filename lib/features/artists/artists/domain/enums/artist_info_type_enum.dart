/// Enum que identifica tipos específicos de informações do artista
/// 
/// Cada tipo está associado a uma categoria (ArtistInfoCategory) e representa
/// uma verificação específica de completude
enum ArtistInfoType {
  /// Documentos: Todos os documentos obrigatórios (Identity, Residence, Curriculum, Antecedents)
  /// Categoria: approvalRequired
  documents,
  
  /// Informações bancárias: PIX ou Conta bancária (Agência + Conta)
  /// Categoria: approvalRequired
  bankAccount,
  
  /// Foto de perfil: Imagem de perfil do artista
  /// Categoria: exploreRequired
  profilePicture,
  
  /// Disponibilidade: Pelo menos uma disponibilidade ativa (data futura)
  /// Categoria: exploreRequired
  availability,
  
  /// Informações profissionais: Dados profissionais do artista
  /// Categoria: optional
  professionalInfo,
  
  /// Apresentações: Mídias de apresentação do artista
  /// Categoria: optional
  presentations,
}
