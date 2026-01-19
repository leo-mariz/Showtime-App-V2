import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/app_navigation/presentation/pages/navigation_page.dart';
import 'package:app/features/artist_dashboard/domain/entities/artist_dashboard_stats_entity.dart';
import 'package:app/features/artist_dashboard/presentation/bloc/artist_dashboard_bloc.dart';
import 'package:app/features/artist_dashboard/presentation/bloc/events/artist_dashboard_events.dart';
import 'package:app/features/artist_dashboard/presentation/bloc/states/artist_dashboard_states.dart';
import 'package:app/features/artist_dashboard/presentation/widgets/metric_card.dart';
// import 'package:app/features/artist_dashboard/presentation/widgets/period_filter_section.dart';
import 'package:app/features/artist_dashboard/presentation/widgets/next_show_card.dart';
// import 'package:app/features/artist_dashboard/presentation/widgets/quick_action_button.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/profile/artists/presentation/widgets/profile_completeness_card_simple.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  // Chart carousel state
  late PageController _chartPageController;
  int _currentChartIndex = 0;
  bool _hasLoadedInitialData = false;

  final List<String> _chartTitles = [
    'Receita',
    'Contratos',
    'Solicitações',
    'Taxa de Aceitação',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chartPageController = PageController();
    
    // Carregar dados apenas na primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData(forceRefresh: false);
    });
  }

  void _loadDashboardData({bool forceRefresh = false}) {
    if (!mounted) return;

    // Carregar dados do artista se ainda não estiverem carregados ou se forçado
    final artistsBloc = context.read<ArtistsBloc>();
    if (forceRefresh || artistsBloc.state is! GetArtistSuccess) {
      artistsBloc.add(GetArtistEvent());
    }
    
    // Carregar estatísticas do dashboard apenas se não tiver carregado ou se forçado
    final dashboardBloc = context.read<ArtistDashboardBloc>();
    if (forceRefresh || !_hasLoadedInitialData) {
      dashboardBloc.add(GetArtistDashboardStatsEvent(forceRefresh: forceRefresh));
      _hasLoadedInitialData = true;
    }
  }

  void _refreshDashboard() {
    if (!mounted) return;
    // Usar um pequeno delay para garantir que o estado foi processado
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadDashboardData(forceRefresh: true);
      }
    });
  }

  void _navigateToPresentations() {
    // Navegar para a tela de apresentações (índice 1 do NavigationPage)
    // O NavigationPage gerencia as páginas usando PageController
    // Vamos encontrar o NavigationPage e mudar o índice usando dynamic para acessar o método público
    final navigationState = context.findAncestorStateOfType<State<NavigationPage>>();
    if (navigationState != null) {
      (navigationState as dynamic).navigateToPage(1);
    }
  }

  @override
  void dispose() {
    _chartPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário quando usar AutomaticKeepAliveClientMixin
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
    final currentDate = dateFormat.format(now);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<ArtistsBloc>(),
        ),
        BlocProvider.value(
          value: context.read<ArtistDashboardBloc>(),
        ),
        BlocProvider.value(
          value: context.read<ContractsBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ArtistDashboardBloc, ArtistDashboardState>(
            listener: (context, state) {
              if (state is GetArtistDashboardStatsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao carregar estatísticas: ${state.error}'),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
          ),
          // Listener para mudanças nos contratos que afetam o dashboard
          BlocListener<ContractsBloc, ContractsState>(
            listenWhen: (previous, current) {
              // Só escutar quando houver mudança relevante
              return current is AcceptContractSuccess ||
                  current is RejectContractSuccess ||
                  current is ConfirmShowSuccess ||
                  current is RateArtistSuccess ||
                  current is RateClientSuccess ||
                  current is CancelContractSuccess ||
                  current is MakePaymentSuccess ||
                  current is VerifyPaymentSuccess ||
                  // Também escutar quando voltar para Initial após um loading
                  (current is ContractsInitial &&
                      (previous is AcceptContractLoading ||
                          previous is RejectContractLoading ||
                          previous is ConfirmShowLoading ||
                          previous is RateArtistLoading ||
                          previous is RateClientLoading ||
                          previous is CancelContractLoading ||
                          previous is MakePaymentLoading ||
                          previous is VerifyPaymentLoading));
            },
            listener: (context, state) {
              // Recarregar dashboard quando houver mudanças relevantes nos contratos
              _refreshDashboard();
            },
          ),
          // Listener para mudanças no artista que afetam o dashboard
          BlocListener<ArtistsBloc, ArtistsState>(
            listener: (context, state) {
              // Recarregar dashboard quando houver mudanças relevantes no artista
              // Não escutamos GetArtistSuccess para evitar recarregar no primeiro carregamento
              // Apenas escutamos estados de atualização que indicam mudanças reais
              if (state is UpdateArtistSuccess ||
                  state is UpdateArtistProfilePictureSuccess ||
                  state is UpdateArtistNameSuccess ||
                  state is UpdateArtistProfessionalInfoSuccess) {
                _refreshDashboard();
              }
            },
          ),
        ],
        child: BasePage(
          showAppBar: true,
          appBarTitle: 'Dashboard',
          child: BlocBuilder<ArtistsBloc, ArtistsState>(
            builder: (context, artistsState) {
              return BlocBuilder<ArtistDashboardBloc, ArtistDashboardState>(
                builder: (context, dashboardState) {
                  // Verificar se está carregando
                  final isLoading = dashboardState is GetArtistDashboardStatsLoading ||
                      artistsState is GetArtistLoading;

                  // Obter dados do artista
                  final artist = artistsState is GetArtistSuccess ? artistsState.artist : null;
                  final artistName = artist?.artistName ?? '';
                  final artistPhoto = artist?.profilePicture;
                  final isActive = artist?.isActive ?? false;

                  // Obter estatísticas
                  final stats = dashboardState is GetArtistDashboardStatsSuccess
                      ? dashboardState.stats
                      : null;

                  if (isLoading && stats == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with greeting
                        _buildHeader(
                          textTheme,
                          colorScheme,
                          currentDate,
                          artistName,
                          artistPhoto,
                          isActive,
                        ),
                        DSSizedBoxSpacing.vertical(24),

                        // Completude do perfil
                        if (artist != null && artist.hasIncompleteSections == true) ...[
                          ProfileCompletenessCardSimple(artist: artist),
                          DSSizedBoxSpacing.vertical(24),
                        ],

                        // Main metrics grid
                        if (stats != null) ...[
                          _buildMetricsGrid(colorScheme, stats),
                          DSSizedBoxSpacing.vertical(24),

                          // Próximo show
                          if (stats.nextShow != null) ...[
                            _buildSectionTitle(textTheme, 'Próximo Show'),
                            DSSizedBoxSpacing.vertical(8),
                            NextShowCard(
                              nextShow: stats.nextShow!,
                              onTap: () {
                                // TODO: Navegar para detalhes do show
                              },
                            ),
                            DSSizedBoxSpacing.vertical(24),
                          ],

                          // Earnings chart
                          _buildSectionTitle(textTheme, 'Performance'),
                          DSSizedBoxSpacing.vertical(8),
                          _buildEarningsChart(textTheme, colorScheme, stats),
                          DSSizedBoxSpacing.vertical(24),

                          // Performance summary
                          _buildSectionTitle(textTheme, 'Resumo de Atividades'),
                          DSSizedBoxSpacing.vertical(8),
                          _buildPerformanceSummary(textTheme, colorScheme, stats),
                          DSSizedBoxSpacing.vertical(24),
                        ],

                        // // Quick actions
                        // _buildQuickActions(textTheme, colorScheme),
                        // DSSizedBoxSpacing.vertical(24),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String currentDate,
    String artistName,
    String? artistPhoto,
    bool isActive,
  ) {
    return Row(
      children: [
        CustomCircleAvatar(
          imageUrl: artistPhoto,
          size: DSSize.width(80),
        ),
        DSSizedBoxSpacing.horizontal(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artistName.isNotEmpty ? 'Olá, $artistName' : 'Olá',
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
                    color: isActive
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.error,
                  ),
                  DSSizedBoxSpacing.horizontal(4),
                  Text(
                    isActive ? 'Perfil ativo' : 'Perfil incompleto',
                    style: textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(
    ColorScheme colorScheme,
    ArtistDashboardStatsEntity stats,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: [
        MetricCard(
          icon: Icons.attach_money,
          value: _formatCurrency(stats.monthEarnings),
          label: 'Ganhos este mês',
          subtitle: stats.growthPercentage > 0
              ? '+${stats.growthPercentage.toStringAsFixed(0)}% vs mês anterior'
              : null,
          iconColor: colorScheme.onSecondaryContainer,
        ),
        MetricCard(
          icon: Icons.star,
          value: '${stats.averageRating.toStringAsFixed(1)} ⭐',
          label: 'Avaliação média',
          subtitle: 'de ${stats.totalReviews} avaliações',
          iconColor: colorScheme.onPrimaryContainer,
        ),
        MetricCard(
          icon: Icons.calendar_today,
          value: '${stats.upcomingEvents}',
          label: 'Eventos agendados',
          subtitle: stats.upcomingEvents > 0 ? 'Próximos eventos' : null,
          iconColor: colorScheme.onPrimaryContainer,
        ),
        MetricCard(
          icon: Icons.pending_actions,
          value: '${stats.pendingRequests}',
          label: 'Solicitações pendentes',
          subtitle: stats.pendingRequests > 0 ? 'Requerem atenção' : null,
          iconColor: stats.pendingRequests > 0
              ? colorScheme.onTertiaryContainer
              : colorScheme.onPrimaryContainer,
        ),
      ],
    );
  }

  Widget _buildEarningsChart(
    TextTheme textTheme,
    ColorScheme colorScheme,
    ArtistDashboardStatsEntity stats,
  ) {
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
                onPressed: _currentChartIndex > 0
                    ? () {
                        _chartPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
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
                onPressed: _currentChartIndex < _chartTitles.length - 1
                    ? () {
                        _chartPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
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
                _buildBarChart(textTheme, colorScheme, stats, 'earnings', true),
                _buildBarChart(textTheme, colorScheme, stats, 'contracts', false),
                _buildBarChart(textTheme, colorScheme, stats, 'requests', false),
                _buildBarChart(textTheme, colorScheme, stats, 'acceptanceRate', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    TextTheme textTheme,
    ColorScheme colorScheme,
    ArtistDashboardStatsEntity stats,
    String dataKey,
    bool isCurrency,
  ) {
    if (stats.monthlyStats.isEmpty) {
      return Center(
        child: Text(
          'Sem dados disponíveis',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final values = stats.monthlyStats.map((month) {
      switch (dataKey) {
        case 'earnings':
          return month.earnings;
        case 'contracts':
          return month.contracts.toDouble();
        case 'requests':
          return month.requests.toDouble();
        case 'acceptanceRate':
          return month.acceptanceRate;
        default:
          return 0.0;
      }
    }).toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final hasData = maxValue > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(stats.monthlyStats.length, (index) {
        final month = stats.monthlyStats[index];
        final value = values[index];
        final height = hasData ? (value / maxValue) : 0.0;
        final isCurrentMonth = index == stats.monthlyStats.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isCurrency
                      ? _formatCurrency(value, showDecimals: false)
                      : dataKey == 'acceptanceRate'
                          ? '${value.toStringAsFixed(0)}%'
                          : value.toStringAsFixed(0),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                DSSizedBoxSpacing.vertical(4),
                Container(
                  height: DSSize.height(hasData ? height * 110 : 0),
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onPrimaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(DSSize.width(4)),
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                Text(
                  month.month,
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
    TextTheme textTheme,
    ColorScheme colorScheme,
    ArtistDashboardStatsEntity stats,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Resumo de Atividades',
          //   style: textTheme.titleSmall?.copyWith(
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // DSSizedBoxSpacing.vertical(16),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.check_circle,
            'Aceitas este mês',
            '${stats.completedEvents} eventos',
          ),
          DSSizedBoxSpacing.vertical(12),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.event_available,
            'Concluídas',
            '${stats.completedEvents} eventos',
          ),
          DSSizedBoxSpacing.vertical(12),
          _buildSummaryRow(
            textTheme,
            colorScheme,
            Icons.trending_up,
            'Taxa de aceitação',
            '${stats.acceptanceRate.toStringAsFixed(0)}%',
          ),
          DSSizedBoxSpacing.vertical(16),
          CustomButton(
            label: 'Ver todas as solicitações',
            onPressed: () {
              _navigateToPresentations();
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

  // Widget _buildQuickActions(TextTheme textTheme, ColorScheme colorScheme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Ações Rápidas',
  //         style: textTheme.titleSmall?.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       DSSizedBoxSpacing.vertical(16),
  //       GridView.count(
  //         crossAxisCount: 2,
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         mainAxisSpacing: 16,
  //         crossAxisSpacing: 16,
  //         childAspectRatio: 1.5,
  //         children: [
  //           QuickActionButton(
  //             icon: Icons.calendar_month,
  //             label: 'Ver Agenda',
  //             onTap: () {
  //               // Placeholder
  //             },
  //           ),
  //           QuickActionButton(
  //             icon: Icons.description,
  //             label: 'Ver Solicitações',
  //             onTap: () {
  //               // Placeholder
  //             },
  //           ),
  //           QuickActionButton(
  //             icon: Icons.star_rate,
  //             label: 'Ver Avaliações',
  //             onTap: () {
  //               // Placeholder
  //             },
  //           ),
  //           QuickActionButton(
  //             icon: Icons.analytics,
  //             label: 'Ver Relatórios',
  //             onTap: () {
  //               // Placeholder
  //             },
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  String _formatCurrency(double value, {bool showDecimals = true}) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return formatter.format(value);
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
      ),
    );
  }
}
