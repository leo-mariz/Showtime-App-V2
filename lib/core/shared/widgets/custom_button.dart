import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
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
  final bool isLoading;

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
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double? buttonWidth = width > 0 ? DSSize.width(width) : null;
    final double buttonHeight = height > 0 ? DSSize.height(height) : DSSize.height(48);
    
    // Aplica estilos baseado no tipo de botão
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
      effectiveFilled = filled;
      effectiveBackgroundColor = backgroundColor ?? colorScheme.onPrimaryContainer;
      effectiveTextColor = textColor ?? colorScheme.primaryContainer;
    }
    
    final effectiveIconColor = iconColor ?? effectiveTextColor;
    
    // Construir o conteúdo do botão
    Widget buildButtonContent() {
      // Widget de texto
      final textWidget = Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: calculateFontSize(16),
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
        ) ?? TextStyle(
          fontSize: calculateFontSize(16),
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
        ),
      );
      
      // Indicador de loading
      final loadingIndicator = SizedBox(
        width: DSSize.width(16),
        height: DSSize.width(16),
        child: CustomLoadingIndicator(
          strokeWidth: 2,
          color: effectiveTextColor,
        ),
      );
      
      // Se tem ícone, usar Stack
      if (icon != null) {
        return Stack(
          children: [
            // Ícone à esquerda
            if (iconOnLeft)
              Positioned(
                left: DSSize.width(8),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              ),
            // Ícone à direita
            if (iconOnRight)
              Positioned(
                right: DSSize.width(8),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              ),
            // Ícone padrão (esquerda se não especificado)
            if (!iconOnLeft && !iconOnRight)
              Positioned(
                left: DSSize.width(8),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: DSSize.width(20),
                  ),
                ),
              ),
            // Conteúdo central (texto + loading)
            
            Center(
              child: isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        textWidget,
                        DSSizedBoxSpacing.horizontal(8),
                        loadingIndicator,
                      ],
                    )
                  : textWidget,
            ),
          ],
        );
      } else {
        // Sem ícone: apenas texto + loading
        return isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  textWidget,
                  DSSizedBoxSpacing.horizontal(8),
                  loadingIndicator,
                ],
              )
            : textWidget;
      }
    }
    
    // Criar o conteúdo uma vez
    final buttonContent = buildButtonContent();
    
    // Usar GestureDetector quando desabilitado para garantir que o conteúdo seja renderizado
    final isDisabled = isLoading || onPressed == null;
    
    if (isDisabled) {
      // Quando desabilitado, usar Container com GestureDetector para garantir renderização
      return SizedBox(
        width: buttonWidth,
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
              onTap: null, // Sempre null quando desabilitado
              borderRadius: BorderRadius.circular(DSSize.width(30)),
              child: Center(
                child: buttonContent,
              ),
            ),
          ),
        ),
      );
    }
    
    // Quando habilitado, usar ElevatedButton ou OutlinedButton normalmente
    return SizedBox(
      width: buttonWidth ?? double.infinity,
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