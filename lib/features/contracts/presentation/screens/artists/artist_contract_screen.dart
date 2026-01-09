import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/card_action_button.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/widgets/contract_card.dart';
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
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Buscar contratos ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContracts();
    });
  }

  Future<void> _loadContracts() async {
      context.read<ContractsBloc>().add(
        GetContractsByArtistEvent(),
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
              contract.status == ContractStatusEnum.accepted ||
              contract.status == ContractStatusEnum.paymentPending ||
              contract.status == ContractStatusEnum.paymentExpired ||
              contract.status == ContractStatusEnum.paymentRefused;
        }).toList();
      case 1: // Confirmadas
        return _allContracts.where((contract) {
          return contract.status == ContractStatusEnum.paid ||
              contract.status == ContractStatusEnum.confirmed;
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
          } else if (state is AcceptContractLoading) {
            // Não precisa fazer nada, o BlocBuilder vai atualizar
          } else if (state is AcceptContractSuccess) {
            setState(() {
              _processingContractUid = null; // Reset após sucesso
            });
            context.showSuccess('Solicitação aceita com sucesso!');
            // Recarregar contratos após sucesso
            _loadContracts();
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
            // Recarregar contratos após sucesso
            _loadContracts();
          } else if (state is RejectContractFailure) {
            setState(() {
              _processingContractUid = null; // Reset após falha
            });
            context.showError(state.error);
          }
        },
        child: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            final isLoading = state is GetContractsByArtistLoading;
            final isAccepting = state is AcceptContractLoading;
            final isRejecting = state is RejectContractLoading;
            final filteredContracts = _filteredContracts;

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
                      tabs: const [
                        Tab(text: 'Abertas'),
                        Tab(text: 'Confirmadas'),
                        Tab(text: 'Finalizadas'),
                      ],
                    ),
                  ),

                  DSSizedBoxSpacing.vertical(24),

                  // Lista de contratos
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
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
    }

    return buttons;
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

