import 'package:app/core/domain/addresses/address_info_entity.dart';

/// DTO para checagem de overlaps em um único dia
class CheckOverlapOnDayDto {
  /// Endereço novo
  final AddressInfoEntity? endereco;

  /// Raio de atuação novo
  final double? raioAtuacao;

  /// Valor por hora do slot
  final double? valorHora;

  /// ID do slot
  final String? slotId;

  /// Horário de início (formato: "HH:mm")
  final String? startTime;

  /// Horário de fim (formato: "HH:mm")
  final String? endTime;

  /// ID do padrão de recorrência (opcional, para slots de padrão)
  final String? patternId;

  const CheckOverlapOnDayDto({
    this.endereco,
    this.raioAtuacao,
    this.valorHora,
    this.slotId,
    this.startTime,
    this.endTime,
    this.patternId,
  });
}
