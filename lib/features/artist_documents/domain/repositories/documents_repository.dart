import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Documents
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Set: Salvar/atualizar documento
/// - Delete: Remover documento
abstract class IDocumentsRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca lista de documentos do artista
  /// Primeiro tenta buscar do cache, se não encontrar busca do remoto
  /// Retorna lista vazia se não existir
  Future<Either<Failure, List<DocumentsEntity>>> getDocuments(String artistId);
    
  /// Busca um documento específico por tipo (documentType)
  /// Busca diretamente do remoto para garantir dados atualizados
  /// Retorna null se não existir
  Future<Either<Failure, DocumentsEntity?>> getDocument(
    String artistId,
    String documentType,
  );

  // ==================== SET OPERATIONS ====================
  
  /// Salva/atualiza um documento na subcoleção
  /// O documentType é usado como ID do documento
  Future<Either<Failure, void>> setDocument(
    String artistId,
    DocumentsEntity document,
  );

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove um documento da subcoleção
  Future<Either<Failure, void>> deleteDocument(
    String artistId,
    String documentType,
  );
}

