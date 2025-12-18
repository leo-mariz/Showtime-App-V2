import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

class ProfileOptionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? description;
  final VoidCallback onTap;
  final double? height;
  final bool showWarning;

  const ProfileOptionCard({
    required this.title,
    this.icon,
    this.iconColor,
    this.description,
    required this.onTap,
    this.height,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerHighestColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final outlineColor = colorScheme.onPrimaryContainer.withOpacity(0.4);
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    
    return GestureDetector(
        onTap: onTap,
        child: Container( // Removido o Expanded daqui
          padding: EdgeInsets.all(DSSize.width(16)),
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: surfaceContainerHighestColor,
          border: Border.all(color: outlineColor),
          ),
          height: height ?? DSSize.height(100),
          width: double.infinity,
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, color: iconColor ?? onPrimaryContainer, size: 24),
              DSSizedBoxSpacing.horizontal(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: calculateFontSize(22),
                      ),
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                        
                    DSSizedBoxSpacing.vertical(6),
                    if (description != null)
                    Text(
                      description ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w100,
                        color: onSurfaceContainerColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onPrimaryContainer,
                size: DSSize.width(20),
              ),
            ],
          ),
        ),
    );
  }
}
