import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? colorScheme.onPrimaryContainer;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: DSSize.width(32),
                color: effectiveIconColor,
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(12),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          DSSizedBoxSpacing.vertical(4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: onSurfaceVariant,
            ),
          ),
          if (subtitle != null) ...[
            DSSizedBoxSpacing.vertical(2),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
