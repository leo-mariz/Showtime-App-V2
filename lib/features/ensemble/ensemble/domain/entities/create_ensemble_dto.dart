/// DTO com os dados do modal de novo conjunto para criar um ensemble.
class CreateEnsembleDto {
  final String? ensembleName;
  final int membersCount;
  final String? ensembleType;
  final List<String>? talents;
  final String? bio;

  const CreateEnsembleDto({
    this.ensembleName,
    this.membersCount = 2,
    this.ensembleType,
    this.talents,
    this.bio,
  });
}
