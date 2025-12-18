import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/event/event_entity.dart';
import 'package:app/core/domain/event/event_type/event_type_entity.dart';
import 'package:app/core/enums/event_status_enum.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/contracts/presentation/widgets/contract_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ClientContractsScreen extends StatefulWidget {
  const ClientContractsScreen({super.key});

  @override
  State<ClientContractsScreen> createState() => _ClientContractsScreenState();
}

class _ClientContractsScreenState extends State<ClientContractsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // TODO: Substituir por dados reais do Bloc
  final List<EventEntity> _allRequests = [
    // Solicitações Pendentes
    EventEntity(
      date: DateTime.now().add(const Duration(days: 5)),
      time: '18:00',
      duration: 120,
      address: null, // TODO: Adicionar endereço real
      status: EventStatusEnum.pending.name,
      nameArtist: 'João Silva',
      eventType: EventTypeEntity(
        uid: '1',
        name: 'Festa de Aniversário',
        active: 'true',
      ),
      value: 450.0,
    ),
    EventEntity(
      date: DateTime.now().add(const Duration(days: 10)),
      time: '20:00',
      duration: 90,
      address: null,
      status: EventStatusEnum.pending.name,
      nameArtist: 'Maria Santos',
      eventType: EventTypeEntity(
        uid: '2',
        name: 'Casamento',
        active: 'true',
      ),
      value: 380.0,
    ),
    // Solicitações Aceitas
    EventEntity(
      date: DateTime.now().add(const Duration(days: 3)),
      time: '19:30',
      duration: 150,
      address: null,
      status: EventStatusEnum.accepted.name,
      nameArtist: 'Pedro Oliveira',
      eventType: EventTypeEntity(
        uid: '3',
        name: 'Evento Corporativo',
        active: 'true',
      ),
      value: 600.0,
    ),
    // Solicitações Recusadas
    EventEntity(
      date: DateTime.now().subtract(const Duration(days: 2)),
      time: '17:00',
      duration: 120,
      address: null,
      status: EventStatusEnum.rejected.name,
      nameArtist: 'Ana Costa',
      eventType: EventTypeEntity(
        uid: '4',
        name: 'Show Musical',
        active: 'true',
      ),
      value: 400.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<EventEntity> get _filteredRequests {
    switch (_selectedTabIndex) {
      case 0: // Solicitadas
        return _allRequests
            .where((req) => req.status.toUpperCase() == EventStatusEnum.pending.name)
            .toList();
      case 1: // Aceitas
        return _allRequests
            .where((req) => req.status.toUpperCase() == EventStatusEnum.accepted.name)
            .toList();
      case 2: // Recusadas
        return _allRequests
            .where((req) => req.status.toUpperCase() == EventStatusEnum.rejected.name)
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

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
                Tab(text: 'Solicitadas'),
                Tab(text: 'Aceitas'),
                Tab(text: 'Recusadas'),
              ],
            ),
          ),

          DSSizedBoxSpacing.vertical(24),

          // Lista de solicitações
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = _filteredRequests[index];
                      return ContractCard(
                        event: request,
                        onTap: () => _onRequestTapped(request),
                        onCancel: () => _onCancelRequest(request),
                        onViewDetails: () => _onRequestTapped(request),
                      );
                    },
                  ),
          ),
        ],
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
      case 0:
        icon = Icons.inbox_outlined;
        message = 'Nenhuma solicitação pendente.\nSuas solicitações aparecerão aqui.';
        break;
      case 1:
        icon = Icons.check_circle_outline;
        message = 'Nenhuma solicitação aceita.\nAs solicitações aceitas aparecerão aqui.';
        break;
      case 2:
        icon = Icons.cancel_outlined;
        message = 'Nenhuma solicitação recusada.\nAs solicitações recusadas aparecerão aqui.';
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

  void _onRequestTapped(EventEntity request) {
    context.router.push(ClientEventDetailRoute(event: request));
  }

  void _onCancelRequest(EventEntity request) {
    // TODO: Implementar lógica de cancelamento
    debugPrint('Cancelar solicitação: ${request.uid}');
    // TODO: Mostrar confirmação e atualizar status
  }
}

