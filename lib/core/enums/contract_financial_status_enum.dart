import 'package:dart_mappable/dart_mappable.dart';

part 'contract_financial_status_enum.mapper.dart';

/// Status financeiro do contrato: repasse ao artista, reembolso, contestação (espelhado do Admin).
@MappableEnum()
enum ContractFinancialStatus {
  /// Ainda não aplicável (ex.: contrato não pago).
  @MappableValue('NONE')
  none,

  /// Cliente pagou; repasse ao artista ainda não feito.
  @MappableValue('TRANSFER_PENDING')
  transferPending,

  /// Reembolso em análise (decisão pendente).
  @MappableValue('REFUND_IN_ANALYSIS')
  refundInAnalysis,

  /// Em contestação.
  @MappableValue('CONTESTED')
  contested,

  /// Reembolso parcial ao cliente → repasse parcial ao artista.
  @MappableValue('PARTIALLY_TRANSFERRED')
  partiallyTransferred,

  /// Reembolso total ao cliente → 0 ao artista.
  @MappableValue('FULLY_REFUNDED')
  fullyRefunded,

  /// 100% repassado ao artista.
  @MappableValue('TRANSFER_DONE')
  transferDone,
}

extension ContractFinancialStatusDisplay on ContractFinancialStatus {
  /// Label em português para exibição na UI.
  String get displayName {
    switch (this) {
      case ContractFinancialStatus.none:
        return 'Não aplicável';
      case ContractFinancialStatus.transferPending:
        return 'Repasse pendente';
      case ContractFinancialStatus.refundInAnalysis:
        return 'Reembolso em análise';
      case ContractFinancialStatus.contested:
        return 'Em contestação';
      case ContractFinancialStatus.partiallyTransferred:
        return 'Repasse parcial';
      case ContractFinancialStatus.fullyRefunded:
        return 'Reembolso total';
      case ContractFinancialStatus.transferDone:
        return 'Repasse realizado';
    }
  }
}

/// Converte string (ex. do Firestore) para enum; retorna null se inválido.
ContractFinancialStatus? tryParseContractFinancialStatus(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return ContractFinancialStatusMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
