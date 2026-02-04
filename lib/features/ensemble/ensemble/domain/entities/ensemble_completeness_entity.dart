import 'package:app/features/ensemble/ensemble/domain/entities/ensemble_info_status_entity.dart';
import 'package:equatable/equatable.dart';

/// Entidade que representa o status de completude do conjunto.
/// Usada para comparar com [EnsembleEntity.hasIncompleteSections] e [EnsembleEntity.incompleteSections].
class EnsembleCompletenessEntity extends Equatable {
  final List<EnsembleInfoStatusEntity> infoStatuses;

  const EnsembleCompletenessEntity({
    required this.infoStatuses,
  });

  /// Apenas os status incompletos (para montar incompleteSections).
  List<EnsembleInfoStatusEntity> get incompleteStatuses {
    return infoStatuses.where((s) => !s.isComplete).toList();
  }

  @override
  List<Object?> get props => [infoStatuses];
}
