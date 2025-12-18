import 'package:app/core/services/image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/config/setup_locator.dart';

class CachedAppLogo extends StatelessWidget {
  final double size;
  final String? logoUrl;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedAppLogo({
    super.key,
    this.size = 120,
    this.logoUrl,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imageCacheService = getIt<IImageCacheService>();
    final double logoSize = DSSize.width(size);
    
    // Se não tiver URL, usa a logo local
    if (logoUrl == null || logoUrl!.isEmpty) {
      return Image.asset(
        'assets/icons/logo.png',
        width: logoSize,
        height: logoSize,
        fit: fit ?? BoxFit.contain,
      );
    }

    // Carrega a logo da URL com cache
    return imageCacheService.loadImage(
      imageUrl: logoUrl!,
      width: logoSize,
      height: logoSize,
      fit: fit ?? BoxFit.contain,
      placeholder: placeholder ?? _defaultPlaceholder(logoSize),
      errorWidget: errorWidget ?? _defaultErrorWidget(logoSize),
    );
  }

  Widget _defaultPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
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
