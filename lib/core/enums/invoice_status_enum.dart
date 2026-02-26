import 'package:dart_mappable/dart_mappable.dart';

part 'invoice_status_enum.mapper.dart';

/// Status da nota fiscal em relação ao repasse (espelhado do Admin).
@MappableEnum()
enum InvoiceStatus {
  /// Pendente
  @MappableValue('PENDING')
  pending,

  /// Emitida
  @MappableValue('EMITTED')
  emitted,

  /// Dispensada
  @MappableValue('DISPENSED')
  dispensed,
}

extension InvoiceStatusDisplay on InvoiceStatus {
  /// Label em português para exibição na UI.
  String get displayName {
    switch (this) {
      case InvoiceStatus.pending:
        return 'Pendente';
      case InvoiceStatus.emitted:
        return 'Emitida';
      case InvoiceStatus.dispensed:
        return 'Dispensada';
    }
  }
}

/// Converte string (ex. do Firestore) para enum; retorna null se inválido.
InvoiceStatus? tryParseInvoiceStatus(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return InvoiceStatusMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
