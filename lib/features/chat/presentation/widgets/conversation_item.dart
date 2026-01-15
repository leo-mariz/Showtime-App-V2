import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para item de conversa na lista de conversas
/// 
/// Exibe avatar, nome, última mensagem, timestamp e indicador de não lidas
class ConversationItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = conversation['name'] as String;
    final avatar = conversation['avatar'] as String?;
    final lastMessage = conversation['lastMessage'] as String;
    final timestamp = conversation['timestamp'] as DateTime;
    final unreadCount = conversation['unreadCount'] as int;
    final isOnline = conversation['isOnline'] as bool;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: DSPadding.vertical(12),
          horizontal: DSPadding.horizontal(0),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CustomCircleAvatar(
                  imageUrl: avatar,
                  size: 56,
                ),
                // Indicador de online
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: DSSize.width(14),
                      height: DSSize.height(14),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            DSSizedBoxSpacing.horizontal(12),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimestamp(timestamp),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  DSSizedBoxSpacing.vertical(4),
                  // Última mensagem e contador de não lidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        DSSizedBoxSpacing.horizontal(8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DSSize.width(8),
                            vertical: DSSize.height(4),
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(DSSize.width(12)),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Hoje - mostrar apenas hora
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Ontem
      return 'Ontem';
    } else if (difference.inDays < 7) {
      // Esta semana - mostrar dia da semana
      return DateFormat('EEEE', 'pt_BR').format(timestamp);
    } else {
      // Mais antigo - mostrar data
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }
}
