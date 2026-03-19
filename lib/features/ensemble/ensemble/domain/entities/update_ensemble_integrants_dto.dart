/// DTO para atualizar número de integrantes, talentos e tipo de conjunto.
class UpdateEnsembleIntegrantsDto {
  final int membersCount;
  final List<String>? talents;
  final String? ensembleType;

  const UpdateEnsembleIntegrantsDto({
    required this.membersCount,
    this.talents,
    this.ensembleType,
  });
}
