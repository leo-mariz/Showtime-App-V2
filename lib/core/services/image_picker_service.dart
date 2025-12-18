import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Service para seleção e capturade imagens
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Seleciona uma imagem da galeria
  /// Retorna null se o usuário cancelar ou houver erro
  Future<File?> pickImageFromGallery() async {
    try {
      if (kDebugMode) {
        print('📷 ImagePickerService: Abrindo galeria...');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compressão para otimizar tamanho
        maxWidth: 1024,   // Tamanho máximo para evitar arquivos muito grandes
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          print('✅ ImagePickerService: Imagem selecionada da galeria: ${pickedFile.path}');
        }
        return File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('❌ ImagePickerService: Seleção cancelada pelo usuário');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao selecionar imagem da galeria: $e');
      }
      return null;
    }
  }

  /// Captura uma imagem usando a câmera
  /// Retorna null se o usuário cancelar ou houver erro
  Future<File?> captureImageFromCamera() async {
    try {
      if (kDebugMode) {
        print('📸 ImagePickerService: Abrindo câmera...');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compressão para otimizar tamanho
        maxWidth: 1024,   // Tamanho máximo para evitar arquivos muito grandes
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          print('✅ ImagePickerService: Foto capturada: ${pickedFile.path}');
        }
        return File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('❌ ImagePickerService: Captura cancelada pelo usuário');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao capturar imagem: $e');
      }
      return null;
    }
  }

  /// Verifica se a câmera está disponível no dispositivo
  Future<bool> isCameraAvailable() async {
    try {
      // Tenta acessar a câmera para verificar disponibilidade
      await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 1,
        maxWidth: 1,
        maxHeight: 1,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ImagePickerService: Câmera não disponível: $e');
      }
      return false;
    }
  }

  /// Valida se o arquivo é uma imagem válida
  bool isValidImageFile(File file) {
    try {
      final extension = file.path.toLowerCase().split('.').last;
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
      
      final isValid = validExtensions.contains(extension);
      
      if (kDebugMode) {
        print('🔍 ImagePickerService: Validando arquivo ${file.path}: ${isValid ? "✅ Válido" : "❌ Inválido"}');
      }
      
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao validar arquivo: $e');
      }
      return false;
    }
  }

  /// Obtém informações sobre o arquivo de imagem
  Future<Map<String, dynamic>?> getImageInfo(File file) async {
    try {
      final stat = await file.stat();
      final size = stat.size;
      final sizeInMB = size / (1024 * 1024);
      
      final info = {
        'path': file.path,
        'size': size,
        'sizeInMB': sizeInMB.toStringAsFixed(2),
        'lastModified': stat.modified,
      };
      
      if (kDebugMode) {
        print('📊 ImagePickerService: Info da imagem: $info');
      }
      
      return info;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao obter info da imagem: $e');
      }
      return null;
    }
  }
}
