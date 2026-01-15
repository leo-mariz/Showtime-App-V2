import 'dart:async';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/presentation/bloc/events/explore_events.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:app/features/explore/presentation/widgets/address_selector.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/date_selector.dart';
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

class _ExploreScreenState extends State<ExploreScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  AddressInfoEntity? _selectedAddress;
  DateTime _selectedDate = DateTime.now();
  int _nextIndex = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  static const int _pageSize = 10;
  
  // Tamanho anterior da lista para detectar se é nova busca ou apenas atualização
  int _previousListSize = 0;
  
  // Mapa para rastrear mudanças locais de favoritos (artistId -> isFavorite)
  // Isso permite atualização visual imediata antes do ExploreBloc recarregar
  final Map<String, bool> _localFavoriteUpdates = {};
  
  // Rastrear último artista que teve favorito alterado
  String? _lastFavoriteArtistId;
  
  // Query de busca atual
  String _searchQuery = '';
  
  // Timer para debounce da busca
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
    
    // Buscar endereços se ainda não foram buscados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressesState = context.read<AddressesBloc>().state;      
      if (addressesState is! GetAddressesSuccess) {
        context.read<AddressesBloc>().add(GetAddressesEvent());
      } else {
        _getPrimaryAddressFromState(addressesState);
      }
    });

    // Scroll listener para carregar mais ao chegar no fim
    _scrollController.addListener(() {
      if (_hasMore &&
          !_isLoadingMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  /// Obtém endereço primário do estado do AddressesBloc
  void _getPrimaryAddressFromState(GetAddressesSuccess state) {
    
    if (state.addresses.isEmpty) {
      // Sem endereço, buscar sem filtro geográfico
      _onGetArtistsWithAvailabilitiesFiltered();
      return;
    }

    AddressInfoEntity primaryAddress;
    try {
      primaryAddress = state.addresses.firstWhere(
        (address) => address.isPrimary,
      );
    } catch (e) {
      // Se não encontrar primário, usar o primeiro endereço
      primaryAddress = state.addresses.first;
    }

    if (_selectedAddress == null) {
      setState(() {
        _selectedAddress = primaryAddress;
      });
      // Buscar artistas filtrados com endereço primário e data atual
      _onGetArtistsWithAvailabilitiesFiltered();
    }
  }

  /// Busca artistas com filtros aplicados (data, endereço e busca)
  /// 
  /// Usa o endereço selecionado (_selectedAddress), a data selecionada (_selectedDate)
  /// e a query de busca (_searchQuery)
  /// Se não houver endereço selecionado, busca sem filtro geográfico
  void _onGetArtistsWithAvailabilitiesFiltered() {
    if (!mounted) {
      return;
    }

    final forceRefresh = false; // Mudado para false para usar cache
    
    // Sempre disparar o evento (removida a verificação de estado de sucesso)
    context.read<ExploreBloc>().add(
      GetArtistsWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        forceRefresh: forceRefresh,
        startIndex: 0,
        pageSize: _pageSize,
        append: false,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  void _onUpdateArtistFavoriteStatus(String artistId, bool isFavorite) {
    context.read<ExploreBloc>().add(
      UpdateArtistFavoriteStatusEvent(
        artistId: artistId,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel(); // Cancelar timer ao dispor
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário quando usar AutomaticKeepAliveClientMixin
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Explorar',
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
          
          // Search Bar + Filtro
          Row(
            children: [          
              Expanded(
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Buscar artistas...',
                  onChanged: _onSearchChanged,
                  onClear: _onSearchCleared,
                ),
              ),
              DSSizedBoxSpacing.horizontal(12),
              FilterButton(
                onPressed: _onFilterTapped,
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(24),
          
          // Lista de artistas
          Expanded(
            child: MultiBlocListener(
              listeners: [
                // Escutar mudanças no AddressesBloc para obter endereço primário
                BlocListener<AddressesBloc, AddressesState>(
                  listener: (context, state) {
                    if (state is GetAddressesSuccess && _selectedAddress == null) {
                      _getPrimaryAddressFromState(state);
                    }
                  },
                ),
                // Escutar ExploreBloc para atualizar paginação
                BlocListener<ExploreBloc, ExploreState>(
                  listener: (context, state) {
                    if (state is GetArtistsWithAvailabilitiesSuccess) {
                      final currentListSize = state.artistsWithAvailabilities.length;
                      _nextIndex = state.nextIndex;
                      _hasMore = state.hasMore;
                      if (state.append) {
                        _isLoadingMore = false;
                      } else {
                        // Reset de scroll apenas se for uma nova busca (tamanho mudou)
                        // Se o tamanho for o mesmo, é apenas atualização de favorito, não faz scroll
                        if (currentListSize != _previousListSize && _scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                      _previousListSize = currentListSize;
                    }
                  },
                ),
                // Escutar FavoritesBloc para feedback de adicionar/remover favoritos
                BlocListener<FavoritesBloc, FavoritesState>(
                  listener: (context, state) {
                    if (state is AddFavoriteSuccess) {
                      context.showSuccess('Artista adicionado aos favoritos');
                      // Atualizar estado local para refletir mudança visual imediatamente
                      if (_lastFavoriteArtistId != null) {
                        setState(() {
                          _localFavoriteUpdates[_lastFavoriteArtistId!] = true;
                        });
                        _onUpdateArtistFavoriteStatus(_lastFavoriteArtistId!, true);
                      }
                    } else if (state is AddFavoriteFailure) {
                      context.showError(state.error);
                      // Reverter mudança local em caso de erro
                      if (_lastFavoriteArtistId != null) {
                        setState(() {
                          _localFavoriteUpdates.remove(_lastFavoriteArtistId);
                        });
                      }
                    } else if (state is RemoveFavoriteSuccess) {
                      context.showSuccess('Artista removido dos favoritos');
                      // Atualizar estado local para refletir mudança visual imediatamente
                      if (_lastFavoriteArtistId != null) {
                        setState(() {
                          _localFavoriteUpdates[_lastFavoriteArtistId!] = false;
                        });
                        _onUpdateArtistFavoriteStatus(_lastFavoriteArtistId!, false);
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
              child: BlocBuilder<ExploreBloc, ExploreState>(
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
                            'Erro ao carregar artistas',
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
                          onPressed: () {
                            _onGetArtistsWithAvailabilitiesFiltered();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is GetArtistsWithAvailabilitiesSuccess) {
                  // A busca agora é feita no UseCase, então usamos diretamente a lista do estado
                  final artists = state.artistsWithAvailabilities;
                  
                  if (artists.isEmpty) {
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
                                'Não encontramos artistas que correspondam à sua busca',
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
                            Icons.search_off,
                            size: DSSize.width(48),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          DSSizedBoxSpacing.vertical(16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
                            child: Text(
                              'Nenhum artista encontrado',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DSSizedBoxSpacing.vertical(8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DSPadding.horizontal(32)),
                            child: Text(
                              'Não há artistas disponíveis para a data e endereço selecionados no momento.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildArtistsList(artists);
                }

                // Estado inicial - mostrar loading
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsList(
    List<ArtistWithAvailabilitiesEntity> artistsWithAvailabilities,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _hasMore
          ? artistsWithAvailabilities.length + 1
          : artistsWithAvailabilities.length,
      itemBuilder: (context, index) {
        // Footer loader
        if (index >= artistsWithAvailabilities.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final artistWithAvailabilities = artistsWithAvailabilities[index];
        final artist = artistWithAvailabilities.artist;
        final availabilities = artistWithAvailabilities.availabilities;
        
        // Verificar se há atualização local de favorito para este artista
        final artistId = artist.uid ?? '';
        final isFavorite = _localFavoriteUpdates.containsKey(artistId)
            ? _localFavoriteUpdates[artistId]!
            : artistWithAvailabilities.isFavorite;

        // Obter preço da primeira disponibilidade (ou usar hourlyRate do professionalInfo)
        String? pricePerHour;
        if (availabilities.isNotEmpty) {
          final firstAvailability = availabilities.first;
          pricePerHour = 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(firstAvailability.valorShow)}/hora';
        } else if (artist.professionalInfo?.hourlyRate != null) {
          pricePerHour = 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(artist.professionalInfo!.hourlyRate!)}/hora';
        }

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

  void _onAddressSelected() async {
    final selectedAddress = await AddressesModal.show(
      context: context,
      selectedAddress: _selectedAddress,
    );

    if (selectedAddress != null && selectedAddress != _selectedAddress) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
      // Buscar artistas filtrados com novo endereço
      _onGetArtistsWithAvailabilitiesFiltered();
    } else {
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
      setState(() {
        _selectedDate = picked;
      });
      // Buscar artistas filtrados com nova data
      _onGetArtistsWithAvailabilitiesFiltered();
    } else {
    }
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
        // Buscar artistas com a nova query de busca
        _onGetArtistsWithAvailabilitiesFiltered();
      }
    });
  }

  void _onSearchCleared() {
    setState(() {
      _searchQuery = '';
    });
    _searchController.clear();
    // Buscar artistas sem a query de busca
    _onGetArtistsWithAvailabilitiesFiltered();
  }

  void _onFilterTapped() {
    // TODO: Abrir bottomsheet/modal com filtros
  }

  void _onFavoriteTapped(String artistId, bool isFavorite) {
    // Armazenar o artistId para atualizar o estado após sucesso
    _lastFavoriteArtistId = artistId;
    
    // Atualizar estado local imediatamente para feedback visual instantâneo
    setState(() {
      _localFavoriteUpdates[artistId] = !isFavorite;
    });
    
    if (isFavorite) {
      context.read<FavoritesBloc>().add(RemoveFavoriteEvent(artistId: artistId));
    } else {
      context.read<FavoritesBloc>().add(AddFavoriteEvent(artistId: artistId));
    }
  }

  void _onRequestTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    
    // Encontrar a disponibilidade correspondente ao endereço e data selecionados
    // Como as disponibilidades já foram filtradas, todas são válidas
    // Vamos usar a primeira que corresponde ao endereço selecionado (geohash ou lat/lon)
    
    final matchedAvailability = _findAvailability(artistWithAvailabilities);

    // Obter preço da disponibilidade correspondente ou do professionalInfo
    double pricePerHour = 0.0;
    if (matchedAvailability != null) {
      pricePerHour = matchedAvailability.valorShow;
    } else if (artist.professionalInfo?.hourlyRate != null) {
      pricePerHour = artist.professionalInfo!.hourlyRate!;
    }

    // Obter duração mínima do professionalInfo
    final minimumDuration = artist.professionalInfo?.minimumShowDuration != null
        ? Duration(minutes: artist.professionalInfo!.minimumShowDuration!)
        : const Duration(minutes: 30);

    if (_selectedAddress == null) {
      context.showError('Selecione um endereço antes de solicitar');
      return;
    }

    router.push(RequestRoute(
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress!,
      artist: artist,
      pricePerHour: pricePerHour,
      minimumDuration: minimumDuration,
      availability: matchedAvailability, // Passar disponibilidade correspondente
    ));
  }

  void _onArtistCardTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    final isFavorite = _localFavoriteUpdates.containsKey(artist.uid ?? '')
        ? _localFavoriteUpdates[artist.uid ?? '']!
        : artistWithAvailabilities.isFavorite;

    // Encontrar a disponibilidade correspondente ao endereço e data selecionados
    final matchedAvailability = _findAvailability(artistWithAvailabilities);

    router.push(ArtistProfileRoute(
      artist: artist,
      isFavorite: isFavorite, 
      selectedDate: _selectedDate,
      selectedAddress: _selectedAddress,
      availability: matchedAvailability,
    ));
  }

  void _loadMore() {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    context.read<ExploreBloc>().add(
      GetArtistsWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        startIndex: _nextIndex,
        pageSize: _pageSize,
        append: true,
      ),
    );
  }

  AvailabilityEntity? _findAvailability(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
   AvailabilityEntity? matchedAvailability;
    if (_selectedAddress != null && artistWithAvailabilities.availabilities.isNotEmpty) {
      // Tentar encontrar disponibilidade com mesmo geohash ou lat/lon
      matchedAvailability = artistWithAvailabilities.availabilities.firstWhere(
        (availability) {
          if (_selectedAddress!.geohash != null && availability.endereco.geohash != null) {
            return _selectedAddress!.geohash == availability.endereco.geohash;
          }
          // Fallback: comparar por latitude/longitude (com tolerância)
          if (_selectedAddress!.latitude != null && 
              _selectedAddress!.longitude != null &&
              availability.endereco.latitude != null &&
              availability.endereco.longitude != null) {
            const tolerance = 0.0001; // ~11 metros
            return (_selectedAddress!.latitude! - availability.endereco.latitude!).abs() < tolerance &&
                   (_selectedAddress!.longitude! - availability.endereco.longitude!).abs() < tolerance;
          }
          return false;
        },
        orElse: () => artistWithAvailabilities.availabilities.first, // Usar primeira se não encontrar
      );
    } else if (artistWithAvailabilities.availabilities.isNotEmpty) {
      matchedAvailability = artistWithAvailabilities.availabilities.first;
    }
    return matchedAvailability;
  }
}


