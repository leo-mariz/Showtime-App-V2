import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Widget de badge de avaliação no formato x,x ⭐
class CustomBadge extends StatelessWidget {
  final String? title;
  final String value;
  final TextStyle? valueStyle;
  final IconData? icon;
  final Color? color;

  const CustomBadge({
    super.key,
    this.title,
    required this.value,
    this.valueStyle,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(6),
      ),
      decoration: BoxDecoration(
        color: onPrimaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(DSSize.width(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: valueStyle ?? textTheme.bodyMedium?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: DSSize.width(4)),
          if (icon != null) ...[
            Icon(
              icon,
              color: onPrimaryContainer,
              size: DSSize.width(16),
            ),
          ],
          if (title != null) ...[
            SizedBox(width: DSSize.width(4)),
            Text(
              title!,
              style: textTheme.bodySmall?.copyWith(
                color: onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

