import 'dart:async';

import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/search_bar_widget.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  
  // Set com IDs dos artistas favoritos (sincronizado com FavoritesBloc)
  Set<String> _favoriteArtistIds = {};
  
  // Query de busca atual
  String _searchQuery = '';
  
  // Timer para debounce da busca
  Timer? _searchDebounceTimer;

  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    // Buscar artistas favoritos ao inicializar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel(); // Cancelar timer ao dispor
    super.dispose();
  }

  void _reloadFavorites() {
    context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário quando usar AutomaticKeepAliveClientMixin
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Favoritos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Buscar artistas favoritos...',
            onChanged: _onSearchChanged,
            onClear: _onSearchCleared,
          ),
          
          DSSizedBoxSpacing.vertical(24),
          
          // Lista de artistas favoritos
          Expanded(
            child: BlocListener<FavoritesBloc, FavoritesState>(
              listener: (context, state) {
                if (state is GetFavoriteArtistsSuccess) {
                  // Atualizar lista de IDs de favoritos
                  setState(() {
                    _favoriteArtistIds = state.artists
                        .map((artist) => artist.uid ?? '')
                        .where((id) => id.isNotEmpty)
                        .toSet();
                  });
                } else if (state is RemoveFavoriteSuccess) {
                  context.showSuccess('Artista removido dos favoritos');
                  // Recarregar lista de favoritos para sincronizar
                  _reloadFavorites();
                } else if (state is RemoveFavoriteFailure) {
                  context.showError(state.error);
                }
              },
              child: _buildFavoritesList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is GetFavoriteArtistsLoading) {
          return const Center(
            child: CustomLoadingIndicator(),
          );
        }

        if (state is GetFavoriteArtistsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    'Erro ao carregar favoritos',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                DSSizedBoxSpacing.vertical(8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
                  child: Text(
                    state.error,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                DSSizedBoxSpacing.vertical(16),
                ElevatedButton(
                  onPressed: _reloadFavorites,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is GetFavoriteArtistsSuccess) {
          final favoriteArtists = state.artists;
          
          // Aplicar filtro de busca nos favoritos
          final filteredFavoriteArtists = _searchQuery.isEmpty
              ? favoriteArtists
              : favoriteArtists.where((artist) {
                  final searchLower = _searchQuery.toLowerCase();
                  final artistName = artist.artistName?.toLowerCase() ?? '';
                  final talents = artist.professionalInfo?.specialty?.join(' ').toLowerCase() ?? '';
                  final bio = artist.professionalInfo?.bio?.toLowerCase() ?? '';
                  
                  return artistName.contains(searchLower) ||
                         talents.contains(searchLower) ||
                         bio.contains(searchLower);
                }).toList();

          if (filteredFavoriteArtists.isEmpty) {
            // Se houver query de busca, mostrar mensagem específica
            if (_searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        'Nenhum resultado encontrado',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
                      child: Text(
                        'Não encontramos favoritos que correspondam à sua busca',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Se não houver query, mostrar mensagem padrão
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      'Nenhum favorito ainda',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
                    child: Text(
                      'Adicione artistas aos favoritos para vê-los aqui',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredFavoriteArtists.length,
            itemBuilder: (context, index) {
              final artist = filteredFavoriteArtists[index];
              final artistId = artist.uid ?? '';
              
              // Verificar se artista está na lista de favoritos
              final isFavorite = _favoriteArtistIds.contains(artistId);

              // Obter gêneros do professionalInfo
              final talents = artist.professionalInfo?.specialty?.join(', ') ?? 'Sem talentos definidos';

              // Obter descrição/bio
              final description = artist.professionalInfo?.bio ?? 'Sem descrição disponível';

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
                onFavoriteToggle: () => _onFavoriteTapped(artistId),
                onHirePressed: () => _onRequestTapped(artist),
                onTap: () => _onArtistCardTapped(artist),
              );
            },
          );
        }

        // Estado inicial - mostrar loading
        return const Center(
          child: CustomLoadingIndicator(),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    // Cancelar timer anterior se existir
    _searchDebounceTimer?.cancel();
    
    // Criar novo timer com debounce de 500ms
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim();
        });
      }
    });
  }

  void _onSearchCleared() {
    setState(() {
      _searchQuery = '';
    });
    _searchController.clear();
  }

  void _onFavoriteTapped(String artistId) {
    // Remover dos favoritos (na tela de favoritos, só podemos remover)
    context.read<FavoritesBloc>().add(RemoveFavoriteEvent(artistId: artistId));
  }

  void _onRequestTapped(dynamic artist) {
    final router = AutoRouter.of(context);

    router.push(
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

  void _onArtistCardTapped(dynamic artist) {
    final router = AutoRouter.of(context);
    final artistId = artist.uid ?? '';
    final isFavorite = _favoriteArtistIds.contains(artistId);
    

    router.push(
      ArtistExploreRoute(
        artist: artist,
        isFavorite: isFavorite,
      ),
    );
  }
}

