import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing; // Widget personalizado para o lado direito
  final bool isFirst; // Indica se é a primeira opção
  final bool isLast; // Indica se é a última opção

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.showDivider = true,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = colorScheme.onPrimary;
    final textColor = colorScheme.onPrimary;
    final primaryContainerWithOpacity = colorScheme.surfaceContainerHighest;

    // Define o borderRadius baseado na posição do item
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 16 : 0),
      topRight: Radius.circular(isFirst ? 16 : 0),
      bottomLeft: Radius.circular(isLast ? 16 : 0),
      bottomRight: Radius.circular(isLast ? 16 : 0),
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Container( 
              height: DSSize.height(52), // Altura compacta
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(20)),
              decoration: BoxDecoration(
                color: primaryContainerWithOpacity,
                borderRadius: borderRadius,
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: DSSize.width(22)),
                  SizedBox(width: DSSize.width(16)),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  trailing ?? Icon(Icons.arrow_forward_ios, size: DSSize.width(16), color: iconColor),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: iconColor,
          ),
      ],
    );
  }
}