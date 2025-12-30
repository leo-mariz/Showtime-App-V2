import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Groups
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados
/// - Add: Criar dados
/// - Update: Atualizar dados
/// - Delete: Deletar dados
abstract class IGroupsRepository {
  // ==================== GET OPERATIONS ====================

  /// Busca dados do grupo no Firestore e salva no cache
  Future<Either<Failure, GroupEntity>> getGroup(String uid);
  
  /// Busca todos os grupos
  Future<Either<Failure, List<GroupEntity>>> getGroups();
  
  // ==================== ADD OPERATIONS ====================
  
  /// Salva dados do grupo no Firestore e cache
  Future<Either<Failure, void>> addGroup(String uid, GroupEntity group);

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza um grupo existente
  Future<Either<Failure, void>> updateGroup(String uid, GroupEntity group);

  // ==================== DELETE OPERATIONS ====================
  
  /// Deleta um grupo
  Future<Either<Failure, void>> deleteGroup(String uid);
}

