import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para bubble de mensagem no chat
/// 
/// Exibe mensagem enviada ou recebida com diferentes estilos
class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isSent;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: DSPadding.vertical(8),
        left: isSent ? DSPadding.horizontal(48) : 0,
        right: isSent ? 0 : DSPadding.horizontal(48),
      ),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            // Avatar (apenas para mensagens recebidas)
            Container(
              width: DSSize.width(24),
              height: DSSize.height(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: DSSize.width(16),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            DSSizedBoxSpacing.horizontal(8),
          ],
          // Bubble de mensagem
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSPadding.horizontal(12),
                    vertical: DSPadding.vertical(10),
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(DSSize.width(16)),
                      topRight: Radius.circular(DSSize.width(16)),
                      bottomLeft: Radius.circular(
                        isSent ? DSSize.width(16) : DSSize.width(4),
                      ),
                      bottomRight: Radius.circular(
                        isSent ? DSSize.width(4) : DSSize.width(16),
                      ),
                    ),
                  ),
                  child: Text(
                    message,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isSent
                          ? colorScheme.surface
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                // Timestamp e status de leitura
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (isSent) ...[
                      DSSizedBoxSpacing.horizontal(4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: DSSize.width(14),
                        color: isRead
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
