import 'package:app/core/users/domain/entities/cnpj/cnpj_user_entity.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
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
abstract class IUsersRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Retorna o UID do usuário em cache ou null
  Future<Either<Failure, String?>> getUserUid();

  /// Busca dados do usuário no Firestore e salva no cache
  Future<Either<Failure, UserEntity>> getUserData(String uid);

  // ==================== SET OPERATIONS ====================
  
  /// Salva dados do usuário no Firestore e cache
  Future<Either<Failure, void>> setUserData(UserEntity user);
  
  /// Salva dados CPF do usuário no Firestore
  Future<Either<Failure, void>> setCpfUserInfo(String uid, CpfUserEntity cpfUser);

  /// Salva dados CNPJ do usuário no Firestore
  Future<Either<Failure, void>> setCnpjUserInfo(String uid, CnpjUserEntity cnpjUser);

  // ==================== VERIFICATION OPERATIONS ====================
  
  /// Verifica se CPF já existe no banco
  Future<Either<Failure, bool>> cpfExists(String cpf);

  /// Verifica se CNPJ já existe no banco
  Future<Either<Failure, bool>> cnpjExists(String cnpj);

  /// Verifica se email já existe no banco
  Future<Either<Failure, bool>> emailExists(String email);
}
