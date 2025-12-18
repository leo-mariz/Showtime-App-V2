import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class CustomLogo extends StatelessWidget {
  final double size;
  const CustomLogo({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    final double logoSize = DSSize.width(size);
    return Image.asset(
      'assets/icons/logo/Logo.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
    );
  }
}
