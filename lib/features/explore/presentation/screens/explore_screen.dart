import 'dart:async';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/explore/domain/entities/artists/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:app/features/explore/presentation/widgets/address_selector.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/date_selector.dart';
import 'package:app/features/explore/presentation/widgets/ensemble_card.dart';
// ignore: unused_import
import 'package:app/features/explore/presentation/widgets/filter_button.dart';
import 'package:app/features/explore/presentation/widgets/search_bar_widget.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late ScrollController _scrollControllerArtists;
  late ScrollController _scrollControllerEnsembles;

  AddressInfoEntity? _selectedAddress;
  DateTime _selectedDate = DateTime.now();
  static const int _pageSize = 10;

  int _artistsNextIndex = 0;
  bool _artistsHasMore = false;
  bool _isLoadingMoreArtists = false;
  int _previousArtistsListSize = 0;

  int _ensemblesNextIndex = 0;
  bool _ensemblesHasMore = false;
  bool _isLoadingMoreEnsembles = false;
  int _previousEnsemblesListSize = 0;

  Set<String> _favoriteArtistIds = {};
  Set<String> _favoriteEnsembleIds = {};
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  @override
  bool get wantKeepAlive => true;

  String get _currentAddressDisplay {
    if (_selectedAddress == null) {
      return 'Selecione um endereço';
    }
    return _selectedAddress!.title;
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollControllerArtists = ScrollController();
    _scrollControllerEnsembles = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressesState = context.read<AddressesBloc>().state;
      if (addressesState is! GetAddressesSuccess) {
        context.read<AddressesBloc>().add(GetAddressesEvent());
      } else {
        _getPrimaryAddressFromState(addressesState);
      }
      context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
      context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
    });

    _scrollControllerArtists.addListener(() {
      if (_artistsHasMore &&
          !_isLoadingMoreArtists &&
          _scrollControllerArtists.hasClients &&
          _scrollControllerArtists.position.pixels >=
              _scrollControllerArtists.position.maxScrollExtent - 200) {
        _loadMoreArtists();
      }
    });
    _scrollControllerEnsembles.addListener(() {
      if (_ensemblesHasMore &&
          !_isLoadingMoreEnsembles &&
          _scrollControllerEnsembles.hasClients &&
          _scrollControllerEnsembles.position.pixels >=
              _scrollControllerEnsembles.position.maxScrollExtent - 200) {
        _loadMoreEnsembles();
      }
    });
  }

  void _getPrimaryAddressFromState(GetAddressesSuccess state) {
    if (state.addresses.isEmpty) {
      setState(() => _selectedAddress = null);
      context.read<ExploreBloc>().add(ResetExploreEvent());
      return;
    }
    AddressInfoEntity primaryAddress;
    try {
      primaryAddress = state.addresses.firstWhere(
        (address) => address.isPrimary,
      );
    } catch (e) {
      primaryAddress = state.addresses.first;
    }
    if (_selectedAddress == null) {
      setState(() => _selectedAddress = primaryAddress);
      _onApplyFilters();
    }
  }

  /// Aplica filtros atuais (data, endereço, busca) em ambas as abas.
  /// Só carrega artistas e conjuntos quando há um endereço selecionado.
  void _onApplyFilters() {
    if (!mounted) return;
    if (_selectedAddress == null) {
      context.read<ExploreBloc>().add(ResetExploreEvent());
      return;
    }
    const forceRefresh = true;
    final query = _searchQuery.isNotEmpty ? _searchQuery : null;
    context.read<ExploreBloc>().add(
      GetArtistsWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        forceRefresh: forceRefresh,
        startIndex: 0,
        pageSize: _pageSize,
        append: false,
        searchQuery: query,
      ),
    );
    context.read<ExploreBloc>().add(
      GetEnsemblesWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        forceRefresh: forceRefresh,
        startIndex: 0,
        pageSize: _pageSize,
        append: false,
        searchQuery: query,
      ),
    );
  }

  void _onUpdateArtistFavoriteStatus(String artistId, bool isFavorite) {
    if (isFavorite) {
      context.read<FavoritesBloc>().add(RemoveFavoriteEvent(artistId: artistId));
    } else {
      context.read<FavoritesBloc>().add(AddFavoriteEvent(artistId: artistId));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollControllerArtists.dispose();
    _scrollControllerEnsembles.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário quando usar AutomaticKeepAliveClientMixin
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    return BasePage(
      // showAppBar: true,
      // appBarTitle: 'Explorar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Seletor de endereço e data
          Row(
            children: [
              // Endereço - 60% do espaço
              Flexible(
                flex: 6,
                child: AddressSelector(
                  currentAddress: _currentAddressDisplay,
                  onAddressTap: _onAddressSelected,
                ),
              ),
              DSSizedBoxSpacing.horizontal(8),
              // Data - 40% do espaço
              Flexible(
                flex: 4,
                child: DateSelector(
                  selectedDate: _selectedDate,
                  onDateTap: _onDateSelected,
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          
          if (_selectedAddress != null) ...[
            // Search Bar + Filtro (acima das abas: mesma busca em Individual e Conjuntos)
            Row(
              children: [
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Buscar artistas e conjuntos...',
                    onChanged: _onSearchChanged,
                    onClear: _onSearchCleared,
                  ),
                ),
              ],
            ),
            DSSizedBoxSpacing.vertical(12),
            Container(
              height: DSSize.height(30),
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
                    child: const Text('Individual'),
                  ),
                  Tab(
                    child: const Text('Conjuntos'),
                  ),
                ],
              ),
            ),
            DSSizedBoxSpacing.vertical(12),
          ],
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<AddressesBloc, AddressesState>(
                  listener: (context, state) {
                    if (state is GetAddressesSuccess &&
                        _selectedAddress == null) {
                      _getPrimaryAddressFromState(state);
                    }
                  },
                ),
                if (_selectedAddress != null)
                  BlocListener<ExploreBloc, ExploreState>(
                        listener: (context, state) {
                          if (state is GetArtistsWithAvailabilitiesSuccess) {
                            setState(() {
                              final n = state.artistsWithAvailabilities.length;
                              _artistsNextIndex = state.nextIndex;
                              _artistsHasMore = state.hasMore;
                              if (state.append) {
                                _isLoadingMoreArtists = false;
                              } else {
                                if (n != _previousArtistsListSize &&
                                    _scrollControllerArtists.hasClients) {
                                  _scrollControllerArtists.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              }
                              _previousArtistsListSize = n;
                            });
                          } else if (state is GetEnsemblesWithAvailabilitiesSuccess) {
                            setState(() {
                              final n = state.ensemblesWithAvailabilities.length;
                              _ensemblesNextIndex = state.nextIndex;
                              _ensemblesHasMore = state.hasMore;
                              if (state.append) {
                                _isLoadingMoreEnsembles = false;
                              } else {
                                if (n != _previousEnsemblesListSize &&
                                    _scrollControllerEnsembles.hasClients) {
                                  _scrollControllerEnsembles.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              }
                              _previousEnsemblesListSize = n;
                            });
                          }
                        },
                      ),
                      BlocListener<FavoritesBloc, FavoritesState>(
                        listener: (context, state) {
                          if (state is GetFavoriteArtistsSuccess) {
                            setState(() {
                              _favoriteArtistIds = state.artists
                                  .map((a) => a.uid ?? '')
                                  .where((id) => id.isNotEmpty)
                                  .toSet();
                            });
                          } else if (state is GetFavoriteEnsemblesSuccess) {
                            setState(() {
                              _favoriteEnsembleIds = state.ensembles
                                  .map((e) => e.ensemble.id ?? '')
                                  .where((id) => id.isNotEmpty)
                                  .toSet();
                            });
                          } else if (state is AddFavoriteSuccess) {
                            context.showSuccess('Adicionado aos favoritos');
                            context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
                          } else if (state is AddFavoriteFailure) {
                            context.showError(state.error);
                          } else if (state is RemoveFavoriteSuccess) {
                            context.showSuccess('Removido dos favoritos');
                            context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
                          } else if (state is RemoveFavoriteEnsembleSuccess) {
                            context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
                          } else if (state is RemoveFavoriteFailure) {
                            context.showError(state.error);
                          }
                        },
                      ),
                    ],
                    child: _selectedAddress == null
                        ? _buildSelectAddressMessage()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildArtistsTabContent(),
                              _buildEnsemblesTabContent(),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsTabContent() {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (prev, curr) =>
          curr.currentArtists != prev.currentArtists ||
          curr is GetArtistsWithAvailabilitiesLoading ||
          curr is GetArtistsWithAvailabilitiesFailure,
      builder: (context, state) {
        final loading = state is GetArtistsWithAvailabilitiesLoading &&
            (state.currentArtists == null || state.currentArtists!.isEmpty);
        if (loading) {
          return const Center(child: CustomLoadingIndicator());
        }
        if (state is GetArtistsWithAvailabilitiesFailure) {
          return _buildErrorCenter(
            'Erro ao carregar artistas',
            state.error,
            _onApplyFilters,
          );
        }
        final artists = state.currentArtists ?? [];
        if (artists.isEmpty) {
          return _buildEmptyCenter(
            _searchQuery.isNotEmpty
                ? 'Nenhum resultado encontrado'
                : 'Nenhum artista encontrado',
            _searchQuery.isNotEmpty
                ? 'Não encontramos artistas que correspondam à sua busca'
                : 'Não há artistas disponíveis para a data e endereço selecionados no momento.',
          );
        }
        return _buildArtistsList(artists);
      },
    );
  }

  Widget _buildEnsemblesTabContent() {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (prev, curr) =>
          curr.currentEnsembles != prev.currentEnsembles ||
          curr is GetEnsemblesWithAvailabilitiesLoading ||
          curr is GetEnsemblesWithAvailabilitiesFailure,
      builder: (context, state) {
        final loading = state is GetEnsemblesWithAvailabilitiesLoading &&
            (state.currentEnsembles == null || state.currentEnsembles!.isEmpty);
        if (loading) {
          return const Center(child: CustomLoadingIndicator());
        }
        if (state is GetEnsemblesWithAvailabilitiesFailure) {
          return _buildErrorCenter(
            'Erro ao carregar conjuntos',
            state.error,
            _onApplyFilters,
          );
        }
        final ensembles = state.currentEnsembles ?? [];
        if (ensembles.isEmpty) {
          return _buildEmptyCenter(
            _searchQuery.isNotEmpty
                ? 'Nenhum resultado encontrado'
                : 'Nenhum conjunto encontrado',
            _searchQuery.isNotEmpty
                ? 'Não encontramos conjuntos que correspondam à sua busca'
                : 'Não há conjuntos disponíveis para a data e endereço selecionados no momento.',
          );
        }
        return _buildEnsemblesList(ensembles);
      },
    );
  }

  /// Mensagem exibida quando nenhum endereço está selecionado.
  Widget _buildSelectAddressMessage() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: DSSize.width(56),
              color: colorScheme.onSurfaceVariant,
            ),
            DSSizedBoxSpacing.vertical(20),
            Text(
              'Selecione um endereço',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            DSSizedBoxSpacing.vertical(8),
            Text(
              'É necessário selecionar um endereço para ver os artistas e conjuntos disponíveis.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            DSSizedBoxSpacing.vertical(24),
            FilledButton.icon(
              onPressed: _onAddressSelected,
              icon: const Icon(Icons.add_location_alt_outlined, size: 20),
              label: const Text('Selecionar endereço'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCenter(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: DSSize.width(48),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCenter(String title, String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: DSSize.width(48),
            color: Theme.of(context).colorScheme.error,
          ),
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsList(
    List<ArtistWithAvailabilitiesEntity> artistsWithAvailabilities,
  ) {
    return ListView.builder(
      controller: _scrollControllerArtists,
      itemCount: _artistsHasMore
          ? artistsWithAvailabilities.length + 1
          : artistsWithAvailabilities.length,
      itemBuilder: (context, index) {
        // Footer loader
        if (index >= artistsWithAvailabilities.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CustomLoadingIndicator()),
          );
        }
        final artistWithAvailabilities = artistsWithAvailabilities[index];
        final artist = artistWithAvailabilities.artist;
        final availabilities = artistWithAvailabilities.availabilities;
        
        // Verificar se artista está na lista de favoritos
        final artistId = artist.uid ?? '';
        final isFavorite = _favoriteArtistIds.contains(artistId);

        // Obter média dos preços dos slots disponíveis (ou usar hourlyRate do professionalInfo)
        String? pricePerHour;
        if (availabilities.isNotEmpty) {
          final firstAvailabilityDay = availabilities.first;
          // Buscar todos os slots com valor disponível
          final availableSlots = firstAvailabilityDay.availableSlots
              .where((slot) => slot.valorHora != null)
              .toList();
          
          if (availableSlots.isNotEmpty) {
            // Calcular média dos valores dos slots
            final totalValue = availableSlots
                .map((slot) => slot.valorHora!)
                .reduce((a, b) => a + b);
            final averageValue = totalValue / availableSlots.length;
            pricePerHour = 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(averageValue)}/hora';
          } 
        } 
        // Obter descrição/bio
        final description = artist.professionalInfo?.bio ?? 'Sem descrição disponível';

        return ArtistCard(
          musicianName: artist.artistName ?? 'Artista sem nome',
          talents: artist.professionalInfo?.specialty?.join(', ') ?? 'Sem talentos definidos',
          description: description,
          contracts: artist.rateCount ?? 0,
          rating: artist.rating ?? 0.0,
          pricePerHour: pricePerHour,
          imageUrl: artist.profilePicture,
          isFavorite: isFavorite,
          artistId: artist.uid ?? '',
          onFavoriteToggle: () => _onFavoriteTapped(artist.uid ?? '', isFavorite),
          onHirePressed: () => _onRequestTapped(artistWithAvailabilities),
          onTap: () => _onArtistCardTapped(artistWithAvailabilities),
        );
      },
    );
  }

  Widget _buildEnsemblesList(
    List<EnsembleWithAvailabilitiesEntity> ensemblesWithAvailabilities,
  ) {
    return ListView.builder(
      controller: _scrollControllerEnsembles,
      itemCount: _ensemblesHasMore
          ? ensemblesWithAvailabilities.length + 1
          : ensemblesWithAvailabilities.length,
      itemBuilder: (context, index) {
        if (index >= ensemblesWithAvailabilities.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CustomLoadingIndicator()),
          );
        }
        final item = ensemblesWithAvailabilities[index];
        final ensemble = item.ensemble;
        final ownerArtist = item.ownerArtist;
        final availabilities = item.availabilities;
        final info = ensemble.professionalInfo;
        final memberCount = ensemble.members?.length ?? 0;
        final groupName = memberCount > 0
            ? '${ownerArtist?.artistName ?? 'Conjunto'} + ${memberCount-1}'
            : (ownerArtist?.artistName ?? 'Conjunto');
        var talentsSource = <String>[];
        if (ownerArtist?.professionalInfo?.specialty != null) {
          talentsSource.addAll(ownerArtist?.professionalInfo?.specialty ?? []);
        }
        for (final member in ensemble.members ?? []) {
          if (member.specialty != null) {
            talentsSource.addAll(member.specialty ?? []);
          }
        }
        talentsSource = talentsSource.toSet().toList();

        String? pricePerHour;
        if (availabilities.isNotEmpty) {
          final day = availabilities.first;
          final slots = day.availableSlots
              .where((s) => s.valorHora != null)
              .toList();
          if (slots.isNotEmpty) {
            final total =
                slots.map((s) => s.valorHora!).reduce((a, b) => a + b);
            pricePerHour =
                'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(total / slots.length)}/hora';
          }
        }
        final description = info?.bio ?? 'Sem descrição disponível';
        final ensembleId = ensemble.id ?? '';
        final isFavorite = _favoriteEnsembleIds.contains(ensembleId);
        return EnsembleCard(
          groupName: groupName,
          totalMembers: memberCount,
          talents: talentsSource.join(', '),
          description: description,
          contracts: ensemble.rateCount ?? 0,
          rating: ensemble.rating ?? 0.0,
          pricePerHour: pricePerHour,
          imageUrl: ensemble.profilePhotoUrl,
          ensembleId: ensembleId,
          isFavorite: isFavorite,
          onFavoriteToggle: () => _onEnsembleFavoriteTapped(ensembleId, isFavorite),
          onHirePressed: () => _onEnsembleRequestTapped(item),
          onTap: () => _onEnsembleCardTapped(item),
        );
      },
    );
  }

  void _onEnsembleFavoriteTapped(String ensembleId, bool isFavorite) {
    if (isFavorite) {
      context.read<FavoritesBloc>().add(RemoveFavoriteEnsembleEvent(ensembleId: ensembleId));
      setState(() => _favoriteEnsembleIds = {..._favoriteEnsembleIds}..remove(ensembleId));
    } else {
      context.read<FavoritesBloc>().add(AddFavoriteEnsembleEvent(ensembleId: ensembleId));
      setState(() => _favoriteEnsembleIds = {..._favoriteEnsembleIds, ensembleId});
    }
  }

  void _onEnsembleCardTapped(EnsembleWithAvailabilitiesEntity item) {
    final router = AutoRouter.of(context);
    final ensembleId = item.ensemble.id ?? '';
    final isFavorite = _favoriteEnsembleIds.contains(ensembleId);
    router.push(EnsembleExploreRoute(
      ensembleId: ensembleId,
      artist: item.ownerArtist,
      isFavorite: isFavorite,
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress,
    ));
  }

  void _onEnsembleRequestTapped(EnsembleWithAvailabilitiesEntity item) {
    if (_selectedAddress == null) {
      context.showError('Selecione um endereço antes de solicitar');
      return;
    }
    if (item.ownerArtist == null) {
      context.showError('Solicitação indisponível para este conjunto no momento');
      return;
    }
    final router = AutoRouter.of(context);
    router.push(RequestRoute(
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress!,
      artist: item.ownerArtist!,
      ensemble: item,
    ));
  }

  void _onAddressSelected() async {
    final selectedAddress = await AddressesModal.show(
      context: context,
      selectedAddress: _selectedAddress,
    );

    if (selectedAddress != null && selectedAddress != _selectedAddress) {
      setState(() => _selectedAddress = selectedAddress);
      _onApplyFilters();
    }
  }

  void _onDateSelected() async {
    final DateTime? picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _onApplyFilters();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _searchQuery = query.trim());
        _onApplyFilters();
      }
    });
  }

  void _onSearchCleared() {
    setState(() => _searchQuery = '');
    _searchController.clear();
    _onApplyFilters();
  }

  // void _onFilterTapped() {
  // }

  void _onFavoriteTapped(String artistId, bool isFavorite) {
    _onUpdateArtistFavoriteStatus(artistId, isFavorite);
  }

  void _onRequestTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    
    // Obter a disponibilidade do dia (já filtrada e válida)
    final availabilityDay = artistWithAvailabilities.availabilities.isNotEmpty
        ? artistWithAvailabilities.availabilities.first
        : null;

    // Obter média dos preços dos slots disponíveis ou do professionalInfo
    // ignore: unused_local_variable
    double pricePerHour = 0.0;
    if (availabilityDay != null) {
      final availableSlots = availabilityDay.availableSlots
          .where((slot) => slot.valorHora != null)
          .toList();
      
      if (availableSlots.isNotEmpty) {
        // Calcular média dos valores dos slots
        final totalValue = availableSlots
            .map((slot) => slot.valorHora!)
            .reduce((a, b) => a + b);
        pricePerHour = totalValue / availableSlots.length;
      } 
    } 

    if (_selectedAddress == null) {
      context.showError('Selecione um endereço antes de solicitar');
      return;
    }

    router.push(RequestRoute(
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress!,
      artist: artist,
    ));
  }

  void _onArtistCardTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    final isFavorite = _favoriteArtistIds.contains(artist.uid ?? '');

    router.push(ArtistExploreRoute(
      artist: artist,
      isFavorite: isFavorite, 
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress,
    ));
  }

  void _loadMoreArtists() {
    if (_selectedAddress == null || !_artistsHasMore || _isLoadingMoreArtists) return;
    _isLoadingMoreArtists = true;
    context.read<ExploreBloc>().add(
      GetArtistsWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        startIndex: _artistsNextIndex,
        pageSize: _pageSize,
        append: true,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  void _loadMoreEnsembles() {
    if (_selectedAddress == null || !_ensemblesHasMore || _isLoadingMoreEnsembles) return;
    _isLoadingMoreEnsembles = true;
    context.read<ExploreBloc>().add(
      GetEnsemblesWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        startIndex: _ensemblesNextIndex,
        pageSize: _pageSize,
        append: true,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }
}


