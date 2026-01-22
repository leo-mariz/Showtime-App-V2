import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:flutter/material.dart';

/// DTO para abrir um período de disponibilidade
class OpenPeriodDto {
  /// Data de início do período
  final DateTime startDate;

  /// Data de fim do período
  final DateTime endDate;

  /// Horário de início (ex: 14:00)
  final TimeOfDay startTime;

  /// Horário de fim (ex: 22:00)
  final TimeOfDay endTime;

  /// Valor por hora
  final double pricePerHour;

  /// ID do endereço
  final String addressId;

  /// Raio de atuação em km
  final double raioAtuacao;

  /// Informações completas do endereço
  final AddressInfoEntity endereco;

  /// Dias da semana específicos (opcional)
  /// Se null, cria para todos os dias do período
  /// Ex: ['MO', 'TU', 'WE'] para segunda, terça e quarta
  final List<String>? weekdays;

  const OpenPeriodDto({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.addressId,
    required this.raioAtuacao,
    required this.endereco,
    this.weekdays,
  });

  /// Formata horário para string "HH:mm"
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formata horário para string "HH:mm"
  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';
  }
}
