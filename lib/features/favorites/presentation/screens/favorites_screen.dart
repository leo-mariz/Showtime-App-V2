import 'dart:async';

import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/ensemble_card.dart';
import 'package:app/features/explore/presentation/widgets/search_bar_widget.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  Set<String> _favoriteArtistIds = {};
  Set<String> _favoriteEnsembleIds = {};
  /// Cache das listas para não mostrar loading infinito quando o estado atual é da outra aba.
  List<dynamic>? _cachedFavoriteArtists;
  List<EnsembleWithAvailabilitiesEntity>? _cachedFavoriteEnsembles;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
      context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _reloadArtists() {
    context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
  }

  void _reloadEnsembles() {
    context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Favoritos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarWidget(
            controller: _searchController,
            hintText: _tabController.index == 0
                ? 'Buscar artistas favoritos...'
                : 'Buscar conjuntos favoritos...',
            onChanged: _onSearchChanged,
            onClear: _onSearchCleared,
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
          Expanded(
            child: BlocListener<FavoritesBloc, FavoritesState>(
              listener: (context, state) {
                if (state is GetFavoriteArtistsSuccess) {
                  setState(() {
                    _favoriteArtistIds = state.artists
                        .map((a) => a.uid ?? '')
                        .where((id) => id.isNotEmpty)
                        .toSet();
                    _cachedFavoriteArtists = state.artists;
                  });
                } else if (state is GetFavoriteEnsemblesSuccess) {
                  setState(() {
                    _favoriteEnsembleIds = state.ensembles
                        .map((e) => e.ensemble.id ?? '')
                        .where((id) => id.isNotEmpty)
                        .toSet();
                    _cachedFavoriteEnsembles = state.ensembles;
                  });
                } else if (state is RemoveFavoriteSuccess) {
                  context.showSuccess('Removido dos favoritos');
                  _reloadArtists();
                } else if (state is RemoveFavoriteEnsembleSuccess) {
                  context.showSuccess('Conjunto removido dos favoritos');
                  _reloadEnsembles();
                } else if (state is RemoveFavoriteFailure) {
                  context.showError(state.error);
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArtistsList(),
                  _buildEnsemblesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsList() {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is GetFavoriteArtistsLoading &&
            _cachedFavoriteArtists == null) {
          return const Center(child: CustomLoadingIndicator());
        }
        if (state is GetFavoriteArtistsFailure) {
          return _buildErrorCenter(
            'Erro ao carregar favoritos',
            state.error,
            _reloadArtists,
          );
        }
        final list = state is GetFavoriteArtistsSuccess
            ? state.artists
            : _cachedFavoriteArtists;
        if (list != null) {
          final filtered = _searchQuery.isEmpty
              ? list
              : list.where((artist) {
                  final q = _searchQuery.toLowerCase();
                  final name = artist.artistName?.toLowerCase() ?? '';
                  final talents = artist.professionalInfo?.specialty
                          ?.join(' ')
                          .toLowerCase() ??
                      '';
                  final bio = artist.professionalInfo?.bio?.toLowerCase() ?? '';
                  return name.contains(q) ||
                      talents.contains(q) ||
                      bio.contains(q);
                }).toList();
          return _buildArtistsContent(filtered);
        }
        return const Center(child: CustomLoadingIndicator());
      },
    );
  }

  Widget _buildEnsemblesList() {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is GetFavoriteEnsemblesLoading &&
            _cachedFavoriteEnsembles == null) {
          return const Center(child: CustomLoadingIndicator());
        }
        if (state is GetFavoriteEnsemblesFailure) {
          return _buildErrorCenter(
            'Erro ao carregar conjuntos favoritos',
            state.error,
            _reloadEnsembles,
          );
        }
        final list = state is GetFavoriteEnsemblesSuccess
            ? state.ensembles
            : _cachedFavoriteEnsembles;
        if (list != null) {
          final filtered = _searchQuery.isEmpty
              ? list
              : list.where((e) {
                  final q = _searchQuery.toLowerCase();
                  final ownerName =
                      e.ownerArtist?.artistName?.toLowerCase() ?? '';
                  final groupName = e.ensemble.professionalInfo?.bio
                          ?.toLowerCase() ??
                      '';
                  final talents = e.ownerArtist?.professionalInfo?.specialty
                          ?.join(' ')
                          .toLowerCase() ??
                      '';
                  return ownerName.contains(q) ||
                      groupName.contains(q) ||
                      talents.contains(q);
                }).toList();
          return _buildEnsemblesContent(filtered);
        }
        return const Center(child: CustomLoadingIndicator());
      },
    );
  }

  Widget _buildArtistsContent(List<dynamic> favoriteArtists) {
    if (favoriteArtists.isEmpty) {
      return _buildEmptyCenter(
        _searchQuery.isNotEmpty
            ? 'Nenhum resultado encontrado'
            : 'Nenhum favorito ainda',
        _searchQuery.isNotEmpty
            ? 'Não encontramos favoritos que correspondam à sua busca'
            : 'Adicione artistas aos favoritos para vê-los aqui',
      );
    }
    return ListView.builder(
      itemCount: favoriteArtists.length,
      itemBuilder: (context, index) {
        final artist = favoriteArtists[index];
        final artistId = artist.uid ?? '';
        final isFavorite = _favoriteArtistIds.contains(artistId);
        final talents =
            artist.professionalInfo?.specialty?.join(', ') ?? 'Sem talentos';
        final description = artist.professionalInfo?.bio ?? 'Sem descrição';

        return ArtistCard(
          musicianName: artist.artistName ?? 'Artista sem nome',
          talents: talents,
          description: description,
          contracts: artist.rateCount ?? 0,
          rating: artist.rating ?? 0.0,
          pricePerHour: null,
          imageUrl: artist.profilePicture,
          isFavorite: isFavorite,
          artistId: artistId,
          onFavoriteToggle: () => context
              .read<FavoritesBloc>()
              .add(RemoveFavoriteEvent(artistId: artistId)),
          onHirePressed: () => _onRequestArtistTapped(artist),
          onTap: () => _onArtistCardTapped(artist),
        );
      },
    );
  }

  Widget _buildEnsemblesContent(
      List<EnsembleWithAvailabilitiesEntity> favoriteEnsembles) {
    if (favoriteEnsembles.isEmpty) {
      return _buildEmptyCenter(
        _searchQuery.isNotEmpty
            ? 'Nenhum resultado encontrado'
            : 'Nenhum conjunto favorito',
        _searchQuery.isNotEmpty
            ? 'Não encontramos conjuntos que correspondam à sua busca'
            : 'Adicione conjuntos aos favoritos no Explorar para vê-los aqui',
      );
    }
    return ListView.builder(
      itemCount: favoriteEnsembles.length,
      itemBuilder: (context, index) {
        final item = favoriteEnsembles[index];
        final ensemble = item.ensemble;
        final ownerArtist = item.ownerArtist;
        final ensembleId = ensemble.id ?? '';
        final isFavorite = _favoriteEnsembleIds.contains(ensembleId);
        final memberCount = ensemble.members?.length ?? 0;
        final groupName = memberCount > 0
            ? '${ownerArtist?.artistName ?? 'Conjunto'} + ${memberCount - 1}'
            : (ownerArtist?.artistName ?? 'Conjunto');
        var talentsSource = <String>[];
        if (ownerArtist?.professionalInfo?.specialty != null) {
          talentsSource.addAll(ownerArtist!.professionalInfo!.specialty ?? []);
        }
        for (final member in ensemble.members ?? []) {
          if (member.specialty != null) {
            talentsSource.addAll(member.specialty ?? []);
          }
        }
        talentsSource = talentsSource.toSet().toList();
        String? pricePerHour;
        if (item.availabilities.isNotEmpty) {
          final day = item.availabilities.first;
          final slots =
              day.availableSlots.where((s) => s.valorHora != null).toList();
          if (slots.isNotEmpty) {
            final total =
                slots.map((s) => s.valorHora!).reduce((a, b) => a + b);
            pricePerHour =
                'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(total / slots.length)}/hora';
          }
        }
        final description =
            ensemble.professionalInfo?.bio ?? 'Sem descrição disponível';

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
          onFavoriteToggle: () => context.read<FavoritesBloc>().add(
              RemoveFavoriteEnsembleEvent(ensembleId: ensembleId)),
          onHirePressed: () => _onRequestEnsembleTapped(item),
          onTap: () => _onEnsembleCardTapped(item),
        );
      },
    );
  }

  Widget _buildEmptyCenter(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
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

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _searchQuery = query.trim());
    });
  }

  void _onSearchCleared() {
    setState(() => _searchQuery = '');
    _searchController.clear();
  }

  void _onRequestArtistTapped(dynamic artist) {
    AutoRouter.of(context).push(
      RequestRoute(
        selectedDate: DateTime.now(),
        selectedAddress: AddressInfoEntity(
          title: 'Selecione um endereço',
          zipCode: '00000000',
          street: 'Rua',
          number: '000',
          district: 'Bairro',
          city: 'Cidade',
          state: 'SP',
          isPrimary: true,
        ),
        artist: artist,
      ),
    );
  }

  void _onRequestEnsembleTapped(EnsembleWithAvailabilitiesEntity item) {
    final owner = item.ownerArtist;
    if (owner == null) return;
    AutoRouter.of(context).push(
      RequestRoute(
        selectedDate: DateTime.now(),
        selectedAddress: AddressInfoEntity(
          title: 'Selecione um endereço',
          zipCode: '00000000',
          street: 'Rua',
          number: '000',
          district: 'Bairro',
          city: 'Cidade',
          state: 'SP',
          isPrimary: true,
        ),
        artist: owner,
        ensemble: item,
      ),
    );
  }

  void _onArtistCardTapped(dynamic artist) {
    final artistId = artist.uid ?? '';
    final isFavorite = _favoriteArtistIds.contains(artistId);
    AutoRouter.of(context).push(
      ArtistExploreRoute(
        artist: artist,
        isFavorite: isFavorite,
      ),
    );
  }

  void _onEnsembleCardTapped(EnsembleWithAvailabilitiesEntity item) {
    final ensembleId = item.ensemble.id ?? '';
    AutoRouter.of(context).push(
      EnsembleExploreRoute(
        ensembleId: ensembleId,
        artist: item.ownerArtist,
        isFavorite: _favoriteEnsembleIds.contains(ensembleId),
      ),
    );
  }
}
