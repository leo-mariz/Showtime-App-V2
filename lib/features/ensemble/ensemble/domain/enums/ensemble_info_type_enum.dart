/// Tipos de informação verificados na completude do conjunto.
/// Uma verificação por tipo; cada uma com mensagem própria quando incompleta.
enum EnsembleInfoType {
  /// 1. Há pelo menos um integrante além do administrador (isOwner = false).
  members,

  /// 2. O(s) integrante(s) têm ambos os documentos (identidade e antecedentes) enviados ou aprovados.
  memberDocuments,

  /// 3. Há foto de perfil do grupo.
  profilePhoto,

  /// 4. Há vídeo de apresentação.
  presentations,

  /// 5. Dados profissionais do conjunto preenchidos.
  professionalInfo,

  /// 6. Administrador tem todos os documentos enviados (feature artists).
  ownerDocuments,

  /// 7. Administrador tem informações bancárias (PIX ou Ag/Conta).
  ownerBankAccount,
}
