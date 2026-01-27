import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para mensagens do sistema no chat
/// 
/// Exibe mensagens do sistema centralizadas com estilo diferenciado
class SystemMessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const SystemMessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: DSPadding.vertical(8),
        horizontal: DSPadding.horizontal(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container com fundo diferenciado
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSPadding.horizontal(16),
                    vertical: DSPadding.vertical(10),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(DSSize.width(20)),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                // Timestamp centralizado
                Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
