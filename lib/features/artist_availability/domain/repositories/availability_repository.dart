import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Availability
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Create: Adicionar nova disponibilidade
/// - Update: Atualizar disponibilidade existente
/// - Delete: Remover disponibilidade
abstract class IAvailabilityRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca lista de disponibilidades do artista
  /// Primeiro tenta buscar do cache, se não encontrar busca do remoto
  /// Retorna lista vazia se não existir
  Future<Either<Failure, List<AvailabilityEntity>>> getAvailabilities(String artistId);
    
  /// Busca uma disponibilidade específica por ID
  /// Busca diretamente do remoto para garantir dados atualizados
  Future<Either<Failure, AvailabilityEntity>> getAvailability(
    String artistId,
    String availabilityId,
  );

  // ==================== CREATE OPERATIONS ====================
  
  /// Adiciona uma nova disponibilidade à subcoleção do artista
  /// Retorna o ID da disponibilidade criada
  Future<Either<Failure, String>> addAvailability(
    String artistId,
    AvailabilityEntity availability,
  );

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza uma disponibilidade existente na subcoleção
  Future<Either<Failure, void>> updateAvailability(
    String artistId,
    AvailabilityEntity availability,
  );

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove uma disponibilidade da subcoleção
  Future<Either<Failure, void>> deleteAvailability(
    String artistId,
    String availabilityId,
  );

  // ==================== REPLACE OPERATIONS ====================
  
  /// Substitui todas as disponibilidades do artista (deleta antigas e adiciona novas)
  /// Usa batch operations para garantir atomicidade e eficiência
  /// Ideal para operações que modificam múltiplas disponibilidades
  Future<Either<Failure, void>> replaceAvailabilities(
    String artistId,
    List<AvailabilityEntity> newAvailabilities,
  );
}

