import 'package:flutter/foundation.dart';
import 'package:app/core/config/setup_locator.dart';
import 'package:app/core/services/image_cache_service.dart';

class ImagePreloaderService {
  static final ImagePreloaderService _instance = ImagePreloaderService._internal();
  factory ImagePreloaderService() => _instance;
  ImagePreloaderService._internal();

  final IImageCacheService _imageCacheService = getIt<IImageCacheService>();

  /// Pré-carrega imagens importantes do app
  Future<void> preloadImportantImages({
    String? logoUrl,
    List<String>? additionalImages,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Iniciando pré-carregamento de imagens...');
      }

      final imagesToPreload = <String>[];

      // Adiciona a logo se fornecida
      if (logoUrl != null && logoUrl.isNotEmpty) {
        imagesToPreload.add(logoUrl);
      }

      // Adiciona imagens adicionais
      if (additionalImages != null) {
        imagesToPreload.addAll(additionalImages);
      }

      // Pré-carrega todas as imagens em paralelo
      await Future.wait(
        imagesToPreload.map((imageUrl) => _imageCacheService.preloadImage(imageUrl)),
      );

      if (kDebugMode) {
        print('✅ Pré-carregamento de imagens concluído');
        print('📊 Total de imagens pré-carregadas: ${imagesToPreload.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no pré-carregamento de imagens: $e');
      }
    }
  }

  /// Pré-carrega imagens baseadas na configuração do app
  Future<void> preloadAppImages(String logoUrl) async {
    await preloadImportantImages(
      logoUrl: logoUrl,
      additionalImages: [
        // Adicione aqui outras imagens importantes do app
        // 'https://example.com/background.jpg',
        // 'https://example.com/icon.png',
      ],
    );
  }

  /// Verifica se uma imagem específica está em cache
  Future<bool> isImageCached(String imageUrl) async {
    return await _imageCacheService.isImageCached(imageUrl);
  }

  /// Limpa o cache de imagens
  Future<void> clearImageCache() async {
    await _imageCacheService.clearImageCache();
  }
}

