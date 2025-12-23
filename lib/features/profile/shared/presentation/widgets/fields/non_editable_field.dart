import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

class NonEditableField extends StatelessWidget {
  final String title;
  final String value;

  const NonEditableField({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainerColor = colorScheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: onPrimary,
          ),
        ),
        DSSizedBoxSpacing.vertical(4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: onSurfaceContainerColor,
          ),
        ),
        Divider(color: onPrimaryContainerColor.withOpacity(0.3))
      ],
    );
  }
}

