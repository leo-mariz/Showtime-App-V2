import 'package:flutter/material.dart';

/// Widget reutilizável para exibir informações em formato de linha
/// com label à esquerda e valor à direita
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? highlightColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? highlightColor ?? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? highlightColor ?? colorScheme.onPrimary : colorScheme.onPrimary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

