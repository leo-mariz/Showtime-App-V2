/// Enum que categoriza tipos de informações do artista
/// 
/// ORGANIZAÇÃO:
/// - approvalRequired: Informações essenciais para aprovação do artista
/// - exploreRequired: Informações necessárias para aparecer no explorar
/// - optional: Informações opcionais que melhoram a experiência (ordenação/recomendação)
enum ArtistInfoCategory {
  /// Informações essenciais para aprovação do artista pela plataforma
  approvalRequired,
  
  /// Informações necessárias para o artista aparecer na busca/explorar
  exploreRequired,
  
  /// Informações opcionais que melhoram ordenação e recomendações
  optional,
}
