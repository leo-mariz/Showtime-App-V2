
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

  // ==================== CACHE OPERATIONS ====================
  
  /// Limpa todo o cache local
  Future<Either<Failure, void>> clearCache();

  /// Imprime todo o cache local
  Future<Either<Failure, void>> printCache(String key);
}
