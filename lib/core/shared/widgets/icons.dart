import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class CustomIcons extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final double? width;
  final double? height;

  const CustomIcons({
    super.key,
    required this.onTap,
    required this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final size = width ?? DSSize.width(48);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: height ?? size,
        padding: EdgeInsets.all(DSSize.width(8)),
        decoration: BoxDecoration(
          // Fundo sutil que harmoniza com o tema
          borderRadius: BorderRadius.circular(DSSize.width(12)),
        ),
        child: Image.asset(
          icon,
          width: DSSize.width(32),
          height: DSSize.height(32),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}