import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:equatable/equatable.dart';

abstract class RequestAvailabilitiesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Carrega disponibilidades de um artista para o formulário de solicitação.
class LoadArtistAvailabilitiesEvent extends RequestAvailabilitiesEvent {
  final String artistId;
  final AddressInfoEntity? userAddress;
  final bool forceRefresh;

  LoadArtistAvailabilitiesEvent({
    required this.artistId,
    this.userAddress,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [artistId, userAddress, forceRefresh];
}

/// Carrega disponibilidades de um conjunto para o formulário de solicitação.
class LoadEnsembleAvailabilitiesEvent extends RequestAvailabilitiesEvent {
  final String ensembleId;
  final AddressInfoEntity? userAddress;
  final bool forceRefresh;

  LoadEnsembleAvailabilitiesEvent({
    required this.ensembleId,
    this.userAddress,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [ensembleId, userAddress, forceRefresh];
}
