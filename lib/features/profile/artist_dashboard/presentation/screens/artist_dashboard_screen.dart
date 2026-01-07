import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/profile/artist_dashboard/presentation/widgets/metric_card.dart';
// import 'package:app/features/artist_dashboard/presentation/widgets/period_filter_section.dart';
import 'package:app/features/profile/artist_dashboard/presentation/widgets/quick_action_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  // Period filter state
  // DateTime? _startDate;
  // DateTime? _endDate;

  // Chart carousel state
  late PageController _chartPageController;
  int _currentChartIndex = 0;

  // Mock data (geral)
  final String artistName = "Marina Santos";
  final double monthEarnings = 12450.00;
  final double totalEarnings = 89300.00;
  final double growthPercentage = 23.0;
  final double averageRating = 4.9;
  final int totalReviews = 234;
  final int pendingRequests = 7;
  final int upcomingEvents = 15;
  final int completedEvents = 12;
  final double acceptanceRate = 92.0;

  // Chart data for last 6 months
  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Jul', 'earnings': 8500.0, 'contracts': 12, 'requests': 18, 'acceptanceRate': 88.0},
    {'month': 'Ago', 'earnings': 9200.0, 'contracts': 14, 'requests': 20, 'acceptanceRate': 90.0},
    {'month': 'Set', 'earnings': 10100.0, 'contracts': 15, 'requests': 22, 'acceptanceRate': 91.0},
    {'month': 'Out', 'earnings': 9800.0, 'contracts': 14, 'requests': 21, 'acceptanceRate': 89.0},
    {'month': 'Nov', 'earnings': 11200.0, 'contracts': 16, 'requests': 24, 'acceptanceRate': 93.0},
    {'month': 'Dez', 'earnings': 12450.0, 'contracts': 18, 'requests': 25, 'acceptanceRate': 92.0},
  ];

  final List<String> _chartTitles = [
    'Receita',
    'Contratos',
    'Solicitações',
    'Taxa de Aceitação',
  ];

  @override
  void initState() {
    super.initState();
    _chartPageController = PageController();
  }

  @override
  void dispose() {
    _chartPageController.dispose();
    super.dispose();
  }

  // // Mock data filtrado (será calculado baseado no período selecionado)
  // double get _filteredEarnings {
  //   if (_startDate == null || _endDate == null) return 0.0;
  //   // Simulação: receita proporcional ao período
  //   final days = _endDate!.difference(_startDate!).inDays;
  //   return (monthEarnings / 30) * days;
  // }

  // int get _filteredRequests {
  //   if (_startDate == null || _endDate == null) return 0;
  //   // Simulação: solicitações no período
  //   final days = _endDate!.difference(_startDate!).inDays;
  //   return (pendingRequests * days / 30).round();
  // }

  // int get _filteredPresentations {
  //   if (_startDate == null || _endDate == null) return 0;
  //   // Simulação: apresentações no período
  //   final days = _endDate!.difference(_startDate!).inDays;
  //   return (completedEvents * days / 30).round();
  // }

  // double get _filteredAcceptanceRate {
  //   if (_startDate == null || _endDate == null) return 0.0;
  //   // Simulação: taxa de aceitação no período (pode variar)
  //   return acceptanceRate + (DateTime.now().day % 10 - 5);
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
    final currentDate = dateFormat.format(now);
    final bool isActive = false;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            _buildHeader(textTheme, colorScheme, currentDate, isActive),
            DSSizedBoxSpacing.vertical(24),

            // // Main metrics grid
            // _buildMetricsGrid(colorScheme),
            // DSSizedBoxSpacing.vertical(24),

            // Earnings chart placeholder
            _buildEarningsChart(textTheme, colorScheme),
            DSSizedBoxSpacing.vertical(24),

            // Performance summary
            _buildPerformanceSummary(textTheme, colorScheme),
            DSSizedBoxSpacing.vertical(24),

            // Quick actions
            _buildQuickActions(textTheme, colorScheme),
            DSSizedBoxSpacing.vertical(24),

            // Period analysis section (isolated section with filter and filtered metrics)
            // _buildPeriodAnalysisSection(textTheme, colorScheme),
            // DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme, String currentDate, bool isActive) {
    return 
    Row(
      children: [
        CustomCircleAvatar(
          // imageUrl: '',
          size: DSSize.width(80),
        ),
        DSSizedBoxSpacing.horizontal(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              'Olá, $artistName',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            DSSizedBoxSpacing.vertical(4),
            Text(
              'Hoje é $currentDate',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            DSSizedBoxSpacing.vertical(8),
            Row(
              children: [
                Icon(
                  isActive ? Icons.verified : Icons.error,
                  size: DSSize.width(16),
                  color: isActive ? colorScheme.onSecondaryContainer : colorScheme.error,
                ),
                DSSizedBoxSpacing.horizontal(4),
                Text(
                  isActive ? 'Perfil ativo' : 'Perfil incompleto',
                  style: textTheme.bodySmall?.copyWith(
                    color: isActive ? colorScheme.onSecondaryContainer : colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      // Aumenta a altura útil dos cards para evitar overflow de texto
      childAspectRatio: 1.05,
      children: [
        MetricCard(
          icon: Icons.attach_money,
          value: _formatCurrency(monthEarnings),
          label: 'Ganhos este mês',
          subtitle: growthPercentage > 0
              ? '+${growthPercentage.toStringAsFixed(0)}% vs mês anterior'
              : null,
          iconColor: colorScheme.onSecondaryContainer,
        ),
        MetricCard(
          icon: Icons.star,
          value: '${averageRating.toStringAsFixed(1)} ⭐',
          label: 'Avaliação média',
          subtitle: 'de $totalReviews avaliações',
          iconColor: colorScheme.onPrimaryContainer,
        ),
        MetricCard(
          icon: Icons.calendar_today,
          value: '$upcomingEvents',
          label: 'Eventos agendados',
          subtitle: 'Próximo evento em 3 dias',
          iconColor: colorScheme.onPrimaryContainer,
        ),
        MetricCard(
          icon: Icons.pending_actions,
          value: '$pendingRequests',
          label: 'Solicitações pendentes',
          subtitle: pendingRequests > 0 ? 'Requerem atenção' : null,
          iconColor: pendingRequests > 0
              ? colorScheme.error
              : colorScheme.onPrimaryContainer,
        ),
        
      ],
    );
  }

  Widget _buildEarningsChart(TextTheme textTheme, ColorScheme colorScheme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Últimos 6 meses',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          DSSizedBoxSpacing.vertical(12),
          // Navigation with metric name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: DSSize.width(18),
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  _chartPageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  _chartTitles[_currentChartIndex],
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: DSSize.width(18),
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  _chartPageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(16),
          // Chart carousel
          SizedBox(
            height: DSSize.height(200),
            child: PageView(
              controller: _chartPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentChartIndex = index;
                });
              },
              children: [
                _buildBarChart(textTheme, colorScheme, 'earnings', true),
                _buildBarChart(textTheme, colorScheme, 'contracts', false),
                _buildBarChart(textTheme, colorScheme, 'requests', false),
                _buildBarChart(textTheme, colorScheme, 'acceptanceRate', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
      TextTheme textTheme, ColorScheme colorScheme, String dataKey, bool isCurrency) {
    final values = _monthlyData.map((e) => e[dataKey] as num).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_monthlyData.length, (index) {
        final data = _monthlyData[index];
        final value = data[dataKey] as num;
        final height = value.toDouble() / maxValue;
        final isCurrentMonth = index == _monthlyData.length - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isCurrency
                              ? _formatCurrency(value.toDouble(), showDecimals: false)
                              : dataKey == 'acceptanceRate'
                                  ? '${value.toStringAsFixed(0)}%'
                                  : value.toString(),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        DSSizedBoxSpacing.vertical(4),
                        Container(
                  height: DSSize.height(height * 110),
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onPrimaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(DSSize.width(4)),
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(4),
                        Text(
                          data['month'] as String,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
      }),
    );
  }

  Widget _buildPerformanceSummary(
      TextTheme textTheme, ColorScheme colorScheme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo de Atividades',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.check_circle,
            'Aceitas este mês',
            '$completedEvents eventos',
          ),
          DSSizedBoxSpacing.vertical(12),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.event_available,
            'Concluídas',
            '$completedEvents eventos',
          ),
          DSSizedBoxSpacing.vertical(12),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.trending_up,
            'Taxa de aceitação',
            '${acceptanceRate.toStringAsFixed(0)}%',
          ),
          DSSizedBoxSpacing.vertical(16),
          CustomButton(
            label: 'Ver todas as solicitações',
            onPressed: () {
              // Placeholder - será implementado depois
            },
            backgroundColor: colorScheme.onPrimaryContainer,
            textColor: colorScheme.primaryContainer,
            icon: Icons.arrow_forward,
            iconOnRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(TextTheme textTheme, ColorScheme colorScheme,
      IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: DSSize.width(20),
              color: colorScheme.onPrimaryContainer,
            ),
            DSSizedBoxSpacing.horizontal(8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget _buildPeriodAnalysisSection(
  //     TextTheme textTheme, ColorScheme colorScheme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Análise por Período',
  //         style: textTheme.titleSmall?.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       DSSizedBoxSpacing.vertical(16),
  //       // Period filter
  //       PeriodFilterSection(
  //         startDate: _startDate,
  //         endDate: _endDate,
  //         onStartDateChanged: (date) {
  //           setState(() {
  //             _startDate = date;
  //           });
  //         },
  //         onEndDateChanged: (date) {
  //           setState(() {
  //             _endDate = date;
  //           });
  //         },
  //       ),
  //       // Filtered metrics (only shown when period is selected)
  //       if (_startDate != null && _endDate != null) ...[
  //         DSSizedBoxSpacing.vertical(16),
  //         _buildFilteredMetricsSection(textTheme, colorScheme),
  //       ],
  //     ],
  //   );
  // }

  // Widget _buildFilteredMetricsSection(
  //     TextTheme textTheme, ColorScheme colorScheme) {
  //   return CustomCard(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Métricas do Período',
  //               style: textTheme.titleSmall?.copyWith(
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             Icon(
  //               Icons.analytics,
  //               size: DSSize.width(20),
  //               color: colorScheme.onPrimaryContainer,
  //             ),
  //           ],
  //         ),
  //         DSSizedBoxSpacing.vertical(8),
  //         Text(
  //           '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
  //           style: textTheme.bodySmall?.copyWith(
  //             color: colorScheme.onSurfaceVariant,
  //             fontSize: 11,
  //           ),
  //         ),
  //         DSSizedBoxSpacing.vertical(16),
  //         GridView.count(
  //           crossAxisCount: 2,
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           mainAxisSpacing: 16,
  //           crossAxisSpacing: 16,
  //           childAspectRatio: 1.05,
  //           children: [
  //             MetricCard(
  //               icon: Icons.attach_money,
  //               value: _formatCurrency(_filteredEarnings),
  //               label: 'Receita',
  //               subtitle: 'No período',
  //               iconColor: colorScheme.onTertiaryContainer,
  //             ),
  //             MetricCard(
  //               icon: Icons.description,
  //               value: '$_filteredRequests',
  //               label: 'Solicitações',
  //               subtitle: 'Recebidas',
  //               iconColor: colorScheme.onSecondaryContainer,
  //             ),
  //             MetricCard(
  //               icon: Icons.event_available,
  //               value: '$_filteredPresentations',
  //               label: 'Apresentações',
  //               subtitle: 'Realizadas',
  //               iconColor: colorScheme.onPrimaryContainer,
  //             ),
  //             MetricCard(
  //               icon: Icons.trending_up,
  //               value: '${_filteredAcceptanceRate.toStringAsFixed(0)}%',
  //               label: 'Taxa de Aceitação',
  //               subtitle: 'No período',
  //               iconColor: colorScheme.onTertiaryContainer,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuickActions(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        DSSizedBoxSpacing.vertical(16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            QuickActionButton(
              icon: Icons.calendar_month,
              label: 'Ver Agenda',
              onTap: () {
                // Placeholder
              },
            ),
            QuickActionButton(
              icon: Icons.description,
              label: 'Ver Solicitações',
              onTap: () {
                // Placeholder
              },
            ),
            QuickActionButton(
              icon: Icons.star_rate,
              label: 'Ver Avaliações',
              onTap: () {
                // Placeholder
              },
            ),
            QuickActionButton(
              icon: Icons.analytics,
              label: 'Ver Relatórios',
              onTap: () {
                // Placeholder
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double value, {bool showDecimals = true}) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return formatter.format(value);
  }
}
