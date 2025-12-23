import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Addresses
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Create: Adicionar novo endereço
/// - Update: Atualizar endereço existente
/// - Delete: Remover endereço
/// - SetPrimary: Definir endereço como primário
abstract class IAddressesRepository {
  // ==================== GET OPERATIONS ====================
  
  Future<Either<Failure, List<AddressInfoEntity>>> getAddresses(String uid);

  // ==================== CREATE OPERATIONS ====================
  
  /// Adiciona um novo endereço à subcoleção do usuário
  /// Retorna o ID do endereço criado
  Future<Either<Failure, String>> addAddress(String uid, AddressInfoEntity address);

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza um endereço existente na subcoleção
  Future<Either<Failure, void>> updateAddress(
    String uid,
    String addressId,
    AddressInfoEntity address,
  );

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove um endereço da subcoleção
  Future<Either<Failure, void>> deleteAddress(String uid, String addressId);

  // ==================== SET PRIMARY OPERATIONS ====================
  
  /// Define um endereço como primário (e remove primário dos outros)
  Future<Either<Failure, void>> setPrimaryAddress(String uid, String addressId);
}

