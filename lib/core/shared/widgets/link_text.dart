import 'package:flutter/material.dart';

class CustomLinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? style;
  final Color? textColor;

  const CustomLinkText({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style ?? Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}