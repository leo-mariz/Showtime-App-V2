import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:app/core/errors/exceptions.dart';

abstract class IStorageService {
  /// Faz upload de um arquivo para o Firebase Storage
  /// 
  /// Suporta qualquer tipo de arquivo: imagens, vídeos, documentos, etc.
  /// 
  /// [reference] - Referência do Firebase Storage onde o arquivo será salvo
  /// [localFilePath] - Caminho local do arquivo a ser enviado
  /// 
  /// Retorna a URL de download do arquivo após o upload
  /// Lança [ServerException] ou [NetworkException] em caso de erro
  Future<String> uploadFileToFirebaseStorage(
    Reference reference,
    String localFilePath,
  );

  /// Deleta um arquivo do Firebase Storage
  /// 
  /// Suporta qualquer tipo de arquivo: imagens, vídeos, documentos, etc.
  /// 
  /// [downloadUrl] - URL de download do arquivo no Firebase Storage
  /// 
  /// Lança [ServerException], [NetworkException] ou [NotFoundException] em caso de erro
  Future<void> deleteFileFromFirebaseStorage(String downloadUrl);
}

class StorageService implements IStorageService {
  @override
  Future<String> uploadFileToFirebaseStorage(
    Reference reference,
    String localFilePath,
  ) async {
    try {
      // Validar se o arquivo existe
      final file = File(localFilePath);
      if (!await file.exists()) {
        throw const ValidationException('Arquivo não encontrado no caminho especificado');
      }

      // Criar nome único para o arquivo
      final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = reference.child(uniqueFileName);

      // Fazer upload do arquivo
      await storageRef.putFile(file);

      // Obter URL de download
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } on AppException {
      // Re-lança exceções já tipadas
      rethrow;
    } catch (e, stackTrace) {
      // Verificar se é erro de rede
      if (e.toString().contains('network') || 
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        throw NetworkException(
          'Erro de conexão ao fazer upload do arquivo',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
      
      throw ServerException(
        'Erro ao fazer upload do arquivo para o Firebase Storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteFileFromFirebaseStorage(String downloadUrl) async {
    try {
      // Validar se a URL é válida
      if (downloadUrl.isEmpty) {
        throw const ValidationException('URL de download não pode ser vazia');
      }

      // Obter referência do arquivo a partir da URL
      final fileReference = FirebaseStorage.instance.refFromURL(downloadUrl);
      
      // Deletar arquivo
      await fileReference.delete();
    } on AppException {
      // Re-lança exceções já tipadas
      rethrow;
    } catch (e, stackTrace) {
      // Verificar se é erro de rede
      if (e.toString().contains('network') || 
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        throw NetworkException(
          'Erro de conexão ao deletar arquivo',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      // Verificar se o arquivo não foi encontrado
      if (e.toString().contains('not found') || 
          e.toString().contains('object-not-found')) {
        throw const NotFoundException('Arquivo não encontrado no Firebase Storage');
      }

      throw ServerException(
        'Erro ao deletar arquivo do Firebase Storage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}