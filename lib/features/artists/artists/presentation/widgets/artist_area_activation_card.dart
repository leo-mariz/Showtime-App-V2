import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

class ArtistAreaActivationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const ArtistAreaActivationCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(24),
        vertical: DSSize.height(24),
      ),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: DSSize.width(24)),
          DSSizedBoxSpacing.horizontal(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          DSSizedBoxSpacing.horizontal(4),
          Switch(
            value: isActive,
            onChanged: isEnabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
