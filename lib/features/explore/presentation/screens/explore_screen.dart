import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
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
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // TODO: Substituir por dados reais do Bloc
  AddressInfoEntity? _selectedAddress;
  DateTime _selectedDate = DateTime.now();
  int _nextIndex = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  static const int _pageSize = 10;

  String get _currentAddressDisplay {
    if (_selectedAddress == null) {
      return 'Selecione um endereço';
    }
    return _selectedAddress!.title;
  }
  
  @override
  void initState() {
    super.initState();
    print('🔵 [EXPLORE_SCREEN] initState - Iniciando tela');
    
    // Buscar endereços se ainda não foram buscados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressesState = context.read<AddressesBloc>().state;
      print('🔵 [EXPLORE_SCREEN] initState - Estado atual do AddressesBloc: ${addressesState.runtimeType}');
      
      if (addressesState is! GetAddressesSuccess) {
        print('🔵 [EXPLORE_SCREEN] initState - Disparando GetAddressesEvent');
        context.read<AddressesBloc>().add(GetAddressesEvent());
      } else {
        print('🔵 [EXPLORE_SCREEN] initState - Endereços já carregados, obtendo primário');
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
    print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Total de endereços: ${state.addresses.length}');
    
    if (state.addresses.isEmpty) {
      print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Nenhum endereço disponível');
      // Sem endereço, buscar sem filtro geográfico
      _onGetArtistsWithAvailabilitiesFiltered();
      return;
    }

    AddressInfoEntity primaryAddress;
    try {
      primaryAddress = state.addresses.firstWhere(
        (address) => address.isPrimary,
      );
      print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Endereço primário encontrado: ${primaryAddress.title}');
    } catch (e) {
      // Se não encontrar primário, usar o primeiro endereço
      primaryAddress = state.addresses.first;
      print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Usando primeiro endereço (sem primário): ${primaryAddress.title}');
    }

    if (_selectedAddress == null) {
      setState(() {
        _selectedAddress = primaryAddress;
      });
      print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Endereço definido: ${primaryAddress.title}');
      print('🔵 [EXPLORE_SCREEN] _getPrimaryAddressFromState - Coordenadas: lat=${primaryAddress.latitude}, lon=${primaryAddress.longitude}');
      // Buscar artistas filtrados com endereço primário e data atual
      _onGetArtistsWithAvailabilitiesFiltered();
    }
  }

  /// Busca artistas com filtros aplicados (data e endereço)
  /// 
  /// Usa o endereço selecionado (_selectedAddress) e a data selecionada (_selectedDate)
  /// Se não houver endereço selecionado, busca sem filtro geográfico
  void _onGetArtistsWithAvailabilitiesFiltered() {
    if (!mounted) {
      print('🔴 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Widget não está montado, abortando');
      return;
    }

    final forceRefresh = false; // Mudado para false para usar cache
    final currentState = context.read<ExploreBloc>().state;
    
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Iniciando busca');
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Data selecionada: $_selectedDate');
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Endereço selecionado: ${_selectedAddress?.title ?? "Nenhum"}');
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Estado atual: ${currentState.runtimeType}');
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - forceRefresh: $forceRefresh');
    
    // Sempre disparar o evento (removida a verificação de estado de sucesso)
    context.read<ExploreBloc>().add(
      GetArtistsWithAvailabilitiesFilteredEvent(
        selectedDate: _selectedDate,
        userAddress: _selectedAddress,
        forceRefresh: forceRefresh,
        startIndex: 0,
        pageSize: _pageSize,
        append: false,
      ),
    );
    print('🔵 [EXPLORE_SCREEN] _onGetArtistsWithAvailabilitiesFiltered - Evento disparado');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      print('🔵 [EXPLORE_SCREEN] BlocListener AddressesBloc - Endereços carregados');
                      _getPrimaryAddressFromState(state);
                    }
                  },
                ),
                // Escutar ExploreBloc para atualizar paginação
                BlocListener<ExploreBloc, ExploreState>(
                  listener: (context, state) {
                    if (state is GetArtistsWithAvailabilitiesSuccess) {
                      _nextIndex = state.nextIndex;
                      _hasMore = state.hasMore;
                      if (state.append) {
                        _isLoadingMore = false;
                      } else {
                        // Reset de scroll em nova busca
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  print('🔵 [EXPLORE_SCREEN] BlocBuilder ExploreBloc - Estado: ${state.runtimeType}');
                  
                  if (state is GetArtistsWithAvailabilitiesLoading) {
                    print('🔵 [EXPLORE_SCREEN] BlocBuilder - Mostrando loading');
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                if (state is GetArtistsWithAvailabilitiesFailure) {
                  print('🔴 [EXPLORE_SCREEN] BlocBuilder - Erro: ${state.error}');
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
                          'Erro ao carregar artistas',
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
                            _onGetArtistsWithAvailabilitiesFiltered();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is GetArtistsWithAvailabilitiesSuccess) {
                  print('🟢 [EXPLORE_SCREEN] BlocBuilder - Sucesso! Total de artistas: ${state.artistsWithAvailabilities.length}');
                  
                  if (state.artistsWithAvailabilities.isEmpty) {
                    print('🟡 [EXPLORE_SCREEN] BlocBuilder - Nenhum artista encontrado');
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
                          Text(
                            'Nenhum artista encontrado',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DSSizedBoxSpacing.vertical(8),
                          Text(
                            'Não há artistas disponíveis no momento',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  print('🟢 [EXPLORE_SCREEN] BlocBuilder - Exibindo lista com ${state.artistsWithAvailabilities.length} artistas');
                  return _buildArtistsList(state.artistsWithAvailabilities);
                }

                // Estado inicial - mostrar loading
                print('🟡 [EXPLORE_SCREEN] BlocBuilder - Estado inicial, mostrando loading');
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
          contracts: artist.finalizedContracts,
          rating: artist.rating,
          pricePerHour: pricePerHour,
          imageUrl: artist.profilePicture,
          isFavorite: false, // TODO: Implementar verificação de favoritos
          artistId: artist.uid ?? '',
          onFavoriteToggle: () => _onFavoriteTapped(artist.uid ?? ''),
          onHirePressed: () => _onRequestTapped(artistWithAvailabilities),
          onTap: () => _onArtistCardTapped(artistWithAvailabilities),
        );
      },
    );
  }

  void _onAddressSelected() async {
    print('🔵 [EXPLORE_SCREEN] _onAddressSelected - Abrindo modal de endereços');
    final selectedAddress = await AddressesModal.show(
      context: context,
      selectedAddress: _selectedAddress,
    );

    if (selectedAddress != null && selectedAddress != _selectedAddress) {
      print('🔵 [EXPLORE_SCREEN] _onAddressSelected - Novo endereço selecionado: ${selectedAddress.title}');
      print('🔵 [EXPLORE_SCREEN] _onAddressSelected - Coordenadas: lat=${selectedAddress.latitude}, lon=${selectedAddress.longitude}');
      setState(() {
        _selectedAddress = selectedAddress;
      });
      // Buscar artistas filtrados com novo endereço
      _onGetArtistsWithAvailabilitiesFiltered();
    } else {
      print('🔵 [EXPLORE_SCREEN] _onAddressSelected - Nenhum endereço selecionado ou mesmo endereço');
    }
  }

  void _onDateSelected() async {
    print('🔵 [EXPLORE_SCREEN] _onDateSelected - Abrindo seletor de data');
    final DateTime? picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      print('🔵 [EXPLORE_SCREEN] _onDateSelected - Nova data selecionada: $picked');
      setState(() {
        _selectedDate = picked;
      });
      // Buscar artistas filtrados com nova data
      _onGetArtistsWithAvailabilitiesFiltered();
    } else {
      print('🔵 [EXPLORE_SCREEN] _onDateSelected - Nenhuma data selecionada ou mesma data');
    }
  }

  void _onSearchChanged(String query) {
    // TODO: Implementar debounce e busca
    print('🔍 Busca alterada: $query');
  }

  void _onSearchCleared() {
    // TODO: Limpar filtros de busca
    print('🔍 Busca limpa');
  }

  void _onFilterTapped() {
    // TODO: Abrir bottomsheet/modal com filtros
    print('🎛️ Filtros clicados');
  }

  void _onFavoriteTapped(String artistId) {
    // TODO: Implementar adicionar/remover favorito
    print('❤️ Favorito $artistId clicado');
  }

  void _onRequestTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;
    
    // Obter preço da primeira disponibilidade ou do professionalInfo
    double pricePerHour = 0.0;
    if (artistWithAvailabilities.availabilities.isNotEmpty) {
      pricePerHour = artistWithAvailabilities.availabilities.first.valorShow;
    } else if (artist.professionalInfo?.hourlyRate != null) {
      pricePerHour = artist.professionalInfo!.hourlyRate!;
    }

    // Obter duração mínima do professionalInfo
    final minimumDuration = artist.professionalInfo?.minimumShowDuration != null
        ? Duration(minutes: artist.professionalInfo!.minimumShowDuration!)
        : const Duration(minutes: 30);

    router.push(RequestRoute(
      selectedDate: _selectedDate,
      selectedAddress: _currentAddressDisplay,
      artist: artist,
      pricePerHour: pricePerHour,
      minimumDuration: minimumDuration,
    ));
  }

  void _onArtistCardTapped(ArtistWithAvailabilitiesEntity artistWithAvailabilities) {
    final router = AutoRouter.of(context);
    final artist = artistWithAvailabilities.artist;

    router.push(ArtistProfileRoute(
      artist: artist,
      isFavorite: false, // TODO: Implementar verificação de favoritos
    ));
  }

  void _loadMore() {
    if (!_hasMore || _isLoadingMore) return;
    print('🔵 [EXPLORE_SCREEN] _loadMore - Carregando mais. nextIndex=$_nextIndex');
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
}

