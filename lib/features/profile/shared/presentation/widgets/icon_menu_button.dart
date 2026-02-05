import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

class IconMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool showWarning;

  const IconMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.showWarning = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surfaceContainerHighest;
    final errorColor = colorScheme.error;
    final onPrimary = colorScheme.onPrimary;
    return 
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: DSSize.width(8)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(DSSize.width(16)),
                ),
                width: DSSize.width(65),
                height: DSSize.height(65),
                child: IconButton(
                  icon: Icon(icon, size: DSSize.width(30)),
                  onPressed: onPressed,
                ),
              ),
              if (showWarning)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                    padding: EdgeInsets.all(DSSize.width(4)),
                    decoration: BoxDecoration(
                      color: errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: DSSize.width(14),
                      color: onPrimary ,
                    ),
                  ),
                ),
              ],
            ),
          DSSizedBoxSpacing.vertical(8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
    );
  }
}
