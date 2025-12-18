import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Widget de badge de número de contratos finalizados
class ContractsBadge extends StatelessWidget {
  final int contracts;

  const ContractsBadge({
    super.key,
    required this.contracts,
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
            '$contracts',
            style: textTheme.bodyMedium?.copyWith(
              color: onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: DSSize.width(4)),
          Text(
            'Contratos',
            style: textTheme.bodySmall?.copyWith(
              color: onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

