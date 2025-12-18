import 'package:flutter/material.dart';

class CustomLeadingButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;

  const CustomLeadingButton({super.key, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final colorScheme = theme.colorScheme;
    
    return IconButton(
      icon: isIOS
          ? Icon(Icons.arrow_back_ios_new, color: color ?? colorScheme.secondary)
          : Icon(Icons.arrow_back, color: color ?? colorScheme.secondary),
      onPressed: onTap ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Voltar',
    );
  }
}