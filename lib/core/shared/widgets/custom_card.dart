import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Card padronizado do design system
/// 
/// Define as configurações padrão de estilo (cor, elevação, bordas)
/// que são usadas em todos os cards do app. Permite customização
/// quando necessário através dos parâmetros opcionais.
class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? customBorderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.borderRadius,
    this.margin,
    this.padding,
    this.onTap,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Valores padrão
    final defaultColor = color ?? colorScheme.surfaceContainerHighest;
    final defaultElevation = elevation ?? 1;
    final defaultBorderRadius = customBorderRadius ?? 
        BorderRadius.circular(DSSize.width(borderRadius ?? 16));
    final defaultPadding = padding ?? EdgeInsets.all(DSSize.width(12));

    Widget cardContent = Padding(
      padding: defaultPadding,
      child: child,
    );

    // Se tiver onTap, envolve com InkWell
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: defaultBorderRadius,
        child: cardContent,
      );
    }

    return Card(
      elevation: defaultElevation,
      shadowColor: Colors.transparent,
      color: defaultColor,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: defaultBorderRadius,
      ),
      child: cardContent,
    );
  }
}

