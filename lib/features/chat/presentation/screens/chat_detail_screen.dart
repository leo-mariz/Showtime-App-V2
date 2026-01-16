import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:app/features/chat/presentation/widgets/message_input.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/bloc/events/chat_events.dart';
import 'package:app/features/chat/presentation/bloc/states/chat_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de detalhes do chat - Conversa individual
/// 
/// Exibe mensagens de uma conversa
class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String recipientName;
  final String? recipientAvatar;
  final String? contractReference;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.recipientAvatar,
    this.contractReference,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar mensagens ao inicializar
    context.read<ChatBloc>().add(GetMessagesEvent(contractId: widget.conversationId));
    // Marcar mensagens como lidas quando abrir a conversa
    context.read<ChatBloc>().add(MarkMessagesAsReadEvent(contractId: widget.conversationId));
    // Listener para atualizar botão de envio
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Enviar mensagem através do BLoC
    context.read<ChatBloc>().add(
          SendMessageEvent(
            contractId: widget.conversationId,
            text: text,
            senderName: widget.recipientName,
            senderAvatarUrl: widget.recipientAvatar,
          ),
        );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: widget.recipientName,
      showAppBarBackButton: true,
      horizontalPadding: 0,
      verticalPadding: 0,
      child: Column(
        children: [
          // Referência do contrato abaixo do AppBar
          if (widget.contractReference != null && widget.contractReference!.isNotEmpty)
            Container(
              width: double.infinity,
              // padding: EdgeInsets.symmetric(
              //   horizontal: DSPadding.horizontal(16),
              //   vertical: DSPadding.vertical(8),
              // ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                widget.contractReference!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontSize: calculateFontSize(12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Lista de mensagens
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is GetMessagesSuccess || state is SendMessageSuccess) {
                  _scrollToBottom();
                }
                if (state is SendMessageSuccess) {
                  // Recarregar mensagens após enviar
                  context.read<ChatBloc>().add(GetMessagesEvent(contractId: widget.conversationId));
                }
              },
              builder: (context, state) {
                if (state is GetMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetMessagesFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        DSSizedBoxSpacing.vertical(16),
                        Text(
                          'Erro ao carregar mensagens',
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
                            context.read<ChatBloc>().add(
                                  GetMessagesEvent(contractId: widget.conversationId),
                                );
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is GetMessagesSuccess) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return _buildEmptyState(context, colorScheme);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: DSPadding.horizontal(16),
                      vertical: DSPadding.vertical(16),
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // TODO: Determinar se a mensagem foi enviada pelo usuário atual
                      // quando tivermos acesso ao userId
                      final isSent = false; // TODO: implementar

                      return MessageBubble(
                        message: message.text,
                        timestamp: message.timestamp,
                        isSent: isSent,
                        isRead: message.isRead,
                      );
                    },
                  );
                }

                // Estado inicial - mostrar empty state
                return _buildEmptyState(context, colorScheme);
              },
            ),
          ),
          // Input de mensagem
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state is SendMessageLoading;
              return MessageInput(
                controller: _messageController,
                onSend: _onSendMessage,
                isLoading: isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomCircleAvatar(
            imageUrl: widget.recipientAvatar,
            size: 80,
          ),
          DSSizedBoxSpacing.vertical(16),
          Text(
            widget.recipientName,
            style: textTheme.titleMedium,
          ),
          if (widget.contractReference != null && widget.contractReference!.isNotEmpty) ...[
            DSSizedBoxSpacing.vertical(4),
            Text(
              widget.contractReference!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
          DSSizedBoxSpacing.vertical(8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              'Esta é o início da sua conversa',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
