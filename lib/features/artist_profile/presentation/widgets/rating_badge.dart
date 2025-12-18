import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Widget de badge de avaliação no formato x,x ⭐
class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

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
            rating.toStringAsFixed(1),
            style: textTheme.bodyMedium?.copyWith(
              color: onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: DSSize.width(4)),
          Icon(
            Icons.star,
            color: onPrimaryContainer,
            size: DSSize.width(16),
          ),
        ],
      ),
    );
  }
}

