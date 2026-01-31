import 'package:app/features/ensemble/members/domain/entities/ensemble_member_input.dart';

/// DTO de entrada para criar um conjunto.
/// A UI envia apenas os inputs; o use case monta as entidades e persiste.
class CreateEnsembleInput {
  final List<EnsembleMemberInput> members;

  const CreateEnsembleInput({
    this.members = const [],
  });
}
