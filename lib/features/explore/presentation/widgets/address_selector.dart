import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

/// Widget para seleção de endereço
///
/// Exibe o endereço atual, permitindo trocar ao clicar
class AddressSelector extends StatelessWidget {
  final String currentAddress;
  final VoidCallback onAddressTap;

  const AddressSelector({
    super.key,
    required this.currentAddress,
    required this.onAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return GestureDetector(
      onTap: onAddressTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DSSize.width(12),
          vertical: DSSize.height(8),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.05),
          border: Border.all(
            color: onPrimary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(DSSize.width(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                currentAddress,
                style: textTheme.bodySmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DSSizedBoxSpacing.horizontal(4),
            Icon(
              Icons.keyboard_arrow_down,
              color: onPrimary,
              size: DSSize.width(18),
            ),
          ],
        ),
      ),
    );
  }
}

