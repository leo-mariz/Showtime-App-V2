import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/presentation/widgets/contract_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para item de conversa na lista de conversas
/// 
/// Widget de UI pura - recebe dados via parâmetros
/// Exibe avatar, nome, última mensagem, timestamp e indicador de não lidas
class ConversationItem extends StatelessWidget {
  final ChatEntity chat;
  final String? currentUserId;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determinar dados do outro participante
    final otherUserName = currentUserId != null
        ? chat.getOtherUserName(currentUserId!)
        : chat.artistName;
    final otherUserPhoto = currentUserId != null
        ? chat.getOtherUserPhoto(currentUserId!)
        : chat.artistPhoto;
    final unreadCount = currentUserId != null
        ? chat.getUnreadCountForUser(currentUserId!)
        : 0;
    final isTyping = currentUserId != null
        ? chat.isOtherUserTyping(currentUserId!)
        : false;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: DSPadding.vertical(12),
          horizontal: DSPadding.horizontal(0),
        ),
        child: Row(
          children: [
            // Avatar (sem indicador de online - não necessário)
            CustomCircleAvatar(
              imageUrl: otherUserPhoto,
              size: 56,
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
                          otherUserName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.lastMessageAt != null)
                        Text(
                          _formatTimestamp(chat.lastMessageAt!),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  // Informações do contrato
                  DSSizedBoxSpacing.vertical(2),
                  ContractInfoWidget(
                    contractId: chat.contractId,
                    textStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: calculateFontSize(12),
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(4),
                  // Última mensagem e contador de não lidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isTyping
                              ? 'Digitando...'
                              : (chat.lastMessage ?? 'Nenhuma mensagem ainda'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: isTyping
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontStyle: isTyping ? FontStyle.italic : null,
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
