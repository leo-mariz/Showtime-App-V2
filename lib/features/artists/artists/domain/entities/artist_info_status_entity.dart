import 'package:app/features/artists/artists/domain/enums/artist_info_category_enum.dart';
import 'package:app/features/artists/artists/domain/enums/artist_info_type_enum.dart';
import 'package:equatable/equatable.dart';

/// Entidade que representa o status de uma informação específica do artista
/// 
/// Exemplo:
/// - type: ArtistInfoType.documents
/// - category: ArtistInfoCategory.approvalRequired
/// - isComplete: false
/// - missingItems: ['Identity', 'Residence']
class ArtistInfoStatusEntity extends Equatable {
  final ArtistInfoType type;
  final ArtistInfoCategory category;
  final bool isComplete;
  final List<String> missingItems;

  const ArtistInfoStatusEntity({
    required this.type,
    required this.category,
    required this.isComplete,
    required this.missingItems,
  });

  /// Retorna a descrição amigável do tipo de informação
  String get typeDescription {
    switch (type) {
      case ArtistInfoType.documents:
        return 'Documentos';
      case ArtistInfoType.bankAccount:
        return 'Informações Bancárias';
      case ArtistInfoType.profilePicture:
        return 'Foto de Perfil';
      case ArtistInfoType.availability:
        return 'Disponibilidade';
      case ArtistInfoType.professionalInfo:
        return 'Informações Profissionais';
      case ArtistInfoType.presentations:
        return 'Apresentações';
    }
  }

  /// Retorna mensagem explicativa sobre o que falta
  String get explanationMessage {
    if (isComplete) {
      return '$typeDescription está completo';
    }

    if (missingItems.isEmpty) {
      return '$typeDescription está incompleto';
    }

    if (missingItems.length == 1) {
      return 'Falta: ${missingItems.first}';
    }

    return 'Faltam: ${missingItems.join(', ')}';
  }

  /// Retorna mensagem sobre o impacto dessa informação
  String get impactMessage {
    switch (category) {
      case ArtistInfoCategory.approvalRequired:
        return 'Necessário para aprovação do perfil';
      case ArtistInfoCategory.exploreRequired:
        return 'Necessário para aparecer no explorar';
      case ArtistInfoCategory.optional:
        return 'Melhora sua visibilidade na busca';
    }
  }

  @override
  List<Object?> get props => [type, category, isComplete, missingItems];
}
