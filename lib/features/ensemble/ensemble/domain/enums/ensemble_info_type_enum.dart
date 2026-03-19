/// Tipos de informação verificados na completude do conjunto.
/// Uma verificação por tipo; cada uma com mensagem própria quando incompleta.
enum EnsembleInfoType {
  /// Nome do grupo não vazio.
  ensembleName,

  /// Talentos não vazio.
  talents,

  /// Dados profissionais: todos os campos preenchidos.
  professionalInfo,

  /// Foto de perfil não vazio.
  profilePhoto,

  /// (Legado) Tipo do conjunto preenchido.
  ensembleType,

  /// (Legado) Vídeo de apresentação.
  presentations,

  /// (Legado) Documentos do administrador.
  ownerDocuments,

  /// (Legado) Dados bancários do administrador.
  ownerBankAccount,
}
