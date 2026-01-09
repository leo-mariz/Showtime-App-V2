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

      // Buscar todos os documentos (sem orderBy duplo para evitar necessidade de índice composto)
      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final entity = AppListItemEntityMapper.fromMap(data as Map<String, dynamic>);
        return entity.copyWith(id: doc.id);
      }).toList();

      // Ordenar em memória: primeiro por order (null vai para o final), depois por name
      items.sort((a, b) {
        // Primeiro ordena por order (se ambos tiverem order)
        final orderA = a.order ?? 999999;
        final orderB = b.order ?? 999999;
        
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
        
        // Se order for igual, ordena por nome
        return a.name.compareTo(b.name);
      });

      return items;
    } on FirebaseException catch (e, stackTrace) {
      // Log mais detalhado do erro do Firestore
      print('❌ [AppLists] Erro do Firestore ao buscar ${listType.name}:');
      print('   Código: ${e.code}');
      print('   Mensagem: ${e.message}');
      print('   StackTrace: $stackTrace');
      
      throw ServerException(
        'Erro ao buscar lista ${listType.name} do Firestore: ${e.message ?? e.code}',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // Log de erros inesperados
      print('❌ [AppLists] Erro inesperado ao buscar ${listType.name}:');
      print('   Erro: $e');
      print('   StackTrace: $stackTrace');
      
      throw ServerException(
        'Erro inesperado ao buscar lista ${listType.name}: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

