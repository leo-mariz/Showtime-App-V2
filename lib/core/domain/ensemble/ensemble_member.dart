import 'package:dart_mappable/dart_mappable.dart';

part 'ensemble_member.mapper.dart';

/// Referência enxuta a um integrante dentro de um conjunto.
/// Contém apenas o id do membro e os dados específicos do grupo (talento neste conjunto).
/// Dados completos do integrante (nome, cpf, email, isApproved) ficam na feature members.
@MappableClass()
class EnsembleMember with EnsembleMemberMappable {
  /// ID do membro (document ID na coleção Members do artista).
  /// Para o dono do conjunto, pode ser o [ownerArtistId].
  final String memberId;

  /// Talentos do integrante neste grupo (específicos do conjunto).
  final List<String>? specialty;

  /// Indica se é o dono do conjunto (conta principal).
  final bool isOwner;

  const EnsembleMember({
    required this.memberId,
    this.specialty,
    this.isOwner = false,
  });
}
