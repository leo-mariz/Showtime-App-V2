import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class AlternativeLogo extends StatelessWidget {
  final double size;
  const AlternativeLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final double logoSize = DSSize.width(size);
    return Image.asset(
      'assets/icons/app_icon/icon.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
    );
  }
}
