/// Campos de artista/conjunto cujo último update queremos rastrear.
/// Usado em [ArtistEntity.updatedInfos] e [EnsembleEntity.updatedInfos].
enum UpdatedInfoType {
  /// Foto de perfil (artista: profilePicture; conjunto: profilePhotoUrl).
  profilePhoto,

  /// Apresentações (artista: presentationMedias; conjunto: presentationVideoUrl).
  presentations,

  /// Bio (professionalInfo.bio).
  bio,

  /// Nome (artista: artistName; conjunto: ensembleName).
  name,
}
