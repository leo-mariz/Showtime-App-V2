/// DTO de entrada para adicionar um integrante ao conjunto.
/// Usado no fluxo de criação do conjunto e ao adicionar novo membro.
class EnsembleMemberInput {
  final String name;
  final String cpf;
  final String email;

  const EnsembleMemberInput({
    required this.name,
    required this.cpf,
    required this.email,
  });
}
