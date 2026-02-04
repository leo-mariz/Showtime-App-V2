import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado da seleção/captura de imagem.
/// [file] preenchido em sucesso; [errorMessage] preenchido quando usuário cancelou ou negou permissão.
class PickImageResult {
  final File? file;
  final String? errorMessage;

  const PickImageResult({this.file, this.errorMessage});

  bool get isPermissionDenied => errorMessage != null &&
      (errorMessage!.contains('permissão') ||
          errorMessage!.contains('permission') ||
          errorMessage!.toLowerCase().contains('denied') ||
          errorMessage!.toLowerCase().contains('access_denied'));
}

/// Service para seleção e captura de imagens.
/// Em caso de permissão negada ou cancelamento, retorna [PickImageResult] com [errorMessage] para exibir ao usuário.
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  String? _messageFromException(Object e, {required String contextLabel}) {
    if (e is PlatformException) {
      final code = e.code.toLowerCase();
      final message = e.message ?? '';
      if (code.contains('camera_access_denied') ||
          code.contains('photo_access_denied') ||
          code.contains('permission') ||
          message.toLowerCase().contains('permission') ||
          message.toLowerCase().contains('denied')) {
        return 'Acesso negado. Habilite câmera ou fotos nas configurações do app para continuar.';
      }
      if (code.contains('cancel') || message.toLowerCase().contains('cancel')) {
        return null; // cancelamento não precisa de mensagem
      }
      return message.isNotEmpty ? message : 'Não foi possível acessar $contextLabel.';
    }
    return 'Não foi possível acessar $contextLabel. Tente novamente.';
  }

  /// Seleciona uma imagem da galeria.
  /// Retorna [PickImageResult.file] em sucesso; [PickImageResult.errorMessage] se permissão negada ou erro.
  Future<PickImageResult> pickImageFromGallery() async {
    try {
      if (kDebugMode) {
        print('📷 ImagePickerService: Abrindo galeria...');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          print('✅ ImagePickerService: Imagem selecionada da galeria: ${pickedFile.path}');
        }
        return PickImageResult(file: File(pickedFile.path));
      } else {
        if (kDebugMode) {
          print('❌ ImagePickerService: Seleção cancelada pelo usuário');
        }
        return const PickImageResult(errorMessage: null); // cancelamento
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao selecionar imagem da galeria: $e');
      }
      return PickImageResult(
        errorMessage: _messageFromException(e, contextLabel: 'a galeria'),
      );
    }
  }

  /// Captura uma imagem usando a câmera.
  /// Retorna [PickImageResult.file] em sucesso; [PickImageResult.errorMessage] se permissão negada ou erro.
  Future<PickImageResult> captureImageFromCamera() async {
    try {
      if (kDebugMode) {
        print('📸 ImagePickerService: Abrindo câmera...');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          print('✅ ImagePickerService: Foto capturada: ${pickedFile.path}');
        }
        return PickImageResult(file: File(pickedFile.path));
      } else {
        if (kDebugMode) {
          print('❌ ImagePickerService: Captura cancelada pelo usuário');
        }
        return const PickImageResult(errorMessage: null); // cancelamento
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ImagePickerService: Erro ao capturar imagem: $e');
      }
      return PickImageResult(
        errorMessage: _messageFromException(e, contextLabel: 'a câmera'),
      );
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
