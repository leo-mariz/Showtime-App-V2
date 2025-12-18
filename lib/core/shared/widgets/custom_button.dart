import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/font/font_size_calculator.dart';

enum CustomButtonType {
  default_,
  cancel,
  warning,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final double width;
  final double height;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool iconOnRight;
  final bool iconOnLeft;
  final CustomButtonType? buttonType;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.width = 0,
    this.height = 0,
    this.icon,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.iconOnRight = false,
    this.iconOnLeft = false,
    this.buttonType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double buttonWidth = width > 0 ? DSSize.width(width) : double.infinity;
    final double buttonHeight = height > 0 ? DSSize.height(height) : DSSize.height(48);
    
    // Aplica estilos baseado no tipo de botão, se especificado
    final bool effectiveFilled;
    final Color effectiveBackgroundColor;
    final Color effectiveTextColor;
    
    if (buttonType != null) {
      switch (buttonType!) {
        case CustomButtonType.default_:
          effectiveFilled = filled;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
          effectiveTextColor = textColor ?? colorScheme.primaryContainer;
          break;
        case CustomButtonType.cancel:
          effectiveFilled = false;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
          effectiveTextColor = textColor ?? colorScheme.onPrimaryContainer;
          break;
        case CustomButtonType.warning:
          effectiveFilled = true;
          effectiveBackgroundColor = backgroundColor ?? colorScheme.onError;
          effectiveTextColor = textColor ?? colorScheme.error;
          break;
      }
    } else {
      // Mantém comportamento padrão se tipo não especificado
      effectiveFilled = filled;
      effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
      effectiveTextColor = textColor ?? colorScheme.primaryContainer;
    }
    
    // Determina a cor do ícone baseado no tipo de botão
    final effectiveIconColor = iconColor ?? effectiveTextColor;
    
    // Widget de conteúdo (texto + ícone opcional)
    Widget buildContent(Color textColorToUse) {
      if (icon == null) {
        // Sem ícone: apenas texto centralizado
        return Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: calculateFontSize(16),
            fontWeight: FontWeight.bold,
            color: textColorToUse,
          ),
        );
      } else {
        // Com ícone: usa Stack para posicionar ícone e texto
        return Stack(
          children: [
            if (iconOnLeft) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: DSSize.width(8)),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              ),
              DSSizedBoxSpacing.horizontal(100),
            ],
            if (iconOnRight)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: DSSize.width(8)),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: DSSize.width(8)),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: calculateFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: textColorToUse,
                ),
              ),
            ),
          ],
        );
      }
    }
    
    return SizedBox(
      width: buttonWidth,
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
              child: buildContent(effectiveTextColor),
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
              child: buildContent(effectiveTextColor),
            ),
    );
  }
}


