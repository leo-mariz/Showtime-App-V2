import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/domain/user/cnpj/cnpj_user_entity.dart';
import 'package:app/core/domain/user/cpf/cpf_user_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Autenticação
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados
/// - Set: Salvar dados
/// - Verification: Verificar existência
/// - Cache: Operações de cache
abstract class IAuthRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Retorna o UID do usuário em cache ou null
  Future<Either<Failure, String?>> getUserUid();

  /// Busca dados do usuário no Firestore e salva no cache
  Future<Either<Failure, UserEntity>> getUserData(String uid);
  
  /// Busca dados do artista no Firestore e salva no cache
  Future<Either<Failure, ArtistEntity>> getArtistData(String uid);
  
  /// Busca dados do cliente no Firestore e salva no cache
  Future<Either<Failure, ClientEntity>> getClientData(String uid);

  // ==================== SET OPERATIONS ====================
  
  /// Salva dados do usuário no Firestore e cache
  Future<Either<Failure, void>> setUserData(UserEntity user);
  
  /// Salva dados CPF do usuário no Firestore
  Future<Either<Failure, void>> setCpfUserInfo(String uid, CpfUserEntity cpfUser);

  /// Salva dados CNPJ do usuário no Firestore
  Future<Either<Failure, void>> setCnpjUserInfo(String uid, CnpjUserEntity cnpjUser);

  /// Salva dados do artista no Firestore e cache
  Future<Either<Failure, void>> setArtistData(String uid, ArtistEntity artist);

  /// Salva dados do cliente no Firestore e cache
  Future<Either<Failure, void>> setClientData(String uid, ClientEntity client);

  // ==================== VERIFICATION OPERATIONS ====================
  
  /// Verifica se CPF já existe no banco
  Future<Either<Failure, bool>> cpfExists(String cpf);

  /// Verifica se CNPJ já existe no banco
  Future<Either<Failure, bool>> cnpjExists(String cnpj);

  /// Verifica se email já existe no banco
  Future<Either<Failure, bool>> emailExists(String email);

  // ==================== CACHE OPERATIONS ====================
  
  /// Limpa todo o cache local
  Future<Either<Failure, void>> clearCache();
}
