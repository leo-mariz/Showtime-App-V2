import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

abstract class IImageCacheService {
  /// Carrega uma imagem da URL com cache automático
  Widget loadImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  });

  /// Pré-carrega uma imagem no cache
  Future<void> preloadImage(String imageUrl);

  /// Limpa o cache de imagens
  Future<void> clearImageCache();

  /// Verifica se uma imagem está em cache
  Future<bool> isImageCached(String imageUrl);
}

class ImageCacheService implements IImageCacheService {
  @override
  Widget loadImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      // Configurações de cache
      cacheKey: _generateCacheKey(imageUrl),
      maxWidthDiskCache: 1024,
      maxHeightDiskCache: 1024,
      memCacheWidth: 1024,
      memCacheHeight: 1024,
      // Configurações de rede
      httpHeaders: const {
        'User-Agent': 'VimbleApp/1.0',
      },
    );
  }

  @override
  Future<void> preloadImage(String imageUrl) async {
    try {
      // Pré-carrega a imagem usando CachedNetworkImageProvider
      final imageProvider = CachedNetworkImageProvider(
        imageUrl,
        cacheKey: _generateCacheKey(imageUrl),
      );
      
      // Força o carregamento da imagem
      imageProvider.resolve(const ImageConfiguration());
      
      if (kDebugMode) {
        print('✅ Imagem pré-carregada: $imageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao pré-carregar imagem: $imageUrl - $e');
      }
    }
  }

  @override
  Future<void> clearImageCache() async {
    try {
      // Limpa o cache de imagens do Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      if (kDebugMode) {
        print('✅ Cache de imagens limpo com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao limpar cache de imagens: $e');
      }
    }
  }

  @override
  Future<bool> isImageCached(String imageUrl) async {
    try {
      // Verifica se a imagem está em cache usando o ImageCache do Flutter
      final cacheKey = _generateCacheKey(imageUrl);
      final imageProvider = CachedNetworkImageProvider(imageUrl, cacheKey: cacheKey);
      
      // Tenta resolver a imagem
      final stream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<bool>();
      
      stream.addListener(ImageStreamListener((info, _) {
        completer.complete(true);
      }, onError: (error, _) {
        completer.complete(false);
      }));
      
      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar cache da imagem: $e');
      }
      return false;
    }
  }

  /// Gera uma chave única para o cache baseada na URL
  String _generateCacheKey(String imageUrl) {
    // Remove parâmetros de query para evitar duplicação
    final uri = Uri.parse(imageUrl);
    final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
    return cleanUrl.hashCode.toString();
  }

  /// Widget padrão de placeholder
  Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Widget padrão de erro
  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
