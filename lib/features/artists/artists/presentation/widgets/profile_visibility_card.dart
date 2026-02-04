import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

/// Card para controlar a visibilidade do perfil do artista
class ProfileVisibilityCard extends StatelessWidget {
  final bool isActive;
  final bool isEnabled; // Se pode ativar/desativar (false quando há pendências)
  final String? blockingReason; // Mensagem explicando por que está bloqueado
  final ValueChanged<bool>? onChanged; // Callback quando o switch muda

  const ProfileVisibilityCard({
    super.key,
    required this.isActive,
    this.isEnabled = true,
    this.blockingReason,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.all(DSPadding.horizontal(24)),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: DSSize.width(1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícone de status
              Container(
                padding: EdgeInsets.all(DSPadding.horizontal(10)),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.2)
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.visibility : Icons.visibility_off,
                  color: isActive ? Colors.green : colorScheme.onSurfaceVariant,
                  size: DSSize.width(24),
                ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              
              // Título e descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visibilidade do Perfil',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(4),
                    Text(
                      isActive
                          ? 'Seu perfil está visível para clientes'
                          : 'Seu perfil está oculto dos clientes',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Switch
              Switch(
                value: isActive,
                onChanged: isEnabled ? onChanged : null,
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.5),
              ),
            ],
          ),
          
          // Mensagem de bloqueio (quando desabilitado)
          if (!isEnabled && blockingReason != null) ...[
            DSSizedBoxSpacing.vertical(12),
            Container(
              padding: EdgeInsets.all(DSPadding.horizontal(12)),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(DSSize.width(8)),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: DSSize.width(18),
                    color: colorScheme.error,
                  ),
                  DSSizedBoxSpacing.horizontal(8),
                  Expanded(
                    child: Text(
                      blockingReason!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

