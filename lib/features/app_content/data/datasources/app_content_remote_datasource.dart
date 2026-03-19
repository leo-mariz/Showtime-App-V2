import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para AppContent.
abstract class IAppContentRemoteDataSource {
  /// Busca o conteúdo por tipo.
  /// Retorna entidade com content vazio se o documento não existir.
  Future<AppContentEntity> getContent(AppContentType type);
}

/// Implementação usando Firestore (coleção AppContent).
class AppContentRemoteDataSourceImpl implements IAppContentRemoteDataSource {
  final FirebaseFirestore firestore;

  AppContentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AppContentEntity> getContent(AppContentType type) async {
    try {
      final docRef = AppContentEntity.firebaseDocumentReference(firestore, type);
      final snapshot = await docRef.get();

      if (!snapshot.exists || snapshot.data() == null) {
        return const AppContentEntity(content: '');
      }

      final data = snapshot.data()!;
      final content = data['content'] as String? ?? '';
      final updatedAt = data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null;

      return AppContentEntity(content: content, updatedAt: updatedAt);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar conteúdo ${type.name}: ${e.message ?? e.code}',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar conteúdo ${type.name}: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
