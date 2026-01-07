import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/geohash_helper.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Calcular Geohash de um endereço
/// 
/// RESPONSABILIDADES:
/// - Validar que o endereço possui latitude e longitude
/// - Calcular Geohash com precisão de 5 caracteres (~4.9km)
/// - Retornar endereço atualizado (com geohash calculado)
/// 
/// OBSERVAÇÕES:
/// - Geohash é calculado a partir das coordenadas (latitude, longitude)
/// - Precisão de 5 caracteres = ~4.9km de precisão (ideal para armazenar)
/// - Para buscar com raio de 40km, use precisão 4 no getRange
/// - Se endereço não tiver coordenadas, retorna erro
/// - O geohash será armazenado na AvailabilityEntity, não no AddressInfoEntity
class CalculateAddressGeohashUseCase {
  CalculateAddressGeohashUseCase();

  /// Calcula Geohash do endereço e retorna o valor do Geohash
  /// 
  /// [address]: Endereço com latitude e longitude preenchidos
  /// Retorna [String] com o Geohash calculado (7 caracteres)
  Future<Either<Failure, String>> call(
    AddressInfoEntity address,
  ) async {
    try {
      // Validar que endereço possui coordenadas
      if (address.latitude == null || address.longitude == null) {
        return const Left(
          ValidationFailure(
            'Endereço deve possuir latitude e longitude para calcular Geohash',
          ),
        );
      }

      // Calcular Geohash com precisão de 5 caracteres (~4.9km) para armazenar no banco
      final geohashValue = GeohashHelper.encode(
        address.latitude!,
        address.longitude!,
        precision: 5,
      );

      return Right(geohashValue);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Calcula apenas o Geohash string a partir de um endereço (método síncrono)
  /// 
  /// Útil quando precisamos apenas do valor do Geohash sem usar Either
  /// Retorna null se endereço não tiver coordenadas
  String? calculateGeohash(AddressInfoEntity address) {
    if (address.latitude == null || address.longitude == null) {
      return null;
    }

    return GeohashHelper.encode(
      address.latitude!,
      address.longitude!,
      precision: 5,
    );
  }
}

