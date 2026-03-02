// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'contract_financial_status_enum.dart';

class ContractFinancialStatusMapper
    extends EnumMapper<ContractFinancialStatus> {
  ContractFinancialStatusMapper._();

  static ContractFinancialStatusMapper? _instance;
  static ContractFinancialStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ContractFinancialStatusMapper._(),
      );
    }
    return _instance!;
  }

  static ContractFinancialStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ContractFinancialStatus decode(dynamic value) {
    switch (value) {
      case 'NONE':
        return ContractFinancialStatus.none;
      case 'TRANSFER_PENDING':
        return ContractFinancialStatus.transferPending;
      case 'REFUND_IN_ANALYSIS':
        return ContractFinancialStatus.refundInAnalysis;
      case 'CONTESTED':
        return ContractFinancialStatus.contested;
      case 'PARTIALLY_TRANSFERRED':
        return ContractFinancialStatus.partiallyTransferred;
      case 'FULLY_REFUNDED':
        return ContractFinancialStatus.fullyRefunded;
      case 'TRANSFER_DONE':
        return ContractFinancialStatus.transferDone;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ContractFinancialStatus self) {
    switch (self) {
      case ContractFinancialStatus.none:
        return 'NONE';
      case ContractFinancialStatus.transferPending:
        return 'TRANSFER_PENDING';
      case ContractFinancialStatus.refundInAnalysis:
        return 'REFUND_IN_ANALYSIS';
      case ContractFinancialStatus.contested:
        return 'CONTESTED';
      case ContractFinancialStatus.partiallyTransferred:
        return 'PARTIALLY_TRANSFERRED';
      case ContractFinancialStatus.fullyRefunded:
        return 'FULLY_REFUNDED';
      case ContractFinancialStatus.transferDone:
        return 'TRANSFER_DONE';
    }
  }
}

extension ContractFinancialStatusMapperExtension on ContractFinancialStatus {
  dynamic toValue() {
    ContractFinancialStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ContractFinancialStatus>(this);
  }
}

