import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET ARTISTS WITH AVAILABILITIES EVENTS ====================

/// Evento para buscar todos os artistas com suas disponibilidades
/// 
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
class GetArtistsWithAvailabilitiesEvent extends ExploreEvent {
  final bool forceRefresh;

  GetArtistsWithAvailabilitiesEvent({
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [forceRefresh];
}

/// Evento para buscar artistas com disponibilidades filtradas por data e localização
/// 
/// [selectedDate]: Data selecionada para filtrar disponibilidades (opcional)
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
class GetArtistsWithAvailabilitiesFilteredEvent extends ExploreEvent {
  final DateTime? selectedDate;
  final AddressInfoEntity? userAddress;
  final bool forceRefresh;
  final int startIndex;
  final int pageSize;
  final bool append;

  GetArtistsWithAvailabilitiesFilteredEvent({
    this.selectedDate,
    this.userAddress,
    this.forceRefresh = false,
    this.startIndex = 0,
    this.pageSize = 10,
    this.append = false,
  });

  @override
  List<Object?> get props => [
        selectedDate,
        userAddress,
        forceRefresh,
        startIndex,
        pageSize,
        append,
      ];
}

