import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Opções disponíveis para a imagem de perfil
enum ProfilePictureOption {
  view,
  gallery,
  camera,
  remove,
}

/// Widget que exibe as opções de ação para a foto de perfil
class ProfilePictureOptionsMenu extends StatelessWidget {
  final bool hasImage;
  final Function(ProfilePictureOption) onOptionSelected;

  const ProfilePictureOptionsMenu({
    super.key,
    required this.hasImage,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle do modal
          Container(
            margin: EdgeInsets.only(top: DSSize.height(8)),
            width: DSSize.width(40),
            height: DSSize.height(4),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4 * 255),
              borderRadius: BorderRadius.circular(DSSize.width(2)),
            ),
          ),

          DSSizedBoxSpacing.vertical(16),

          // Título
          Text(
            'Foto de perfil',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),

          DSSizedBoxSpacing.vertical(24),

          // Opções
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
            child: Column(
              children: [
                // Visualizar imagem (só aparece se tem imagem)
                if (hasImage)
                  _buildOptionTile(
                    context,
                    icon: Icons.visibility,
                    title: 'Visualizar imagem',
                    onTap: () => onOptionSelected(ProfilePictureOption.view),
                  ),

                // Escolher da galeria
                _buildOptionTile(
                  context,
                  icon: Icons.photo_library,
                  title: 'Escolher da galeria',
                  onTap: () => onOptionSelected(ProfilePictureOption.gallery),
                ),

                // Tirar foto
                _buildOptionTile(
                  context,
                  icon: Icons.camera_alt,
                  title: 'Tirar foto',
                  onTap: () => onOptionSelected(ProfilePictureOption.camera),
                ),

                // Remover imagem (só aparece se tem imagem)
                if (hasImage)
                  _buildOptionTile(
                    context,
                    icon: Icons.delete,
                    title: 'Remover imagem',
                    onTap: () => onOptionSelected(ProfilePictureOption.remove),
                    isDestructive: true,
                  ),
              ],
            ),
          ),

          DSSizedBoxSpacing.vertical(24),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final textColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSSize.width(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: DSSize.width(16),
          vertical: DSSize.height(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: DSSize.width(24),
            ),
            DSSizedBoxSpacing.horizontal(16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método estático para mostrar o modal
  static Future<ProfilePictureOption?> show(
    BuildContext context, {
    required bool hasImage,
  }) async {
    return await showModalBottomSheet<ProfilePictureOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfilePictureOptionsMenu(
        hasImage: hasImage,
        onOptionSelected: (option) {
          Navigator.of(context).pop(option);
        },
      ),
    );
  }
}
