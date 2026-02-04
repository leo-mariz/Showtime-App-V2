import 'package:app/features/artists/artists/domain/entities/artist_info_status_entity.dart';
import 'package:app/features/artists/artists/domain/enums/artist_info_category_enum.dart';
import 'package:equatable/equatable.dart';

/// Entidade agregada que representa o status de completude geral do artista
/// 
/// Esta entidade consolida todas as verificações de informação do artista e
/// fornece métricas agregadas para decisões de negócio (aprovação, exibição, ordenação)
class ArtistCompletenessEntity extends Equatable {
  /// Indica se o artista pode ser aprovado (todas as informações de aprovação estão completas)
  final bool canBeApproved;
  
  /// Indica se o artista pode aparecer no explorar (todas as informações de explorar estão completas)
  final bool canAppearInExplore;
  
  /// Score de completude (0-100) usado para ordenação
  /// - 50 pontos: Informações de aprovação completas
  /// - 30 pontos: Informações de explorar completas
  /// - 10 pontos: Informações profissionais completas
  /// - 10 pontos: Apresentações completas
  final int completenessScore;
  
  /// Lista de status de cada tipo de informação
  final List<ArtistInfoStatusEntity> infoStatuses;
  
  /// Mapa indicando se cada categoria está completa
  final Map<ArtistInfoCategory, bool> categoryStatus;

  const ArtistCompletenessEntity({
    required this.canBeApproved,
    required this.canAppearInExplore,
    required this.completenessScore,
    required this.infoStatuses,
    required this.categoryStatus,
  });

  /// Retorna apenas os status incompletos
  List<ArtistInfoStatusEntity> get incompleteStatuses {
    return infoStatuses.where((status) => !status.isComplete).toList();
  }

  /// Retorna apenas os status completos
  List<ArtistInfoStatusEntity> get completeStatuses {
    return infoStatuses.where((status) => status.isComplete).toList();
  }

  /// Retorna status incompletos filtrados por categoria
  List<ArtistInfoStatusEntity> getIncompleteByCategory(ArtistInfoCategory category) {
    return incompleteStatuses.where(
      (status) => status.category == category,
    ).toList();
  }

  /// Retorna percentual de completude (0.0 a 1.0)
  double get completenessPercentage {
    return completenessScore / 100.0;
  }

  /// Retorna mensagem resumida do status
  String get summaryMessage {
    if (canBeApproved && canAppearInExplore) {
      return 'Perfil completo! Você está aprovado e visível no explorar.';
    } else if (canBeApproved && !canAppearInExplore) {
      return 'Perfil aprovado, mas precisa completar informações para aparecer no explorar.';
    } else if (!canBeApproved && canAppearInExplore) {
      return 'Perfil visível, mas precisa completar informações para aprovação.';
    } else {
      return 'Perfil incompleto. Complete as informações para aprovação e visibilidade.';
    }
  }

  @override
  List<Object?> get props => [
        canBeApproved,
        canAppearInExplore,
        completenessScore,
        infoStatuses,
        categoryStatus,
      ];
}
