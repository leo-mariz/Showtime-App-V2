import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Widget para exibir o código de confirmação do show
/// 
/// Exibido na tela do cliente quando o status é PAID
/// Permite copiar o código para compartilhar com o artista
class ConfirmationCodeCard extends StatelessWidget {
  final String confirmationCode;

  const ConfirmationCodeCard({
    super.key,
    required this.confirmationCode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;
    final primaryContainer = colorScheme.primaryContainer;

    return Container(
      padding: EdgeInsets.all(DSSize.width(20)),
      decoration: BoxDecoration(
        color: primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(DSSize.width(16)),
        border: Border.all(
          color: primaryContainer.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Código destacado
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: DSSize.width(16),
              vertical: DSSize.height(20),
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(DSSize.width(12)),
              border: Border.all(
                color: primaryContainer.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final codeText = confirmationCode.toUpperCase();
                final codeLength = codeText.length;
                
                // Ajusta o tamanho da fonte baseado no comprimento do código
                double fontSize;
                if (codeLength <= 8) {
                  fontSize = textTheme.headlineMedium?.fontSize ?? 28;
                } else if (codeLength <= 12) {
                  fontSize = textTheme.titleLarge?.fontSize ?? 24;
                } else {
                  fontSize = textTheme.titleMedium?.fontSize ?? 20;
                }
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícone
                    Icon(
                      Icons.vpn_key_rounded,
                      color: onPrimary,
                      size: DSSize.width(24),
                    ),
                    DSSizedBoxSpacing.horizontal(12),
                    // Código com quebra de linha quando necessário
                    Flexible(
                      child: Text(
                        codeText,
                        style: textTheme.headlineMedium?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          fontSize: fontSize,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          DSSizedBoxSpacing.vertical(12),

          // Descrição
          Text(
            'Mostre este código para o artista quando o show for ser iniciado.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

