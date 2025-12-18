// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;
  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _buildDecoration(theme, colorScheme),
      child: child,
    );
  }

  BoxDecoration _buildDecoration(ThemeData theme, ColorScheme colorScheme) {
      // Usar cor sólida de fundo do tema
      return BoxDecoration(
        color: colorScheme.surface,
      );
    }
}
