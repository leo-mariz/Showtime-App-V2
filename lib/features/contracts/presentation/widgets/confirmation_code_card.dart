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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ícone à esquerda
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: onPrimary,
                    size: DSSize.width(24),
                  ),
                ),
                // Código centralizado
                Text(
                  confirmationCode.toUpperCase(),
                  style: textTheme.headlineMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),

          DSSizedBoxSpacing.vertical(12),

          // Descrição
          Text(
            'Mostre este código para o artista na finalização do show para confirmar que o evento foi realizado.',
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

