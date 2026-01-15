import 'dart:async';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:app/features/chat/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';

/// Tela de detalhes do chat - Conversa individual
/// 
/// Exibe mensagens de uma conversa com dados mockados
class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String recipientName;
  final String? recipientAvatar;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.recipientAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
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

  void _loadMessages() {
    // Carregar mensagens mockadas
    setState(() {
      _messages.addAll(_getMockMessages());
    });
    // Scroll para o final após carregar
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
    if (text.isEmpty || _isLoading) return;

    // Adicionar mensagem enviada
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': text,
        'timestamp': DateTime.now(),
        'isSent': true,
        'isRead': false,
      });
      _messageController.clear();
    });

    // Simular envio
    setState(() {
      _isLoading = true;
    });

    // Scroll para o final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simular resposta após 1 segundo
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Marcar última mensagem como lida
          if (_messages.isNotEmpty) {
            _messages.last['isRead'] = true;
          }
          // Simular resposta (opcional)
          // _messages.add({
          //   'id': DateTime.now().millisecondsSinceEpoch.toString(),
          //   'message': 'Resposta automática',
          //   'timestamp': DateTime.now(),
          //   'isSent': false,
          // });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: widget.recipientName,
      showAppBarBackButton: true,
      horizontalPadding: 0,
      verticalPadding: 0,
      child: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(context, colorScheme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: DSPadding.horizontal(16),
                      vertical: DSPadding.vertical(16),
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message['message'] as String,
                        timestamp: message['timestamp'] as DateTime,
                        isSent: message['isSent'] as bool,
                        isRead: message['isRead'] as bool? ?? true,
                      );
                    },
                  ),
          ),
          // Input de mensagem
          MessageInput(
            controller: _messageController,
            onSend: _onSendMessage,
            isLoading: _isLoading,
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

  // Mensagens mockadas
  List<Map<String, dynamic>> _getMockMessages() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'message': 'Olá! Gostaria de contratar seus serviços para um evento.',
        'timestamp': now.subtract(const Duration(days: 2, hours: 10)),
        'isSent': false,
        'isRead': true,
      },
      {
        'id': '2',
        'message': 'Olá! Fico feliz em ajudar. Qual tipo de evento você está planejando?',
        'timestamp': now.subtract(const Duration(days: 2, hours: 9, minutes: 45)),
        'isSent': true,
        'isRead': true,
      },
      {
        'id': '3',
        'message': 'É um casamento no próximo mês. Você está disponível?',
        'timestamp': now.subtract(const Duration(days: 2, hours: 9, minutes: 30)),
        'isSent': false,
        'isRead': true,
      },
      {
        'id': '4',
        'message': 'Sim, estou disponível! Vou enviar mais detalhes sobre os pacotes.',
        'timestamp': now.subtract(const Duration(days: 2, hours: 9, minutes: 15)),
        'isSent': true,
        'isRead': true,
      },
      {
        'id': '5',
        'message': 'Perfeito! Aguardo os detalhes.',
        'timestamp': now.subtract(const Duration(days: 2, hours: 9)),
        'isSent': false,
        'isRead': true,
      },
      {
        'id': '6',
        'message': 'Obrigado! Entro em contato em breve com todas as informações.',
        'timestamp': now.subtract(const Duration(days: 1, hours: 14)),
        'isSent': true,
        'isRead': true,
      },
    ];
  }
}
