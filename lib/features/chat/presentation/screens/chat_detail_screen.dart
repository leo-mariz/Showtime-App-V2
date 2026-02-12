import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/utils/chat_message_contact_validator.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/features/chat/domain/dtos/send_message_input_dto.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:app/features/chat/presentation/widgets/message_input.dart';
import 'package:app/features/chat/presentation/widgets/system_message_bubble.dart';
import 'package:app/features/chat/presentation/widgets/contract_info_widget.dart';
import 'package:app/features/chat/presentation/bloc/messages/messages_bloc.dart';
import 'package:app/features/chat/presentation/bloc/messages/events/messages_events.dart';
import 'package:app/features/chat/presentation/bloc/messages/states/messages_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de detalhes do chat - Conversa individual
/// 
/// Exibe mensagens de uma conversa
class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final ChatEntity chat;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chat,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  String? _currentUserId;
  /// Validação em tempo real: true quando o texto contém informações de contato não permitidas.
  bool _hasContactInfoInText = false;

  @override
  void initState() {
    super.initState();
    
    _initializeScreen();
    // Listener para atualizar botão de envio e validação de conteúdo em tempo real
    _messageController.addListener(() {
      setState(() {
        _hasContactInfoInText = containsDisallowedContactInfo(_messageController.text);
      });
    });
    
    // Listener para scroll - detectar quando chegar no topo para carregar mais mensagens
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    // Quando o usuário rolar para o topo (próximo do início), carregar mais mensagens antigas
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      
      // Se estiver próximo do topo (50 pixels) e não estiver carregando
      if (position.pixels <= 50 && position.pixels > 0) {
        final messagesState = context.read<MessagesBloc>().state;
        if (messagesState is MessagesSuccess && 
            messagesState.hasMore && 
            !messagesState.isLoadingMore) {
          // Obter a data da mensagem mais antiga (primeira da lista)
          final oldestMessage = messagesState.messages.first;
          context.read<MessagesBloc>().add(
            LoadMoreMessagesEvent(
              chatId: widget.chatId,
              beforeDate: oldestMessage.createdAt,
            ),
          );
        }
      }
    }
  }


  bool _hasScrolledToBottom = false;
  int _previousMessagesCount = 0;

  Future<void> _initializeScreen() async {
    // Carregar userId primeiro
    await _loadCurrentUserId();
    
    // Carregar mensagens ao inicializar
    // ignore: use_build_context_synchronously
    context.read<MessagesBloc>().add(LoadMessagesEvent(chatId: widget.chatId));
    
    // Marcar mensagens como lidas quando abrir a conversa (após um pequeno delay para garantir que as mensagens foram carregadas)
    // Só marcar se houver mensagens não lidas para evitar chamadas desnecessárias
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _currentUserId != null) {
        // Verificar se há mensagens não lidas antes de marcar como lido
        final unreadCount = widget.chat.getUnreadCountForUser(_currentUserId!);
        if (unreadCount > 0) {
          // ignore: use_build_context_synchronously
          context.read<MessagesBloc>().add(MarkMessagesAsReadEvent(chatId: widget.chatId));
        }
      }
    });
  }

  Future<void> _loadCurrentUserId() async {
    final usersState = context.read<UsersBloc>().state;
    if (usersState is GetUserDataSuccess) {
      _currentUserId = usersState.user.uid;
      if (mounted) {
        setState(() {});
      }
    } else {
      context.read<UsersBloc>().add(GetUserDataEvent());
    }
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
    
    if (text.isEmpty) {
      return;
    }

    // Enviar mensagem através do BLoC
    // O senderId será obtido internamente pelo UseCase
    context.read<MessagesBloc>().add(
          SendMessageEvent(
            input: SendMessageInputDto(
              chatId: widget.chatId,
              text: text,
              chatStatus: widget.chat.status,
            ),
          ),
        );

    _messageController.clear();
    
    // Rolar para o final imediatamente ao enviar (antes mesmo da mensagem otimista aparecer)
    // Isso garante que a tela já esteja no final quando a mensagem aparecer
    _scrollToBottom();
  }

  /// Banner exibido acima do input quando o texto contém informações de contato (validação em tempo real).
  Widget _buildContactInfoBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: DSPadding.horizontal(16),
        vertical: DSPadding.vertical(8),
      ),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: colorScheme.onErrorContainer, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informações de contato não permitidas',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'Por motivos de segurança, não é permitido compartilhar contatos externos.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          DSSizedBoxSpacing.vertical(6),
          Text(
            '💡 Use apenas a plataforma para se comunicar com segurança.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
          DSSizedBoxSpacing.vertical(6),
          Text(
            '💡 Use apenas a plataforma para se comunicar com segurança.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
          DSSizedBoxSpacing.vertical(6),
          Text(
            'Qualquer tentativa de compartilhar contatos poderá resultar em banimento da plataforma.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactInfoError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Informações de contato não permitidas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Por motivos de segurança, não é permitido compartilhar:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              '• Números de telefone ou WhatsApp\n'
              '• Endereços de email\n'
              '• Redes sociais (Instagram, Facebook, etc.)\n'
              '• Palavras como "me liga", "me add", etc.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 Use apenas a plataforma para se comunicar com segurança',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
          bottom: 80,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determinar nome e foto do outro participante
    final otherUserName = _currentUserId != null
        ? widget.chat.getOtherUserName(_currentUserId!)
        : widget.chat.artistName;
    final otherUserPhoto = _currentUserId != null
        ? widget.chat.getOtherUserPhoto(_currentUserId!)
        : widget.chat.artistPhoto;

    return BlocListener<UsersBloc, UsersState>(
      listener: (context, usersState) {
        if (usersState is GetUserDataSuccess && _currentUserId != usersState.user.uid) {
          setState(() {
            _currentUserId = usersState.user.uid;
          });
        }
      },

      child: BasePage(
        showAppBar: true,
        appBarTitle: otherUserName,
        appBarTitleColor: colorScheme.onPrimary,
        showAppBarBackButton: true,
        horizontalPadding: 0,
        verticalPadding: 0,
        child: GestureDetector(
          onTap: () {
            // Fechar teclado ao tocar em qualquer lugar da tela
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
            // Informações do contrato abaixo do AppBar
            Container(
              width: double.infinity,
              // padding: EdgeInsets.symmetric(
              //   vertical: DSPadding.vertical(2),
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
              child: ContractInfoWidget(
                contractId: widget.chat.contractId,
                textStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontSize: calculateFontSize(12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Lista de mensagens
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  // Listener para UsersBloc - atualizar _currentUserId quando disponível
                  BlocListener<UsersBloc, UsersState>(
                    listener: (context, usersState) {
                      if (usersState is GetUserDataSuccess && _currentUserId != usersState.user.uid) {
                        if (mounted) {
                          setState(() {
                            _currentUserId = usersState.user.uid;
                          });
                        }
                      }
                    },
                  ),
                  // Listener para MessagesBloc - scroll automático
                  BlocListener<MessagesBloc, MessagesState>(
                    listener: (context, state) {
                      if (state is MessagesSuccess) {
                        final currentMessagesCount = state.messages.length;
                        
                        // Quando mensagens são carregadas pela primeira vez, ir para o final
                        if (!_hasScrolledToBottom) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                            _hasScrolledToBottom = true;
                            _previousMessagesCount = currentMessagesCount;
                          });
                        } 
                        // Se uma nova mensagem foi adicionada (enviada ou recebida), rolar até o final
                        else if (currentMessagesCount > _previousMessagesCount) {
                          // Verificar se a última mensagem é recente (últimos 5 segundos)
                          // para evitar scroll quando carregar mensagens antigas
                          if (state.messages.isNotEmpty) {
                            final lastMessage = state.messages.last;
                            final now = DateTime.now();
                            final timeDiff = now.difference(lastMessage.createdAt);
                            
                            // Só rolar se a última mensagem for recente (menos de 5 segundos)
                            // ou se o usuário estiver próximo do final (dentro de 100 pixels)
                            if (timeDiff.inSeconds < 5) {
                              _scrollToBottom();
                            } else if (_scrollController.hasClients) {
                              final position = _scrollController.position;
                              final maxScroll = position.maxScrollExtent;
                              final currentScroll = position.pixels;
                              
                              // Se estiver próximo do final (dentro de 100 pixels), rolar
                              if ((maxScroll - currentScroll) < 100) {
                                _scrollToBottom();
                              }
                            }
                          }
                          
                          _previousMessagesCount = currentMessagesCount;
                        }
                      } else if (state is SendMessageSuccess) {
                        // Quando uma nova mensagem é enviada, ir para o final imediatamente
                        _scrollToBottom();
                      } else if (state is SendMessageFailure && mounted) {
                        if (state.error == kChatContactInfoValidationMessage) {
                          _showContactInfoError(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
                child: BlocBuilder<MessagesBloc, MessagesState>(
                  builder: (context, state) {
                  if (state is MessagesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MessagesFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: DSSize.width(48),
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
                              context.read<MessagesBloc>().add(
                                    LoadMessagesEvent(chatId: widget.chatId),
                                  );
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MessagesSuccess) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return _buildEmptyState(context, colorScheme, otherUserName, otherUserPhoto, widget.chat.contractId);
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: false, // Lista crescente: mais antigas no topo, mais recentes embaixo
                      padding: EdgeInsets.symmetric(
                        horizontal: DSPadding.horizontal(16),
                        vertical: DSPadding.vertical(16),
                      ),
                      itemCount: state.isLoadingMore 
                          ? messages.length + 1 
                          : messages.length,
                      itemBuilder: (context, index) {
                        // Mostrar indicador de loading no topo quando carregando mais mensagens
                        if (state.isLoadingMore && index == 0) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: DSPadding.vertical(8),
                            ),
                            child: Center(
                              child: CustomLoadingIndicator(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          );
                        }
                        
                        // Ajustar índice se estiver carregando
                        final messageIndex = state.isLoadingMore ? index - 1 : index;
                        final message = messages[messageIndex];
                        
                        // Se for mensagem do sistema, usar widget especial
                        if (message.isSystemMessage) {
                          return SystemMessageBubble(
                            message: message.text,
                            timestamp: message.createdAt,
                          );
                        }
                        
                        // Determinar se a mensagem foi enviada pelo usuário atual
                        final isSent = _currentUserId != null && message.senderId == _currentUserId;

                        return MessageBubble(
                          message: message.text,
                          timestamp: message.createdAt,
                          isSent: isSent,
                          isRead: message.isRead,
                        );
                      },
                    );
                  }

                  // Estado inicial - mostrar empty state
                  return _buildEmptyState(context, colorScheme, otherUserName, otherUserPhoto, widget.chat.contractId);
                  },
                ),
              ),
            ),
            // Input de mensagem (oculto quando o chat está encerrado)
            if (!widget.chat.isClosed) ...[
              if (_hasContactInfoInText) _buildContactInfoBanner(context),
              BlocBuilder<MessagesBloc, MessagesState>(
                builder: (context, state) {
                  final isLoading = state is SendMessageSuccess;
                  return MessageInput(
                    controller: _messageController,
                    onSend: _onSendMessage,
                    isLoading: isLoading,
                    sendEnabled: !_hasContactInfoInText,
                  );
                },
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    String otherUserName,
    String? otherUserPhoto,
    String contractRef,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomCircleAvatar(
            imageUrl: otherUserPhoto,
            size: DSSize.width(80),
          ),
          DSSizedBoxSpacing.vertical(16),
          Text(
            otherUserName,
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
}
