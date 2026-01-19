import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/agenda_tab/agenda_view_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/availability_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

/// Tela principal de gerenciamento de disponibilidade
/// 
/// Contém duas tabs:
/// - Tab 1: Calendário (gerencial - com edição)
/// - Tab 2: Agenda (operacional - somente leitura)
@RoutePage(deferredLoading: true)
class AvailabilityManagementScreen extends StatefulWidget {

  const AvailabilityManagementScreen({
    super.key,
  });

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Disponibilidade',
      showAppBarBackButton: true,
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
              tabs: const [
                Tab(text: 'Calendário'),
                Tab(text: 'Agenda'),
              ],
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AvailabilityCalendarWidget(),
                AgendaViewWidget(),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
