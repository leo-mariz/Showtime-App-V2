import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de conteúdo editável do app (documentos na coleção AppContent).
enum AppContentType {
  termsOfUse,
  privacyPolicy,
}

/// Entidade que representa um documento de conteúdo do app (Termos de Uso, Política de Privacidade).
class AppContentEntity {
  /// Texto completo do conteúdo.
  final String content;

  /// Data/hora da última atualização (admin).
  final DateTime? updatedAt;

  const AppContentEntity({
    required this.content,
    this.updatedAt,
  });

  /// ID do documento no Firestore para o tipo.
  static String documentId(AppContentType type) {
    switch (type) {
      case AppContentType.termsOfUse:
        return 'termsOfUse';
      case AppContentType.privacyPolicy:
        return 'privacyPolicy';
    }
  }

  /// Referência do documento no Firestore.
  static DocumentReference<Map<String, dynamic>> firebaseDocumentReference(
    FirebaseFirestore firestore,
    AppContentType type,
  ) {
    return firestore.collection('AppContent').doc(documentId(type));
  }

  /// Chave de cache por tipo.
  static String cachedKey(AppContentType type) {
    return 'CACHED_APP_CONTENT_${type.name}';
  }
}
