import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/features/explore/presentation/widgets/address_selector.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/date_selector.dart';
import 'package:app/features/explore/presentation/widgets/filter_button.dart';
import 'package:app/features/explore/presentation/widgets/search_bar_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // TODO: Substituir por dados reais do Bloc
  String _currentAddress = 'Residencia Sao Paulo';
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _searchController.dispose();
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
                  currentAddress: _currentAddress,
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
            child: _buildArtistsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsList() {
    // TODO: Substituir por ListView.builder com dados reais do Bloc
    // TODO: Implementar paginação/lazy loading
    return ListView.builder(
      itemCount: 5, // Mock
      itemBuilder: (context, index) {
        return ArtistCard(
          musicianName: 'Artista ${index + 1}',
          genres: 'Rock, Pop, Jazz',
          description: 'Músico profissional com experiência em eventos corporativos e festas particulares. Repertório variado e qualidade garantida.',
          contracts: 42 + index,
          rating: 4.5 + (index * 0.1),
          pricePerHour: 'R\$ ${150 + (index * 50)}/hora',
          imageUrl: null, // TODO: URL real da foto
          isFavorite: index == 0, // Mock
          artistId: 'artist_$index', // Mock ID
          onFavoriteToggle: () => _onFavoriteTapped(index),
          onHirePressed: () => _onRequestTapped(index),
          onTap: () => _onArtistCardTapped(index),
        );
      },
    );
  }

  void _onAddressSelected() {
    // TODO: Abrir bottomsheet/modal com lista de endereços
    print('📍 Seletor de endereço clicado');
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
      print('📅 Data selecionada: $picked');
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

  void _onFavoriteTapped(int index) {
    // TODO: Adicionar/remover favorito
    print('❤️ Favorito $index clicado');
  }

  void _onRequestTapped(int index) {
    final router = AutoRouter.of(context);
    router.push(RequestRoute(
      selectedDate: _selectedDate,
      selectedAddress: _currentAddress,
      artist: ArtistEntity(
        uid: 'artist_$index',
        artistName: 'Artista ${index + 1}',
        profilePicture: null, // TODO: URL real da foto
        rating: 4.5 + (index * 0.1),
        finalizedContracts: 42 + index,
      ),
      pricePerHour: 150.0 + (index * 50.0), // TODO: Usar valor real
      minimumDuration: Duration(minutes: 30), // TODO: Usar duração mínima real
    ));
  }

  void _onArtistCardTapped(int index) {
    final router = AutoRouter.of(context);
    
    // Criar ArtistEntity mock a partir dos dados do card
    final artist = ArtistEntity(
      uid: 'artist_$index',
      artistName: 'Artista ${index + 1}',
      profilePicture: null, // TODO: URL real da foto
      rating: 4.5 + (index * 0.1),
      finalizedContracts: 42 + index,
      professionalInfo: ProfessionalInfoEntity(
        bio: 'Músico profissional com experiência em eventos corporativos e festas particulares. Repertório variado e qualidade garantida.',
        genrePreferences: ['Rock', 'Pop', 'Jazz'],
        hourlyRate: 150.0 + (index * 50.0),
        minimumShowDuration: 30,
        specialty: ['Guitarra', 'Vocal'], // Mock
      ),
      presentationMedias: {
        'Guitarra': 'https://example.com/video1.mp4', // Mock
        'Vocal': 'https://example.com/video2.mp4', // Mock
      },
    );

    router.push(ArtistProfileRoute(
      artist: artist,
      isFavorite: index == 0,
    ));
  }
}

