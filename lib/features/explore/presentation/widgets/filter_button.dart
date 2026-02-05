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
        icon: Icons.filter_alt_outlined,
        onPressed: onPressed,
        color: colorScheme.onPrimaryContainer,
        size: DSSize.width(20),
        backgroundColor: colorScheme.surface,
        padding: EdgeInsets.all(DSSize.width(12)),
        sizeBackground: Size(DSSize.width(30), DSSize.height(30)),
        showNotification: false,
      );
    }
  }
