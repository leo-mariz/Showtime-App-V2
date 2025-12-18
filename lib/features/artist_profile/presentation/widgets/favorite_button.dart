import 'package:app/core/shared/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';

/// Widget de botão de favorito
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return CustomIconButton(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      onPressed: onTap,
      color: isFavorite ? Colors.red : onPrimaryContainer,
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
    );
  }
}

