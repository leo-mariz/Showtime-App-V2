import 'package:app/core/domain/addresses/address_info_entity.dart';

/// Classe auxiliar para manter o endereço junto com seu ID do Firestore
class AddressWithId {
  final String id;
  final AddressInfoEntity address;

  AddressWithId({
    required this.id,
    required this.address,
  });
}

