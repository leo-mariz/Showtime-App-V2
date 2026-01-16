import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/features/chat/presentation/widgets/conversation_item.dart';
import 'package:app/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/bloc/events/chat_events.dart';
import 'package:app/features/chat/presentation/bloc/states/chat_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela principal de chat - Lista de conversas
/// 
/// Exibe uma lista de todas as conversas do usuário
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar conversas ao inicializar
    context.read<ChatBloc>().add(GetConversationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Mensagens',
      showAppBarBackButton: false,
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is GetConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetConversationsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: DSSize.width(64),
                    color: colorScheme.error,
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  Text(
                    'Erro ao carregar conversas',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Text(
                    state.error,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(GetConversationsEvent(forceRefresh: true));
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is GetConversationsSuccess) {
            final conversations = state.conversations;

            if (conversations.isEmpty) {
              return _buildEmptyState(context, colorScheme, textTheme);
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationItem(
                  conversation: conversation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          conversationId: conversation.contractId,
                          recipientName: conversation.recipientName,
                          recipientAvatar: conversation.recipientAvatar,
                          contractReference: conversation.contractReference,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          // Estado inicial - mostrar empty state
          return _buildEmptyState(context, colorScheme, textTheme);
        },
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

}
