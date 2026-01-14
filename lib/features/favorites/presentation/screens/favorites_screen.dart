import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
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

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mapa para rastrear mudanças locais de favoritos (artistId -> isFavorite)
  // Isso permite atualização visual imediata antes do ExploreBloc recarregar
  final Map<String, bool> _localFavoriteUpdates = {};
  
  // Rastrear último artista que teve favorito alterado
  String? _lastFavoriteArtistId;
  
  @override
  void initState() {
    super.initState();
    // Buscar artistas ao inicializar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreBloc>().add(
        GetArtistsWithAvailabilitiesEvent(forceRefresh: false),
      );
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: MultiBlocListener(
              listeners: [
                // Escutar FavoritesBloc para feedback de remover favoritos
                BlocListener<FavoritesBloc, FavoritesState>(
                  listener: (context, state) {
                    if (state is RemoveFavoriteSuccess) {
                      context.showSuccess('Artista removido dos favoritos');
                      // Atualizar estado local para refletir mudança visual imediatamente
                      if (_lastFavoriteArtistId != null) {
                        setState(() {
                          _localFavoriteUpdates[_lastFavoriteArtistId!] = false;
                        });
                      }
                    } else if (state is RemoveFavoriteFailure) {
                      context.showError(state.error);
                      // Reverter mudança local em caso de erro
                      if (_lastFavoriteArtistId != null) {
                        setState(() {
                          _localFavoriteUpdates.remove(_lastFavoriteArtistId);
                        });
                      }
                    }
                  },
                ),
              ],
              child: _buildFavoritesList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        if (state is GetArtistsWithAvailabilitiesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is GetArtistsWithAvailabilitiesFailure) {
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
                Text(
                  'Erro ao carregar favoritos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DSSizedBoxSpacing.vertical(8),
                Text(
                  state.error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                DSSizedBoxSpacing.vertical(16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ExploreBloc>().add(
                      GetArtistsWithAvailabilitiesEvent(forceRefresh: false),
                    );
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is GetArtistsWithAvailabilitiesSuccess) {
          // Filtrar apenas artistas favoritos
          final favoriteArtists = state.artistsWithAvailabilities
              .where((artist) {
                final artistId = artist.artist.uid ?? '';
                // Verificar se há atualização local de favorito para este artista
                if (_localFavoriteUpdates.containsKey(artistId)) {
                  return _localFavoriteUpdates[artistId] == true;
                }
                return artist.isFavorite;
              })
              .toList();

          if (favoriteArtists.isEmpty) {
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
                  Text(
                    'Nenhum favorito ainda',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Text(
                    'Adicione artistas aos favoritos para vê-los aqui',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteArtists.length,
            itemBuilder: (context, index) {
              final artistWithAvailabilities = favoriteArtists[index];
              final artist = artistWithAvailabilities.artist;
              // final availabilities = artistWithAvailabilities.availabilities;
              
              // Verificar se há atualização local de favorito para este artista
              final artistId = artist.uid ?? '';
              final isFavorite = _localFavoriteUpdates.containsKey(artistId)
                  ? _localFavoriteUpdates[artistId]!
                  : artistWithAvailabilities.isFavorite;

              // Obter preço da primeira disponibilidade (ou usar hourlyRate do professionalInfo)
              // String? pricePerHour;
              // if (availabilities.isNotEmpty) {
              //   final firstAvailability = availabilities.first;
              //   pricePerHour = 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(firstAvailability.valorShow)}/hora';
              // } else if (artist.professionalInfo?.hourlyRate != null) {
              //   pricePerHour = 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(artist.professionalInfo!.hourlyRate!)}/hora';
              // }

              // Obter gêneros do professionalInfo
              final genres = artist.professionalInfo?.genrePreferences?.join(', ') ?? 'Sem gêneros definidos';

              // Obter descrição/bio
              final description = artist.professionalInfo?.bio ?? 'Sem descrição disponível';

              return ArtistCard(
                musicianName: artist.artistName ?? 'Artista sem nome',
                genres: genres,
                description: description,
                contracts: artist.rateCount ?? 0,
                rating: artist.rating ?? 0.0,
                pricePerHour: null,
                imageUrl: artist.profilePicture,
                isFavorite: isFavorite,
                artistId: artistId,
                onFavoriteToggle: () => _onFavoriteTapped(artistId, isFavorite),
                onHirePressed: () => _onRequestTapped(artistWithAvailabilities),
                onTap: () => _onArtistCardTapped(artistWithAvailabilities),
              );
            },
          );
        }

        // Estado inicial - mostrar loading
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    // TODO: Implementar debounce e busca nos favoritos
    print('🔍 Busca alterada: $query');
  }

  void _onSearchCleared() {
    // TODO: Limpar filtros de busca
    print('🔍 Busca limpa');
  }

  void _onFavoriteTapped(String artistId, bool isFavorite) {
    print('❤️ Favorito $artistId clicado');
    // Armazenar o artistId para atualizar o estado após sucesso
    _lastFavoriteArtistId = artistId;
    
    // Atualizar estado local imediatamente para feedback visual instantâneo
    setState(() {
      _localFavoriteUpdates[artistId] = false; // Sempre remove nesta tela
    });
    
    // Remover dos favoritos
    context.read<FavoritesBloc>().add(RemoveFavoriteEvent(artistId: artistId));
  }

  void _onRequestTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    final availabilities = artistWithAvailabilities.availabilities;
    
    // Obter preço da primeira disponibilidade ou do professionalInfo
    double pricePerHour = 0.0;
    if (availabilities.isNotEmpty) {
      pricePerHour = availabilities.first.valorShow;
    } else if (artist.professionalInfo?.hourlyRate != null) {
      pricePerHour = artist.professionalInfo!.hourlyRate!;
    }

    // Obter duração mínima do professionalInfo
    final minimumDuration = artist.professionalInfo?.minimumShowDuration != null
        ? Duration(minutes: artist.professionalInfo!.minimumShowDuration!)
        : const Duration(minutes: 30);

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
        pricePerHour: pricePerHour,
        minimumDuration: minimumDuration,
      ),
    );
  }

  void _onArtistCardTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    
    // Verificar se há atualização local de favorito para este artista
    final artistId = artist.uid ?? '';
    final isFavorite = _localFavoriteUpdates.containsKey(artistId)
        ? _localFavoriteUpdates[artistId]!
        : artistWithAvailabilities.isFavorite;

    router.push(
      ArtistProfileRoute(
        artist: artist,
        isFavorite: isFavorite,
      ),
    );
  }
}

