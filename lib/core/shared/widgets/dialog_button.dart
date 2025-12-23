import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

/// Tipos de botão para dialogs
enum DialogButtonType {
  primary,   // Botão principal (filled)
  secondary, // Botão secundário (outlined)
  text,      // Botão de texto
}

/// Widget de botão customizável para uso em dialogs
class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final DialogButtonType type;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final Widget? icon;
  final bool expanded;

  const DialogButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = DialogButtonType.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  });

  /// Construtor para botão primário
  const DialogButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  }) : type = DialogButtonType.primary,
       borderColor = null;

  /// Construtor para botão secundário
  const DialogButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  }) : type = DialogButtonType.secondary;

  /// Construtor para botão de texto
  const DialogButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.foregroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  }) : type = DialogButtonType.text,
       backgroundColor = null,
       borderColor = null,
       borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = _buildButtonContent(theme);

    if (expanded) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    return buttonChild;
  }

  Widget _buildButtonContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (type) {
      case DialogButtonType.primary:
        final textColorToUse = textColor ?? colorScheme.primaryContainer;
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: foregroundColor ?? colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? DSSize.width(12),
              ),
            ),
            padding: padding ?? EdgeInsets.symmetric(
              vertical: DSSize.height(12),
              horizontal: DSSize.width(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: _buildContent(theme, textColorToUse),
        );

      case DialogButtonType.secondary:
        final textColorToUse = textColor ?? colorScheme.onPrimary;
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.error,
            foregroundColor: foregroundColor ?? colorScheme.error,
            side: BorderSide(
              color: borderColor ?? colorScheme.error,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? DSSize.width(12),
              ),
            ),
            padding: padding ?? EdgeInsets.symmetric(
              vertical: DSSize.height(12),
            ),
          ),
          child: _buildContent(theme, textColorToUse),
        );

      case DialogButtonType.text:
        final textColorToUse = textColor ?? colorScheme.onPrimary;
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: DSSize.width(12),
              vertical: DSSize.height(8),
            ),
          ),
          child: _buildContent(theme, textColorToUse),
        );
    }
  }

  Widget _buildContent(ThemeData theme, Color? textColor) {
    if (isLoading) {
      return SizedBox(
        height: DSSize.height(20),
        width: DSSize.width(20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize ?? DSSize.width(14),
        fontWeight: fontWeight ?? FontWeight.w600,
        color: textColor ?? theme.colorScheme.primaryContainer,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: DSSize.width(8)),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}

/// Widget para linha de botões em dialogs
class DialogButtonRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const DialogButtonRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      
      // Adiciona espaçamento entre os botões (exceto no último)
      if (i < children.length - 1) {
        widgets.add(SizedBox(width: DSSize.width(spacing)));
      }
    }
    
    return widgets;
  }
}