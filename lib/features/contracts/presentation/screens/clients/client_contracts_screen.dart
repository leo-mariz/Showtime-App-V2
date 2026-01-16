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
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/widgets/contract_card.dart';
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
  // bool _isTryingToPay = false;

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
          } else if (state is GetContractsByClientFailure) {
            context.showError(state.error);
            setState(() {
              _isLoading = false;
            });
          } else if (state is MakePaymentSuccess) {
            // Recarregar contratos após pagamento bem-sucedido
            _loadContracts();
          } else if (state is MakePaymentFailure) {
            context.showError(state.error);
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
          }
        },
        child: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            final filteredContracts = _filteredContracts;
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
                      tabs: const [
                        Tab(text: 'Em aberto'),
                        Tab(text: 'Confirmadas'),
                        Tab(text: 'Finalizados'),
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
                                    actionButtons: _buildActionButtons(contract),
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
      ClientEventDetailRoute(contract: request),
    );
    
    // Se voltou da tela de detalhes com indicação de que precisa recarregar
    if (result == true && mounted) {
      _loadContracts();
    }
  }

  // Constrói os botões de ação baseado no status do contrato (Cliente)
  List<Widget> _buildActionButtons(ContractEntity contract) {
    final buttons = <Widget>[];

    if (contract.status == ContractStatusEnum.paymentPending) {
      if (contract.isPaying == true) {
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
        // Accepted → Realizar Pagamento
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CardActionButton(
              label: 'Realizar Pagamento',
              onPressed: () => _onMakePayment(contract),
              icon: Icons.payment_rounded,
              height: 40,
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

  void _onMakePayment(ContractEntity contract) {
    if (contract.linkPayment == null || contract.linkPayment!.isEmpty) {
      context.showError('Link de pagamento não disponível. Entre em contato com o suporte.');
      return;
    }

    context.read<ContractsBloc>().add(
      MakePaymentEvent(linkPayment: contract.linkPayment!, contractUid: contract.uid!),
    );
  }

  void _onVerifyPayment(ContractEntity contract) {
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

