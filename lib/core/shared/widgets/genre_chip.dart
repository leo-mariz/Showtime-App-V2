import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Widget de chip para exibir gêneros/estilos musicais
class GenreChip extends StatelessWidget {
  final String label;

  const GenreChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(6),
      ),
      decoration: BoxDecoration(
        color: onSurfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSSize.width(20)),
        border: Border.all(
          color: onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: onPrimary,
        ),
      ),
    );
  }
}

