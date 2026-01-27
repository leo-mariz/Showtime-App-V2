import 'package:app/core/utils/timestamp_hook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'user_contracts_index_entity.mapper.dart';

/// Entidade que representa o índice de contratos do usuário
/// 
/// Este documento é armazenado em: user_contracts_index/{userId}
/// 
/// IMPORTANTE: Separa contratos por ROLE (artista vs cliente)
/// - Quando o usuário tem perfil duplo, precisa diferenciar:
///   * Contratos onde ele é ARTISTA (refArtist)
///   * Contratos onde ele é CLIENTE (refClient)
/// 
/// ESTRUTURA:
/// - Contadores por role e tab (artistTab0Total, clientTab0Total, etc.)
/// - Contadores de não vistos por role e tab (artistTab0Unseen, clientTab0Unseen, etc.)
/// - Timestamps de última visualização por role e tab
/// - Timestamp de última atualização (lastUpdate)
@MappableClass(hook: TimestampHook())
class UserContractsIndexEntity with UserContractsIndexEntityMappable {
  // ==================== ARTISTA ====================
  
  /// Contador total de contratos do ARTISTA na Tab 0 (Em aberto)
  final int artistTab0Total;
  
  /// Contador total de contratos do ARTISTA na Tab 1 (Confirmadas)
  final int artistTab1Total;
  
  /// Contador total de contratos do ARTISTA na Tab 2 (Finalizadas)
  final int artistTab2Total;
  
  /// Contador de contratos não vistos do ARTISTA na Tab 0
  final int artistTab0Unseen;
  
  /// Contador de contratos não vistos do ARTISTA na Tab 1
  final int artistTab1Unseen;
  
  /// Contador de contratos não vistos do ARTISTA na Tab 2
  final int artistTab2Unseen;
  
  /// Timestamp da última visualização do ARTISTA na Tab 0
  final DateTime? lastSeenArtistTab0;
  
  /// Timestamp da última visualização do ARTISTA na Tab 1
  final DateTime? lastSeenArtistTab1;
  
  /// Timestamp da última visualização do ARTISTA na Tab 2
  final DateTime? lastSeenArtistTab2;

  // ==================== CLIENTE ====================
  
  /// Contador total de contratos do CLIENTE na Tab 0 (Em aberto)
  final int clientTab0Total;
  
  /// Contador total de contratos do CLIENTE na Tab 1 (Confirmadas)
  final int clientTab1Total;
  
  /// Contador total de contratos do CLIENTE na Tab 2 (Finalizadas)
  final int clientTab2Total;
  
  /// Contador de contratos não vistos do CLIENTE na Tab 0
  final int clientTab0Unseen;
  
  /// Contador de contratos não vistos do CLIENTE na Tab 1
  final int clientTab1Unseen;
  
  /// Contador de contratos não vistos do CLIENTE na Tab 2
  final int clientTab2Unseen;
  
  /// Timestamp da última visualização do CLIENTE na Tab 0
  final DateTime? lastSeenClientTab0;
  
  /// Timestamp da última visualização do CLIENTE na Tab 1
  final DateTime? lastSeenClientTab1;
  
  /// Timestamp da última visualização do CLIENTE na Tab 2
  final DateTime? lastSeenClientTab2;

  // ==================== METADADOS ====================
  
  /// Timestamp da última atualização do índice
  final DateTime? lastUpdate;

  UserContractsIndexEntity({
    // Artista
    this.artistTab0Total = 0,
    this.artistTab1Total = 0,
    this.artistTab2Total = 0,
    this.artistTab0Unseen = 0,
    this.artistTab1Unseen = 0,
    this.artistTab2Unseen = 0,
    this.lastSeenArtistTab0,
    this.lastSeenArtistTab1,
    this.lastSeenArtistTab2,
    // Cliente
    this.clientTab0Total = 0,
    this.clientTab1Total = 0,
    this.clientTab2Total = 0,
    this.clientTab0Unseen = 0,
    this.clientTab1Unseen = 0,
    this.clientTab2Unseen = 0,
    this.lastSeenClientTab0,
    this.lastSeenClientTab1,
    this.lastSeenClientTab2,
    // Metadados
    this.lastUpdate,
  });

  /// Retorna o total de contratos não vistos para um role específico (soma de todas as tabs)
  int getTotalUnseenForRole(bool isArtist) {
    if (isArtist) {
      return artistTab0Unseen + artistTab1Unseen + artistTab2Unseen;
    } else {
      return clientTab0Unseen + clientTab1Unseen + clientTab2Unseen;
    }
  }

  /// Verifica se há contratos não vistos para um role específico
  bool hasUnseenContractsForRole(bool isArtist) {
    return getTotalUnseenForRole(isArtist) > 0;
  }

  /// Retorna o contador de não vistos para uma tab específica de um role
  int getUnseenForTab(int tabIndex, bool isArtist) {
    if (isArtist) {
      switch (tabIndex) {
        case 0:
          return artistTab0Unseen;
        case 1:
          return artistTab1Unseen;
        case 2:
          return artistTab2Unseen;
        default:
          return 0;
      }
    } else {
      switch (tabIndex) {
        case 0:
          return clientTab0Unseen;
        case 1:
          return clientTab1Unseen;
        case 2:
          return clientTab2Unseen;
        default:
          return 0;
      }
    }
  }

  /// Retorna o contador total para uma tab específica de um role
  int getTotalForTab(int tabIndex, bool isArtist) {
    if (isArtist) {
      switch (tabIndex) {
        case 0:
          return artistTab0Total;
        case 1:
          return artistTab1Total;
        case 2:
          return artistTab2Total;
        default:
          return 0;
      }
    } else {
      switch (tabIndex) {
        case 0:
          return clientTab0Total;
        case 1:
          return clientTab1Total;
        case 2:
          return clientTab2Total;
        default:
          return 0;
      }
    }
  }

  /// Retorna o timestamp de última visualização para uma tab específica de um role
  DateTime? getLastSeenForTab(int tabIndex, bool isArtist) {
    if (isArtist) {
      switch (tabIndex) {
        case 0:
          return lastSeenArtistTab0;
        case 1:
          return lastSeenArtistTab1;
        case 2:
          return lastSeenArtistTab2;
        default:
          return null;
      }
    } else {
      switch (tabIndex) {
        case 0:
          return lastSeenClientTab0;
        case 1:
          return lastSeenClientTab1;
        case 2:
          return lastSeenClientTab2;
        default:
          return null;
      }
    }
  }
}

/// Extensão com métodos de referência do Firestore
extension UserContractsIndexEntityReference on UserContractsIndexEntity {
  /// Referência do documento do índice no Firestore
  static DocumentReference<Map<String, dynamic>> firebaseReference(
    FirebaseFirestore firestore,
    String userId,
  ) {
    return firestore.collection('user_contracts_index').doc(userId);
  }

  /// Stream do documento do índice no Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> firebaseStreamReference(
    FirebaseFirestore firestore,
    String userId,
  ) {
    return firestore.collection('user_contracts_index').doc(userId).snapshots();
  }

  /// Referência da coleção de índices
  static CollectionReference<Map<String, dynamic>> firebaseCollectionReference(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection('user_contracts_index');
  }
}
