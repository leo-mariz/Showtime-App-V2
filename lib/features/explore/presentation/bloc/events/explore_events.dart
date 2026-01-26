import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ARTISTS WITH AVAILABILITIES FILTERED EVENT ====================

/// Evento para buscar artistas com disponibilidades filtradas por data e localização
/// 
/// [selectedDate]: Data selecionada para filtrar disponibilidades (obrigatório)
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
/// [searchQuery]: Query de busca para filtrar por nome, talentos ou bio (opcional)
/// [startIndex]: Índice inicial para paginação
/// [pageSize]: Tamanho da página para paginação
/// [append]: Se true, adiciona os resultados à lista existente (útil para paginação infinita)
class GetArtistsWithAvailabilitiesFilteredEvent extends ExploreEvent {
  final DateTime selectedDate;
  final AddressInfoEntity? userAddress;
  final bool forceRefresh;
  final int startIndex;
  final int pageSize;
  final bool append;
  final String? searchQuery;

  GetArtistsWithAvailabilitiesFilteredEvent({
    required this.selectedDate,
    this.userAddress,
    this.forceRefresh = false,
    this.startIndex = 0,
    this.pageSize = 10,
    this.append = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        selectedDate,
        userAddress,
        forceRefresh,
        startIndex,
        pageSize,
        append,
        searchQuery,
      ];
}

// ==================== GET ARTIST ALL AVAILABILITIES EVENT ====================

/// Evento para buscar todas as disponibilidades ativas de um artista
/// 
/// [artistId]: ID do artista (obrigatório)
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
class GetArtistAllAvailabilitiesEvent extends ExploreEvent {
  final String artistId;
  final AddressInfoEntity? userAddress;
  final bool forceRefresh;

  GetArtistAllAvailabilitiesEvent({
    required this.artistId,
    this.userAddress,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [artistId, userAddress, forceRefresh];
}

// ==================== UPDATE ARTIST FAVORITE STATUS EVENT ====================

/// Evento para atualizar o status de favorito de um artista na lista atual
/// 
/// Atualiza apenas o campo isFavorite do artista específico sem recarregar os dados
/// [artistId]: ID do artista a ser atualizado
/// [isFavorite]: Novo status de favorito
class UpdateArtistFavoriteStatusEvent extends ExploreEvent {
  final String artistId;
  final bool isFavorite;

  UpdateArtistFavoriteStatusEvent({
    required this.artistId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [artistId, isFavorite];
}

