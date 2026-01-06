import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

/// Widget reutilizável para exibir mensagens informativas
/// 
/// Segue o design system do app e pode ser usado em qualquer lugar
/// onde seja necessário exibir informações importantes ao usuário.
/// 
/// Exemplo de uso:
/// ```dart
/// InformativeBanner(
///   message: 'Com a recorrência desativada, ficarão disponíveis todos os dias entre a data de início e a data de fim selecionadas.',
/// )
/// ```
class InformativeBanner extends StatelessWidget {
  /// Mensagem a ser exibida
  final String message;
  
  /// Ícone a ser exibido (padrão: Icons.info_outline)
  final IconData? icon;
  
  /// Cor de fundo do banner (opcional, usa primaryContainer por padrão)
  final Color? backgroundColor;
  
  /// Cor da borda (opcional, usa primary por padrão)
  final Color? borderColor;
  
  /// Cor do ícone (opcional, usa onPrimary por padrão)
  final Color? iconColor;
  
  /// Cor do texto (opcional, usa onSurface por padrão)
  final Color? textColor;

  const InformativeBanner({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effectiveBackgroundColor = backgroundColor ?? 
        colorScheme.primaryContainer.withOpacity(0.2);
    final effectiveBorderColor = borderColor ?? 
        colorScheme.primary.withOpacity(0.3);
    final effectiveIconColor = iconColor ?? colorScheme.onPrimary;
    final effectiveTextColor = textColor ?? 
        colorScheme.onSurface.withOpacity(0.8);

    return Container(
      padding: EdgeInsets.all(DSPadding.horizontal(12)),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: DSSize.width(18),
            color: effectiveIconColor,
          ),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: effectiveTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

