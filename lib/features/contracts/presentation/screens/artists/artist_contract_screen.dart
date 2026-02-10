import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/card_action_button.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/states/pending_contracts_count_states.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/pending_contracts_count_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/events/pending_contracts_count_events.dart';
import 'package:app/features/contracts/presentation/widgets/contract_card.dart';
import 'package:app/features/contracts/presentation/widgets/confirm_show_modal.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistContractsScreen extends StatefulWidget {
  const ArtistContractsScreen({super.key});

  @override
  State<ArtistContractsScreen> createState() => _ArtistContractsScreenState();
}

class _ArtistContractsScreenState extends State<ArtistContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  List<ContractEntity> _allContracts = [];
  String? _processingContractUid; // UID do contrato sendo processado (aceitar/rejeitar)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      final newIndex = _tabController.index;
      if (newIndex != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = newIndex;
        });
        // Marcar tab como vista quando mudar
        _markTabAsSeen(newIndex);
      }
    });
    
    // Buscar contratos ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContracts();
      // Carregar índice de contratos pendentes (como artista)
      context.read<PendingContractsCountBloc>().add(LoadPendingContractsCountEvent(isArtist: true));
      // Não marcar tab inicial aqui - será marcada automaticamente quando o usuário interagir
      // ou quando o listener do TabController detectar mudança
    });
  }
  
  void _markTabAsSeen(int tabIndex) {
    // Verificar se há itens não vistos antes de marcar como vista
    final contractsCountState = context.read<PendingContractsCountBloc>().state;
    if (contractsCountState is PendingContractsCountSuccess) {
      // Obter contador de não vistos para a tab específica
      int unseenCount = 0;
      switch (tabIndex) {
        case 0:
          unseenCount = contractsCountState.tab0Unseen;
          break;
        case 1:
          unseenCount = contractsCountState.tab1Unseen;
          break;
        case 2:
          unseenCount = contractsCountState.tab2Unseen;
          break;
      }
      
      // Só marcar como vista se houver itens não vistos
      if (unseenCount > 0) {
        context.read<PendingContractsCountBloc>().add(MarkTabAsSeenEvent(tabIndex: tabIndex, isArtist: true));
      }
    }
  }

  Future<void> _loadContracts({bool forceRefresh = false}) async {
    context.read<ContractsBloc>().add(
      GetContractsByArtistEvent(forceRefresh: forceRefresh),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ContractEntity> get _filteredContracts {
    switch (_selectedTabIndex) {
      case 0: // Abertas
        return _allContracts.where((contract) {
          return contract.status == ContractStatusEnum.pending ||
              contract.status == ContractStatusEnum.paymentPending ||
              contract.status == ContractStatusEnum.paymentExpired ||
              contract.status == ContractStatusEnum.paymentRefused;
        }).toList();
      case 1: // Confirmadas
        return _allContracts.where((contract) {
          return contract.status == ContractStatusEnum.paid;
        }).toList();
      case 2: // Finalizadas
        return _allContracts.where((contract) {
          return contract.status == ContractStatusEnum.rejected ||
              contract.status == ContractStatusEnum.completed ||
              contract.status == ContractStatusEnum.rated ||
              contract.status == ContractStatusEnum.canceled;
        }).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return BlocProvider.value(
      value: context.read<ContractsBloc>(),
        child: BlocListener<ContractsBloc, ContractsState>(
        listener: (context, state) {
          if (state is GetContractsByArtistSuccess) {
            setState(() {
              _allContracts = state.contracts;
              _processingContractUid = null; // Reset ao recarregar
            });
          } else if (state is GetContractsByArtistFailure) {
            context.showError(state.error);
          } else if (state is ConfirmShowSuccess) {
            context.showSuccess('Show confirmado com sucesso!');
            _loadContracts(forceRefresh: true);
          } else if (state is ConfirmShowFailure) {
            context.showError(state.error);
          } else if (state is AcceptContractLoading) {
            // Não precisa fazer nada, o BlocBuilder vai atualizar
          } else if (state is AcceptContractSuccess) {
            setState(() {
              _processingContractUid = null; // Reset após sucesso
            });
            context.showSuccess('Solicitação aceita com sucesso!');
            // Recarregar do servidor para atualizar status/botões na tela
            _loadContracts(forceRefresh: true);
          } else if (state is AcceptContractFailure) {
            setState(() {
              _processingContractUid = null; // Reset após falha
            });
            context.showError(state.error);
          } else if (state is RejectContractLoading) {
            // Não precisa fazer nada, o BlocBuilder vai atualizar
          } else if (state is RejectContractSuccess) {
            setState(() {
              _processingContractUid = null; // Reset após sucesso
            });
            context.showSuccess('Solicitação rejeitada com sucesso!');
            // Recarregar do servidor para atualizar lista/card
            _loadContracts(forceRefresh: true);
          } else if (state is RejectContractFailure) {
            setState(() {
              _processingContractUid = null; // Reset após falha
            });
            context.showError(state.error);
          } else if (state is MakePaymentSuccess) {
            // Recarregar do servidor após pagamento
            _loadContracts(forceRefresh: true);
          } else if (state is CancelContractSuccess) {
            context.showSuccess('Contrato cancelado com sucesso!');
            // Recarregar do servidor após cancelamento
            _loadContracts(forceRefresh: true);
          } else if (state is CancelContractFailure) {
            context.showError(state.error);
          }
        },
        child: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            return BlocBuilder<PendingContractsCountBloc, PendingContractsCountState>(
              builder: (context, contractsCountState) {
                final isLoading = state is GetContractsByArtistLoading;
                final isAccepting = state is AcceptContractLoading;
                final isRejecting = state is RejectContractLoading;
                final filteredContracts = _filteredContracts;
                
                // Obter contadores de não vistos
                int tab0Unseen = 0;
                int tab1Unseen = 0;
                int tab2Unseen = 0;
                
                if (contractsCountState is PendingContractsCountSuccess) {
                  tab0Unseen = contractsCountState.tab0Unseen;
                  tab1Unseen = contractsCountState.tab1Unseen;
                  tab2Unseen = contractsCountState.tab2Unseen;
                }

                return BasePage(
                  showAppBar: true,
                  appBarTitle: 'Apresentações',
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        height: DSSize.height(36),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(DSSize.width(12)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: colorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(DSSize.width(12)),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: colorScheme.primaryContainer,
                          unselectedLabelColor: onSurfaceVariant,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                          unselectedLabelStyle: textTheme.bodyMedium,
                          dividerColor: Colors.transparent,
                          tabAlignment: TabAlignment.fill,
                          padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
                          labelPadding: EdgeInsets.symmetric(horizontal: DSSize.width(8)),
                          tabs: [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Em aberto'),
                                    if (tab0Unseen > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          tab0Unseen > 99 ? '99+' : '$tab0Unseen',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onError,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Confirmadas'),
                                    if (tab1Unseen > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          tab1Unseen > 99 ? '99+' : '$tab1Unseen',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onError,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Finalizadas'),
                                    if (tab2Unseen > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          tab2Unseen > 99 ? '99+' : '$tab2Unseen',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onError,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  DSSizedBoxSpacing.vertical(24),

                  // Lista de contratos
                  Expanded(
                    child: isLoading
                        ? const Center(child: CustomLoadingIndicator())
                        : filteredContracts.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: filteredContracts.length,
                                itemBuilder: (context, index) {
                                  final contract = filteredContracts[index];
                                  return ContractCard(
                                    contract: contract,
                                    onTap: () => _onRequestTapped(contract),
                                    isArtist: true,
                                    actionButtons: _buildActionButtons(
                                      contract,
                                      isAccepting: isAccepting && _processingContractUid == contract.uid,
                                      isRejecting: isRejecting && _processingContractUid == contract.uid,
                                      isAnyLoading: (isAccepting || isRejecting) && _processingContractUid == contract.uid,
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
        },
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    IconData icon;
    String message;

    switch (_selectedTabIndex) {
      case 0: // Abertas
        icon = Icons.inbox_outlined;
        message = 'Nenhuma solicitação aberta.\nSuas solicitações em andamento aparecerão aqui.';
        break;
      case 1: // Confirmadas
        icon = Icons.check_circle_outline;
        message = 'Nenhuma solicitação confirmada.\nAs solicitações pagas e confirmadas aparecerão aqui.';
        break;
      case 2: // Finalizadas
        icon = Icons.event_note_outlined;
        message = 'Nenhuma solicitação finalizada.\nAs solicitações concluídas, recusadas ou canceladas aparecerão aqui.';
        break;
      default:
        icon = Icons.inbox_outlined;
        message = 'Nenhuma solicitação encontrada.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: DSSize.width(64),
            color: onSurfaceVariant.withOpacity(0.5),
          ),
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRequestTapped(ContractEntity request) async {
    final result = await context.router.push<bool>(
      ArtistEventDetailRoute(contract: request),
    );
    
    // Se voltou da tela de detalhes com indicação de que precisa recarregar
    if (result == true && mounted) {
      _loadContracts();
    }
  }

  // Constrói os botões de ação baseado no status do contrato (Artista)
  List<Widget> _buildActionButtons(
    ContractEntity contract, {
    required bool isAccepting,
    required bool isRejecting,
    required bool isAnyLoading,
  }) {
    final buttons = <Widget>[];

    if (contract.status == ContractStatusEnum.pending) {
      // PENDING → Aceitar e Recusar
      buttons.addAll([
        CardActionButton(
          label: 'Recusar',
          onPressed: isAnyLoading ? null : () => _onReject(contract),
          icon: Icons.close_rounded,
          buttonType: CardActionButtonType.cancel,
          height: DSSize.height(40),
          isLoading: isRejecting,
        ),
        CardActionButton(
          label: 'Aceitar',
          onPressed: isAnyLoading ? null : () => _onAccept(contract),
          icon: Icons.check_rounded,
          height: DSSize.height(40),
          isLoading: isAccepting,
        ),
      ]);
    } else if (contract.status == ContractStatusEnum.paid) {
      // PAID → Botão para confirmar show
      buttons.add(
        CardActionButton(
          label: 'O Show irá começar?',
          onPressed: isAnyLoading ? null : () => _onConfirmShow(contract),
          icon: Icons.check_circle_rounded,
          height: DSSize.height(40),
        ),
      );
    }

    return buttons;
  }

  void _onConfirmShow(ContractEntity contract) async {
    if (contract.uid == null || contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    await ConfirmShowModal.show(
      context: context,
      contractUid: contract.uid!,
    );
  }

  void _onAccept(ContractEntity contract) {
    if (contract.uid == null || contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }
    
    setState(() {
      _processingContractUid = contract.uid;
    });
    
    context.read<ContractsBloc>().add(
      AcceptContractEvent(contractUid: contract.uid!),
    );
  }

  void _onReject(ContractEntity contract) {
    if (contract.uid == null || contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }
    
    setState(() {
      _processingContractUid = contract.uid;
    });
    
    context.read<ContractsBloc>().add(
      RejectContractEvent(contractUid: contract.uid!),
    );
  }
}

