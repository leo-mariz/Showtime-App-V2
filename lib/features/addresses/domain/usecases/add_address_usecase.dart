import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo endereço
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Validar dados do endereço
/// - Adicionar endereço no repositório
/// - Retornar ID do endereço criado
class AddAddressUseCase {
  final IAddressesRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;

  AddAddressUseCase({
    required this.repository, 
    required this.calculateAddressGeohashUseCase,
  });

  Future<Either<Failure, String>> call(String uid, AddressInfoEntity address) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do usuário não pode ser vazio'));
      }

      // Validar dados do endereço
      if (address.zipCode.isEmpty) {
        return const Left(ValidationFailure('CEP não pode ser vazio'));
      }

      // Buscar geolocalização do endereço
      final geolocationResult = await repository.getGeolocation(address);
      
      // Se falhou na geolocalização, retorna o erro
      if (geolocationResult.isLeft()) {
        return geolocationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected state'),
        );
      }

      // Extrai o GeoPoint do resultado
      final geopoint = geolocationResult.fold(
        (_) => throw Exception('Unexpected state'),
        (geopoint) => geopoint,
      );

      // Cria endereço com geolocalização
      final addressWithGeolocation = address.copyWith(
        latitude: geopoint.latitude,
        longitude: geopoint.longitude,
      );

      // Calcula Geohash do endereço
      final geohashResult = await calculateAddressGeohashUseCase.call(addressWithGeolocation);
      
      final geohash = geohashResult.fold(
        (failure) => null, // Se falhar, continua sem geohash (não bloqueia criação)
        (geohashValue) => geohashValue,
      );
      print('geohash: $geohash');

      // Cria endereço com Geohash
      final addressWithGeohash = addressWithGeolocation.copyWith(geohash: geohash);

      // Adiciona endereço no repositório
      final addAddressResult = await repository.addAddress(uid, addressWithGeohash);

      return addAddressResult.fold(
        (failure) => Left(failure),
        (addressId) => Right(addressId),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

