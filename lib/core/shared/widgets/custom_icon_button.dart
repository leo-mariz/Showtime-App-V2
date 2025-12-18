import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.backgroundColor,
    this.padding,
    this.sizeBackground,
    this.showNotification = false,
  });

  final IconData icon;
  final Color? color;
  final double? size;
  final EdgeInsets? padding;
  final Size? sizeBackground;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color ?? colorScheme.onSurface, size: size),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            minimumSize: sizeBackground ?? Size(DSSize.width(48), DSSize.height(48)),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSSize.width(16)),
            ),
          ),
        ),
        if (showNotification)
        Positioned(
          top: DSSize.height(0),
          right: DSSize.width(0),
          child: Container(
            width: DSSize.width(10),
            height: DSSize.height(10),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
