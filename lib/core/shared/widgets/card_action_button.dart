import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';

enum CardActionButtonType {
  default_,
  cancel,
  warning,
}

/// Botão específico para ações em cards de contrato
/// 
/// Diferente do CustomButton, este widget garante que:
/// - O ícone fica fixo à esquerda com padding adequado
/// - O texto sempre fica centralizado no botão
/// - Usa Row com espaçamento adequado ao invés de Stack
class CardActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final CardActionButtonType? buttonType;
  final double height;
  final bool isLoading;

  const CardActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.buttonType,
    this.height = 40,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final buttonHeight = DSSize.height(height);

    // Aplica estilos baseado no tipo de botão
    final bool effectiveFilled;
    final Color effectiveBackgroundColor;
    final Color effectiveTextColor;

    if (buttonType != null) {
      switch (buttonType!) {
        case CardActionButtonType.default_:
          effectiveFilled = true;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
          effectiveTextColor = textColor ?? colorScheme.primaryContainer;
          break;
        case CardActionButtonType.cancel:
          effectiveFilled = false;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
          effectiveTextColor = textColor ?? colorScheme.onPrimaryContainer;
          break;
        case CardActionButtonType.warning:
          effectiveFilled = true;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onError;
          effectiveTextColor = textColor ?? colorScheme.error;
          break;
      }
    } else {
      effectiveFilled = true;
      effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
      effectiveTextColor = textColor ?? colorScheme.primaryContainer;
    }

    final effectiveIconColor = iconColor ?? effectiveTextColor;

    // Conteúdo do botão: ícone à esquerda e texto centralizado
    Widget buildButtonContent() {
      if (isLoading) {
        // Loading: apenas indicador centralizado
        return SizedBox(
          width: DSSize.width(16),
          height: DSSize.width(16),
          child: CustomLoadingIndicator(
            strokeWidth: 2,
            color: effectiveTextColor,
          ),
        );
      }

      // Se tem ícone, usar Row com ícone à esquerda e texto centralizado
      if (icon != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone à esquerda com padding
            Padding(
              padding: EdgeInsets.only(right: DSSize.width(4)),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: DSSize.width(20),
              ),
            ),
            // Texto centralizado
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: calculateFontSize(16),
                fontWeight: FontWeight.bold,
                color: effectiveTextColor,
              ) ??
                  TextStyle(
                    fontSize: calculateFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: effectiveTextColor,
                  ),
            ),
          ],
        );
      } else {
        // Sem ícone: apenas texto centralizado
        return Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: calculateFontSize(16),
            fontWeight: FontWeight.bold,
            color: effectiveTextColor,
          ) ??
              TextStyle(
                fontSize: calculateFontSize(16),
                fontWeight: FontWeight.bold,
                color: effectiveTextColor,
              ),
        );
      }
    }

    final buttonContent = buildButtonContent();
    final isDisabled = isLoading || onPressed == null;

    if (isDisabled) {
      // Botão desabilitado
      return SizedBox(
        height: buttonHeight,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveFilled
                ? effectiveBackgroundColor.withOpacity(0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DSSize.width(30)),
            border: effectiveFilled
                ? null
                : Border.all(
                    color: effectiveBackgroundColor.withOpacity(0.6),
                    width: 1,
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: null,
              borderRadius: BorderRadius.circular(DSSize.width(30)),
              child: Center(child: buttonContent),
            ),
          ),
        ),
      );
    }

    // Botão habilitado
    return SizedBox(
      height: buttonHeight,
      child: effectiveFilled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveBackgroundColor,
                foregroundColor: effectiveTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSSize.width(30)),
                ),
              ),
              onPressed: onPressed,
              child: buttonContent,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSSize.width(30)),
                ),
                side: BorderSide(color: effectiveBackgroundColor, width: 1),
              ),
              onPressed: onPressed,
              child: buttonContent,
            ),
    );
  }
}

