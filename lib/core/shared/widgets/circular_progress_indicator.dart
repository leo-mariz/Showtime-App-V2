import 'dart:ui';
import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color ?? Theme.of(context).colorScheme.onPrimary,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? Theme.of(context).colorScheme.onPrimary),
      strokeWidth: strokeWidth ?? 2,
    );
  }
}

