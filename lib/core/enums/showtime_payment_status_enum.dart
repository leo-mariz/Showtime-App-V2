import 'package:dart_mappable/dart_mappable.dart';

part 'showtime_payment_status_enum.mapper.dart';

/// Status do repasse da Showtime ao artista (espelhado do Admin).
@MappableEnum()
enum ShowtimePaymentStatus {
  /// A pagar / atrasado
  @MappableValue('PENDING')
  pending,

  /// Showtime já repassou ao artista
  @MappableValue('PAID')
  paid,

  /// Reembolsado
  @MappableValue('REFUND')
  refund,

  /// Em contestação (ex.: quando analyseRefund == true)
  @MappableValue('IN_DISPUTE')
  inDispute,
}

extension ShowtimePaymentStatusDisplay on ShowtimePaymentStatus {
  /// Label em português para exibição na UI.
  String get displayName {
    switch (this) {
      case ShowtimePaymentStatus.pending:
        return 'A pagar';
      case ShowtimePaymentStatus.paid:
        return 'Pago';
      case ShowtimePaymentStatus.refund:
        return 'Reembolsado';
      case ShowtimePaymentStatus.inDispute:
        return 'Em contestação';
    }
  }
}

/// Converte string (ex. do Firestore) para enum; retorna null se inválido.
ShowtimePaymentStatus? tryParseShowtimePaymentStatus(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return ShowtimePaymentStatusMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
