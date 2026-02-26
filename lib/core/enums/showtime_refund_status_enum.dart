import 'package:dart_mappable/dart_mappable.dart';

part 'showtime_refund_status_enum.mapper.dart';

/// Status do reembolso Showtime ao cliente (espelhado do Admin).
@MappableEnum()
enum ShowtimeRefundStatus {
  /// Sem reembolso ao cliente (valor gera repasse ao artista + parte da plataforma).
  @MappableValue('NONE')
  none,

  /// Reembolso parcial ao cliente (ex.: 50%); o restante gera repasse ao artista.
  @MappableValue('PARTIAL')
  partial,

  /// Reembolso total ao cliente; repasse ao artista = 0.
  @MappableValue('FULL')
  full,
}

extension ShowtimeRefundStatusDisplay on ShowtimeRefundStatus {
  /// Label em português para exibição na UI.
  String get displayName {
    switch (this) {
      case ShowtimeRefundStatus.none:
        return 'Sem reembolso';
      case ShowtimeRefundStatus.partial:
        return 'Reembolso parcial';
      case ShowtimeRefundStatus.full:
        return 'Reembolso total';
    }
  }
}

/// Converte string (ex. do Firestore) para enum; retorna null se inválido.
ShowtimeRefundStatus? showtimeRefundStatusFromValue(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return ShowtimeRefundStatusMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
