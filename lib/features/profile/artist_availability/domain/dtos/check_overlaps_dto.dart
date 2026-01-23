import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';

/// DTO para checagem de overlaps
class CheckOverlapsDto {
  /// Metadata do padrão de recorrência
  final PatternMetadata? patternMetadata;

  /// Endereço novo
  final AddressInfoEntity? endereco;

  /// Raio de atuação novo
  final double? raioAtuacao;

  /// Valor por hora do slot
  final double? valorHora;

  /// Horário de início (formato: "HH:mm")
  final String? startTime;

  /// Horário de fim (formato: "HH:mm")
  final String? endTime;

  const CheckOverlapsDto({
    this.patternMetadata,
    this.endereco,
    this.raioAtuacao,
    this.valorHora,
    this.startTime,
    this.endTime,
  });
}
