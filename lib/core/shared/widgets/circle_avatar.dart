import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onEdit;
  final bool isLoading;
  final bool showCameraIcon; // Mostra ícone de câmera ao invés de edit

  const CustomCircleAvatar({
    super.key,
    this.imageUrl,
    this.size = 54,
    this.onEdit,
    this.isLoading = false,
    this.showCameraIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.surfaceContainerHighest;
    final onPrimaryColor = colorScheme.onSurface;

    return Stack(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onEdit, // Desabilita tap durante carregamento
          child: CircleAvatar(
            backgroundColor: secondaryColor,
            radius: DSSize.width(size / 2),
            backgroundImage: imageUrl != null && !isLoading
                ? NetworkImage(imageUrl!)
                : null,
            child: _buildAvatarContent(onPrimaryColor),
          ),
        ),
        if (onEdit != null)
          Positioned(
            bottom: showCameraIcon ? -DSSize.height(-2) : 0,
            right: showCameraIcon ? -DSSize.width(-2) : 0,
            child: Container(
              width: DSSize.width(20),
              height: DSSize.height(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                // shape: BoxShape.circle,
                // border: Border.all(
                //   color: theme.colorScheme.surface,
                //   width: 2,
                // ),
              ),
              child: GestureDetector(
                onTap: onEdit,
                child: Icon(
                    showCameraIcon ? Icons.camera_alt : Icons.edit, 
                    color: onPrimaryColor, 
                    size: DSSize.width(16),
                  ),
              ),
            ),
          ),
        
      ],
    );
  }

  /// Constrói o conteúdo do avatar baseado no estado atual
  Widget? _buildAvatarContent(Color iconColor) {
    if (isLoading) {
      // Mostra loading
      return SizedBox(
        width: DSSize.width(size * 0.4),
        height: DSSize.height(size * 0.4),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }
    
    if (imageUrl == null) {
      // Mostra ícone de pessoa quando não há imagem
      return Icon(
        Icons.person, 
        size: DSSize.width(size * 0.6), 
        color: iconColor,
      );
    }
    
    // Retorna null quando há imagem (será mostrada via backgroundImage)
    return null;
  }
}