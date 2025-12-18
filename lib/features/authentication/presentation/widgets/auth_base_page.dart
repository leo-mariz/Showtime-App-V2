import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/alternative_logo.dart';
import 'package:app/core/shared/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Widget base para páginas de autenticação
/// 
/// Utiliza o BasePage com configurações padrão e adiciona a logo
/// na parte superior. O conteúdo é passado via children.
class AuthBasePage extends StatelessWidget {
  /// Lista de widgets que serão exibidos abaixo da logo
  final List<Widget> children;

  final bool showBackButton;
  
  /// Tamanho da logo (default: 180)
  final double logoSize;
  
  /// Espaçamento entre a logo e o conteúdo (default: 32)
  final double logoSpacing;
  
  /// Alinhamento do conteúdo (default: center)
  final CrossAxisAlignment crossAxisAlignment;
  
  /// Alinhamento vertical do conteúdo (default: center)
  final MainAxisAlignment mainAxisAlignment;

  final String title;
  final String subtitle;

  const AuthBasePage({
    super.key,
    required this.children,
    this.showBackButton = true,
    this.logoSize = 180,
    this.logoSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return BasePage( // Padding personalizado ou padrão
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              DSSizedBoxSpacing.vertical(80),
                Text(
                  title,
                  style: textTheme.bodyLarge!.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                DSSizedBoxSpacing.vertical(10),
                Text(
                  subtitle,
                  style: textTheme.headlineLarge!.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                DSSizedBoxSpacing.vertical(30),
                ...children, // Conteúdo da página
              ]
            ),
          ),
          if (showBackButton)
            const BackButtonWidget(), // Seta de voltar fixa
          Positioned(
            top: DSSize.height(-15),
            left: DSSize.width(0),
            right: DSSize.width(0),
            child: Center(
              child: AlternativeLogo(size: 80),
            ),
          )        
          
        ],
      ),
    );
  }
}
