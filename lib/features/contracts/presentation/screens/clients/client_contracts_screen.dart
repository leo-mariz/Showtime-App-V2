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
import 'package:app/features/contracts/presentation/bloc/contract_paying_cubit.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/states/pending_contracts_count_states.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/pending_contracts_count_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/events/pending_contracts_count_events.dart';
import 'package:app/features/contracts/presentation/widgets/contract_card.dart';
import 'package:app/features/contracts/presentation/widgets/rating_modal.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientContractsScreen extends StatefulWidget {
  const ClientContractsScreen({super.key});

  @override
  State<ClientContractsScreen> createState() => _ClientContractsScreenState();
}

class _ClientContractsScreenState extends State<ClientContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  List<ContractEntity> _allContracts = [];
  bool _isLoading = false;
  bool _isVerifyingPayment = false;
  /// UID do contrato para o qual disparou "Realizar Pagamento" (para remover do cubit em caso de falha).
  String? _lastMakePaymentContractUid;

  /// Últimos totais do índice (cliente) para detectar mudança e disparar force refresh apenas quando alterar.
  int? _lastClientTab0Total;
  int? _lastClientTab1Total;
  int? _lastClientTab2Total;
  /// Marcar a aba atual como vista ao abrir a tela (apenas uma vez).
  bool _didMarkInitialTabAsSeen = false;

  /// Contratos para os quais já mostramos o modal de avaliação nesta sessão (evita loop infinito).
  final Set<String> _ratingModalShownForContractUids = {};
  /// True enquanto o modal de avaliação está aberto (para fechá-lo ao receber resposta do bloc).
  bool _isRatingModalOpen = false;

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
      // Carregar índice de contratos pendentes (como cliente)
      context.read<PendingContractsCountBloc>().add(LoadPendingContractsCountEvent(isArtist: false));
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
        context.read<PendingContractsCountBloc>().add(MarkTabAsSeenEvent(tabIndex: tabIndex, isArtist: false));
      }
    }
  }

  Future<void> _loadContracts({bool forceRefresh = false}) async {
      context.read<ContractsBloc>().add(
        GetContractsByClientEvent(forceRefresh: forceRefresh),
      );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Retorna o primeiro contrato finalizado que ainda precisa de avaliação do cliente
  /// (showRatingRequestedEntityByClient com requested true, não pulado, não concluído, e ainda sem rateByClient).
  ContractEntity? _findContractNeedingClientRating(List<ContractEntity> contracts) {
    for (final c in contracts) {
      if (c.status != ContractStatusEnum.completed) continue;
      if (c.rateByClient != null) continue; // Já avaliado pelo cliente
      final byClient = c.showRatingRequestedEntityByClient;
      if (byClient == null) continue;
      if (byClient.showRatingRequested &&
          !byClient.showRatingSkipped &&
          !byClient.showRatingCompleted) {
        return c;
      }
    }
    return null;
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
      child: MultiBlocListener(
        listeners: [
          // Índice de contratos: force refresh só quando totais mudarem; marcar aba atual como vista ao abrir.
          BlocListener<PendingContractsCountBloc, PendingContractsCountState>(
            listener: (context, state) {
              if (state is! PendingContractsCountSuccess) return;

              // Ao abrir a tela: se a aba atual tem unseen, marcar como vista uma vez.
              if (!_didMarkInitialTabAsSeen) {
                final unseen = _selectedTabIndex == 0
                    ? state.tab0Unseen
                    : _selectedTabIndex == 1
                        ? state.tab1Unseen
                        : state.tab2Unseen;
                if (unseen > 0) {
                  context.read<PendingContractsCountBloc>().add(
                    MarkTabAsSeenEvent(tabIndex: _selectedTabIndex, isArtist: false),
                  );
                  _didMarkInitialTabAsSeen = true;
                } else {
                  _didMarkInitialTabAsSeen = true;
                }
              }

              // Force refresh apenas quando o índice realmente mudar (não na primeira emissão).
              final tab0 = state.tab0Total;
              final tab1 = state.tab1Total;
              final tab2 = state.tab2Total;
              final changed = _lastClientTab0Total != null &&
                  (tab0 != _lastClientTab0Total || tab1 != _lastClientTab1Total || tab2 != _lastClientTab2Total);
              if (changed) {
                _loadContracts(forceRefresh: true);
              }
              _lastClientTab0Total = tab0;
              _lastClientTab1Total = tab1;
              _lastClientTab2Total = tab2;
            },
          ),
          BlocListener<ContractsBloc, ContractsState>(
            listener: (context, state) {
              if (state is GetContractsByClientLoading) {
                setState(() {
                  _isLoading = true;
                });
              }
              if (state is GetContractsByClientSuccess) {
                setState(() {
                  _allContracts = state.contracts;
                  _isLoading = false;
                });
                final contractToRate = _findContractNeedingClientRating(state.contracts);
                if (contractToRate != null && mounted) {
                  final contractUidToShow = contractToRate.uid;
                  if (contractUidToShow != null &&
                      contractUidToShow.isNotEmpty &&
                      !_ratingModalShownForContractUids.contains(contractUidToShow)) {
                    _ratingModalShownForContractUids.add(contractUidToShow);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final contract = contractToRate;
                      final contractUid = contract.uid;
                      if (contractUid == null || contractUid.isEmpty) return;
                      final nameArtist = contract.nameArtist ?? contract.nameGroup ?? 'Artista';
                      final eventTypeName = contract.eventType?.name;
                      final date = contract.date;
                      final time = contract.time;
                      final bloc = context.read<ContractsBloc>();

                      setState(() => _isRatingModalOpen = true);
                      RatingModal.show(
                        context: context,
                        personName: nameArtist,
                        isRatingArtist: true,
                        eventTypeName: eventTypeName,
                        date: date,
                        time: time,
                        onAvaliar: (rating, comment) {
                          bloc.add(RateArtistEvent(
                            contractUid: contractUid,
                            rating: rating.toDouble(),
                            comment: comment,
                          ));
                        },
                        onAvaliarDepois: () {
                          bloc.add(SkipRatingArtistEvent(contractUid: contractUid));
                        },
                      ).then((_) {
                        if (mounted) setState(() => _isRatingModalOpen = false);
                      });
                    });
                  }
                }
              } else if (state is GetContractsByClientFailure) {
                context.showError(state.error);
                setState(() {
                  _isLoading = false;
                });
              } else if (state is MakePaymentSuccess) {
                _lastMakePaymentContractUid = null;
                // Recarregar contratos após abrir checkout (isPaying já está no cubit local)
                _loadContracts(forceRefresh: true);
              } else if (state is MakePaymentFailure) {
                context.showError(state.error);
                if (_lastMakePaymentContractUid != null) {
                  context.read<ContractPayingCubit>().removeOpening(_lastMakePaymentContractUid!);
                  _lastMakePaymentContractUid = null;
                }
                _loadContracts(forceRefresh: true);
              } else if (state is CancelContractSuccess) {
                context.showSuccess('Contrato cancelado com sucesso!');
                // Recarregar contratos após cancelamento
                _loadContracts();
              } else if (state is CancelContractFailure) {
                context.showError(state.error);
              } else if (state is VerifyPaymentSuccess) {
                context.showSuccess('O pagamento foi identificado com sucesso!');
                setState(() {
                  _isVerifyingPayment = false;
                });
                // Recarregar contratos após verificar pagamento
                _loadContracts();
              } else if (state is VerifyPaymentFailure) {
                context.showError(state.error);
                setState(() {
                  _isVerifyingPayment = false;
                });
                // Recarregar contratos após verificar pagamento
                _loadContracts(forceRefresh: true);
              } else if (state is VerifyPaymentLoading) {
                setState(() {
                  _isVerifyingPayment = true;
                });
              } else if (state is RateArtistSuccess) {
                if (_isRatingModalOpen && mounted) Navigator.of(context).pop();
                context.showSuccess('Avaliação enviada com sucesso!');
                _loadContracts(forceRefresh: true);
              } else if (state is RateArtistFailure) {
                if (_isRatingModalOpen && mounted) Navigator.of(context).pop();
                context.showError(state.error);
              } else if (state is SkipRatingArtistSuccess) {
                if (_isRatingModalOpen && mounted) Navigator.of(context).pop();
                _loadContracts(forceRefresh: true);
              } else if (state is SkipRatingArtistFailure) {
                if (_isRatingModalOpen && mounted) Navigator.of(context).pop();
                context.showError(state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            return BlocBuilder<PendingContractsCountBloc, PendingContractsCountState>(
              builder: (context, contractsCountState) {
                return BlocBuilder<ContractPayingCubit, ContractPayingState>(
                  builder: (context, payingState) {
                final filteredContracts = _filteredContracts;
                
                // Obter contadores de não vistos e totais; limitar badge ao número real de contratos na tab
                int tab0Unseen = 0, tab1Unseen = 0, tab2Unseen = 0;
                int tab0Total = 0, tab1Total = 0, tab2Total = 0;
                if (contractsCountState is PendingContractsCountSuccess) {
                  tab0Unseen = contractsCountState.tab0Unseen;
                  tab1Unseen = contractsCountState.tab1Unseen;
                  tab2Unseen = contractsCountState.tab2Unseen;
                  tab0Total = contractsCountState.tab0Total;
                  tab1Total = contractsCountState.tab1Total;
                  tab2Total = contractsCountState.tab2Total;
                }
                final display0 = tab0Total > 0 ? tab0Unseen.clamp(0, tab0Total) : 0;
                final display1 = tab1Total > 0 ? tab1Unseen.clamp(0, tab1Total) : 0;
                final display2 = tab2Total > 0 ? tab2Unseen.clamp(0, tab2Total) : 0;

                return BasePage(
                  showAppBar: true,
                  appBarTitle: 'Solicitações',
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
                          tabAlignment: TabAlignment.fill,
                          padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
                          labelPadding: EdgeInsets.symmetric(horizontal: DSSize.width(8)),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Em aberto'),
                                    if (display0 > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          display0 > 99 ? '99+' : '$display0',
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
                                    if (display1 > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          display1 > 99 ? '99+' : '$display1',
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
                                    const Text('Finalizados'),
                                    if (display2 > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          display2 > 99 ? '99+' : '$display2',
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
                    child: _isLoading
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
                                    actionButtons: _buildActionButtons(contract, payingState: payingState),
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
      ClientEventDetailRoute(contract: request),
    );
    
    // Se voltou da tela de detalhes com indicação de que precisa recarregar
    if (result == true && mounted) {
      _loadContracts();
    }
  }

  // Constrói os botões de ação baseado no status do contrato (Cliente).
  // Estado de pagamento é local (ContractPayingCubit); o app cliente não escreve em contratos.
  List<Widget> _buildActionButtons(ContractEntity contract, {required ContractPayingState payingState}) {
    final buttons = <Widget>[];
    final isPayingLocally = contract.uid != null && payingState.paying.contains(contract.uid);
    final isOpeningPayment = contract.uid != null && payingState.opening.contains(contract.uid);

    if (contract.status == ContractStatusEnum.paymentPending) {
      if (isPayingLocally) {
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CardActionButton(
              label: 'Verificar Pagamento',
              onPressed: () => _onVerifyPayment(contract),
              icon: Icons.check_circle_rounded,
              height: 40,
              isLoading: _isVerifyingPayment,
            ),
          ),
        );
      } else {
        // Aguardando pagamento → Realizar Pagamento (com loading enquanto abre o MP)
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CardActionButton(
              label: isOpeningPayment ? 'Abrindo...' : 'Realizar Pagamento',
              onPressed: isOpeningPayment ? null : () => _onMakePayment(contract),
              icon: Icons.payment_rounded,
              height: 40,
              isLoading: isOpeningPayment,
            ),
          ),
        );
      }
    }
    else if (contract.status == ContractStatusEnum.paymentExpired) {
      // paymentExpired → Gerar Pagamento
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: CardActionButton(
            label: 'Gerar Pagamento',
            onPressed: () => _onGeneratePayment(contract),
            icon: Icons.refresh_rounded,
            height: 40,
          ),
        ),
      );
    } else if (contract.status == ContractStatusEnum.paymentRefused ||
        contract.status == ContractStatusEnum.paymentFailed) {
      // paymentRefused ou paymentFailed → Tentar Novamente
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: CardActionButton(
            label: 'Tentar Novamente',
            onPressed: () => _onRetryPayment(contract),
            icon: Icons.refresh_rounded,
            height: 40,
          ),
        ),
      );
    }

    return buttons;
  }

  static const _paymentRedirectDelay = Duration(seconds: 7);

  void _onMakePayment(ContractEntity contract) {
    if (contract.linkPayment == null || contract.linkPayment!.isEmpty) {
      context.showError('Link de pagamento não disponível. Entre em contato com o suporte.');
      return;
    }
    if (contract.uid == null || contract.uid!.isEmpty) return;

    final uid = contract.uid!;
    _lastMakePaymentContractUid = uid;
    final cubit = context.read<ContractPayingCubit>();
    cubit.addOpening(uid);
    context.read<ContractsBloc>().add(
      MakePaymentEvent(linkPayment: contract.linkPayment!, contractUid: uid),
    );
    Future.delayed(_paymentRedirectDelay, () {
      if (mounted) cubit.finishOpeningAndSetPaying(uid);
    });
  }

  void _onVerifyPayment(ContractEntity contract) {
    if (contract.uid == null || contract.uid!.isEmpty) return;
    context.read<ContractPayingCubit>().removePaying(contract.uid!);
    context.read<ContractsBloc>().add(
      VerifyPaymentEvent(contractUid: contract.uid!),
    );
  }

  void _onGeneratePayment(ContractEntity contract) {
    // TODO: Implementar lógica de gerar pagamento
    debugPrint('Gerar pagamento: ${contract.uid}');
  }

  void _onRetryPayment(ContractEntity contract) {
    // TODO: Implementar lógica de tentar novamente pagamento
    debugPrint('Tentar novamente pagamento: ${contract.uid}');
  }
}

