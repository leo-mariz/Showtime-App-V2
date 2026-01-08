import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
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
    // Obter UID do cliente
    final usersBloc = context.read<UsersBloc>();
    final uidResult = await usersBloc.getUserUidUseCase.call();
    final clientUid = uidResult.fold(
      (failure) => null,
      (uid) => uid,
    );

    if (clientUid != null && clientUid.isNotEmpty) {
      context.read<ContractsBloc>().add(
        GetContractsByClientEvent(clientUid: clientUid),
      );
    }
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
          if (state is GetContractsByClientSuccess) {
            setState(() {
              _allContracts = state.contracts;
            });
          } else if (state is GetContractsByClientFailure) {
            context.showError(state.error);
          }
        },
        child: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            final isLoading = state is GetContractsByClientLoading;
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
                                    onCancel: () => _onCancelRequest(contract),
                                    onViewDetails: () => _onRequestTapped(contract),
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

  void _onRequestTapped(ContractEntity request) {
    context.router.push(ClientEventDetailRoute(contract: request));
  }

  void _onCancelRequest(ContractEntity request) {
    // TODO: Implementar lógica de cancelamento
    debugPrint('Cancelar solicitação: ${request.uid}');
    // TODO: Mostrar confirmação e atualizar status
  }
}

