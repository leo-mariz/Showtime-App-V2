import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para BankAccount
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IBankAccountRemoteDataSource {
  /// Busca a conta bancária do artista
  /// Retorna null se não existir
  /// Lança [ServerException] em caso de erro
  Future<BankAccountEntity?> getBankAccount(String artistId);
  
  /// Salva ou atualiza a conta bancária do artista
  /// Como cada artista tem apenas uma conta, sempre salva no documento "account"
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId não estiver presente
  Future<void> saveBankAccount(String artistId, BankAccountEntity bankAccount);
  
  /// Remove a conta bancária do artista
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se a conta não existir
  Future<void> deleteBankAccount(String artistId);
}

/// Implementação do DataSource remoto usando Firestore
class BankAccountRemoteDataSourceImpl implements IBankAccountRemoteDataSource {
  final FirebaseFirestore firestore;

  BankAccountRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BankAccountEntity?> getBankAccount(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final documentReference = BankAccountEntityReference.firebaseUidReference(
        firestore,
        artistId,
      );
      
      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        return null;
      }

      final bankAccountMap = snapshot.data() as Map<String, dynamic>;
      return BankAccountEntityMapper.fromMap(bankAccountMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar conta bancária no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar conta bancária',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> saveBankAccount(String artistId, BankAccountEntity bankAccount) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final documentReference = BankAccountEntityReference.firebaseUidReference(
        firestore,
        artistId,
      );

      final bankAccountMap = bankAccount.toMap();
      await documentReference.set(bankAccountMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar conta bancária no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao salvar conta bancária',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteBankAccount(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final documentReference = BankAccountEntityReference.firebaseUidReference(
        firestore,
        artistId,
      );

      // Verifica se o documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException(
          'Conta bancária não encontrada',
        );
      }

      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar conta bancária no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao deletar conta bancária',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

