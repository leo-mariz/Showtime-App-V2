import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para AppLists
/// Responsável APENAS por operações de leitura no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
abstract class IAppListsRemoteDataSource {
  /// Busca lista de itens por tipo
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<AppListItemEntity>> getListItems(AppListType listType);
}

/// Implementação do DataSource remoto usando Firestore
class AppListsRemoteDataSourceImpl implements IAppListsRemoteDataSource {
  final FirebaseFirestore firestore;

  AppListsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AppListItemEntity>> getListItems(AppListType listType) async {
    try {
      final collectionRef = AppListItemEntityReference.firebaseCollectionReference(
        firestore,
        listType,
      );

      final querySnapshot = await collectionRef
          .orderBy('order', descending: false)
          .orderBy('name', descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final entity = AppListItemEntityMapper.fromMap(data as Map<String, dynamic>);
        return entity.copyWith(id: doc.id);
      }).toList();

      return items;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar lista do Firestore',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar lista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

