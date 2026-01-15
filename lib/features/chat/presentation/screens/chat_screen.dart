import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/features/chat/presentation/widgets/conversation_item.dart';
import 'package:app/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';

/// Tela principal de chat - Lista de conversas
/// 
/// Exibe uma lista de todas as conversas do usuário com dados mockados
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Dados mockados de conversas
    final mockConversations = _getMockConversations();

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Mensagens',
      showAppBarBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de conversas
          Expanded(
            child: mockConversations.isEmpty
                ? _buildEmptyState(context, colorScheme, textTheme)
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: mockConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = mockConversations[index];
                      return ConversationItem(
                        conversation: conversation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                conversationId: conversation['id'] as String,
                                recipientName: conversation['name'] as String,
                                recipientAvatar: conversation['avatar'] as String?,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: DSSize.width(64),
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              'Nenhuma conversa ainda',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              'Suas conversas aparecerão aqui',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Dados mockados de conversas
  List<Map<String, dynamic>> _getMockConversations() {
    return [
      {
        'id': '1',
        'name': 'João Silva',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'lastMessage': 'Obrigado pelo show! Foi incrível!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'unreadCount': 2,
        'isOnline': true,
      },
      {
        'id': '2',
        'name': 'Maria Santos',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'lastMessage': 'Podemos agendar para o próximo sábado?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'unreadCount': 0,
        'isOnline': false,
      },
      {
        'id': '3',
        'name': 'Carlos Oliveira',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'lastMessage': 'Perfeito! Vejo você lá!',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'unreadCount': 0,
        'isOnline': true,
      },
      {
        'id': '4',
        'name': 'Ana Costa',
        'avatar': 'https://i.pravatar.cc/150?img=9',
        'lastMessage': 'Gostaria de confirmar os detalhes do evento',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'unreadCount': 1,
        'isOnline': false,
      },
      {
        'id': '5',
        'name': 'Pedro Alves',
        'avatar': null,
        'lastMessage': 'Show confirmado!',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'unreadCount': 0,
        'isOnline': false,
      },
    ];
  }
}
