import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/explore/presentation/widgets/artist_card.dart';
import 'package:app/features/explore/presentation/widgets/search_bar_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
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
            child: _buildFavoritesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    // TODO: Substituir por ListView.builder com dados reais do Bloc
    // TODO: Implementar busca e filtros
    // TODO: Mostrar mensagem quando não houver favoritos
    return ListView.builder(
      itemCount: 3, // Mock - apenas artistas favoritados
      itemBuilder: (context, index) {
        return ArtistCard(
          musicianName: 'Artista Favorito ${index + 1}',
          genres: 'Rock, Pop, Jazz',
          description: 'Músico profissional com experiência em eventos corporativos e festas particulares. Repertório variado e qualidade garantida.',
          contracts: 50 + index,
          rating: 4.7 + (index * 0.1),
          pricePerHour: 'R\$ ${180 + (index * 30)}/hora',
          imageUrl: null, // TODO: URL real da foto
          isFavorite: true, // Todos são favoritos nesta tela
          artistId: 'favorite_artist_$index', // Mock ID
          onFavoriteToggle: () => _onFavoriteTapped(index),
          onHirePressed: () => _onRequestTapped(index),
          onTap: () => _onArtistCardTapped(index),
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

  void _onFavoriteTapped(int index) {
    // TODO: Remover dos favoritos
    print('❤️ Favorito $index removido');
    // TODO: Atualizar lista após remover
  }

  void _onRequestTapped(int index) {
    final router = AutoRouter.of(context);
    router.push(
      RequestRoute(
        selectedDate: DateTime.now(),
        selectedAddress: AddressInfoEntity(
          title: 'Endereço padrão',
          zipCode: '00000000',
          street: 'Rua padrão',
          number: '000',
          district: 'Bairro padrão',
          city: 'Cidade padrão',
          state: 'SP',
          isPrimary: true,
        ),
        artist: ArtistEntity(
          uid: 'favorite_artist_$index',
          artistName: 'Artista Favorito ${index + 1}',
          profilePicture: null, // TODO: URL real da foto
          rating: 4.7 + (index * 0.1),
          rateCount: 50 + index,
        ),
        pricePerHour: 180.0 + (index * 30.0),
        minimumDuration: Duration(minutes: 30),
      ),
    );
  }

  void _onArtistCardTapped(int index) {
    final router = AutoRouter.of(context);
    
    // Criar ArtistEntity mock a partir dos dados do card
    final artist = ArtistEntity(
      uid: 'favorite_artist_$index',
      artistName: 'Artista Favorito ${index + 1}',
      profilePicture: null, // TODO: URL real da foto
      rating: 4.7 + (index * 0.1),
      rateCount: 50 + index,
      professionalInfo: ProfessionalInfoEntity(
        bio: 'Músico profissional com experiência em eventos corporativos e festas particulares. Repertório variado e qualidade garantida.',
        genrePreferences: ['Rock', 'Pop', 'Jazz'],
        hourlyRate: 180.0 + (index * 30.0),
        minimumShowDuration: 30,
        specialty: ['Guitarra', 'Vocal'], // Mock
      ),
      presentationMedias: {
        'Guitarra': 'https://example.com/video1.mp4', // Mock
        'Vocal': 'https://example.com/video2.mp4', // Mock
      },
    );

    router.push(
      ArtistProfileRoute(
        artist: artist,
        isFavorite: true, // Sempre favorito nesta tela
      ),
    );
  }
}

