import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'app_list_item_entity.mapper.dart';

/// Enum para identificar os tipos de listas disponíveis no app
enum AppListType {
  specialties, // Especialidades
  talents, // Talentos
  eventTypes, // Tipos de evento
  supportSubjects, // Assuntos de suporte
}

/// Entidade que representa um item de lista estática do app
@MappableClass()
class AppListItemEntity with AppListItemEntityMappable {
  /// ID único do item (document ID no Firestore)
  final String? id;
  
  /// Nome/valor do item (ex: "Música", "Dança", "Comédia")
  final String name;
  
  /// Descrição opcional do item
  final String? description;
  
  /// Ordem de exibição
  final int? order;
  
  /// Indica se o item está ativo
  final bool isActive;
  
  /// Data de criação
  final DateTime? createdAt;
  
  /// Data de atualização
  final DateTime? updatedAt;

  AppListItemEntity({
    this.id,
    required this.name,
    this.description,
    this.order,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
}

extension AppListItemEntityReference on AppListItemEntity {
  /// Referência da coleção no Firestore baseada no tipo
  static CollectionReference firebaseCollectionReference(
    FirebaseFirestore firestore,
    AppListType listType,
  ) {
    final collectionName = _getCollectionName(listType);
    return firestore.collection('AppLists').doc(collectionName).collection('items');
  }

  /// Nome da coleção baseado no tipo
  static String _getCollectionName(AppListType listType) {
    switch (listType) {
      case AppListType.specialties:
        return 'specialties';
      case AppListType.talents:
        return 'talents';
      case AppListType.eventTypes:
        return 'eventTypes';
      case AppListType.supportSubjects:
        return 'supportSubjects';
    }
  }

  /// Chave de cache baseada no tipo de lista
  static String cachedKey(AppListType listType) {
    return 'CACHED_APP_LIST_${listType.name.toUpperCase()}';
  }
}

