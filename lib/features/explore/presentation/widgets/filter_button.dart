import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FilterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return CustomIconButton(
        icon: Icons.tune,
        onPressed: onPressed,
        color: colorScheme.onPrimary,
        size: DSSize.width(28),
        backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
        padding: EdgeInsets.all(DSSize.width(12)),
        sizeBackground: Size(DSSize.width(48), DSSize.height(48)),
        showNotification: false,
      );
    }
  }
