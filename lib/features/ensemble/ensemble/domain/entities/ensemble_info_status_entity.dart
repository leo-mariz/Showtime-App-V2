import 'package:app/features/ensemble/ensemble/domain/enums/ensemble_info_type_enum.dart';
import 'package:equatable/equatable.dart';

/// Status de uma informação específica do conjunto (ensemble).
class EnsembleInfoStatusEntity extends Equatable {
  final EnsembleInfoType type;
  final bool isComplete;
  final List<String> missingItems;

  const EnsembleInfoStatusEntity({
    required this.type,
    required this.isComplete,
    required this.missingItems,
  });

  String get typeDescription {
    switch (type) {
      case EnsembleInfoType.members:
        return 'Integrantes';
      case EnsembleInfoType.memberDocuments:
        return 'Documentos dos integrantes';
      case EnsembleInfoType.profilePhoto:
        return 'Foto de perfil do grupo';
      case EnsembleInfoType.presentations:
        return 'Apresentações';
      case EnsembleInfoType.professionalInfo:
        return 'Dados profissionais';
      case EnsembleInfoType.ownerDocuments:
        return 'Documentos do administrador';
      case EnsembleInfoType.ownerBankAccount:
        return 'Dados bancários do administrador';
    }
  }

  @override
  List<Object?> get props => [type, isComplete, missingItems];
}
