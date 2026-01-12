// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'contract_status_enum.dart';

class ContractStatusEnumMapper extends EnumMapper<ContractStatusEnum> {
  ContractStatusEnumMapper._();

  static ContractStatusEnumMapper? _instance;
  static ContractStatusEnumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContractStatusEnumMapper._());
    }
    return _instance!;
  }

  static ContractStatusEnum fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ContractStatusEnum decode(dynamic value) {
    switch (value) {
      case 'PENDING':
        return ContractStatusEnum.pending;
      case 'REJECTED':
        return ContractStatusEnum.rejected;
      case 'PAYMENT_PENDING':
        return ContractStatusEnum.paymentPending;
      case 'PAYMENT_EXPIRED':
        return ContractStatusEnum.paymentExpired;
      case 'PAYMENT_REFUSED':
        return ContractStatusEnum.paymentRefused;
      case 'PAYMENT_FAILED':
        return ContractStatusEnum.paymentFailed;
      case 'PAID':
        return ContractStatusEnum.paid;
      case 'COMPLETED':
        return ContractStatusEnum.completed;
      case 'RATED':
        return ContractStatusEnum.rated;
      case 'CANCELED':
        return ContractStatusEnum.canceled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ContractStatusEnum self) {
    switch (self) {
      case ContractStatusEnum.pending:
        return 'PENDING';
      case ContractStatusEnum.rejected:
        return 'REJECTED';
      case ContractStatusEnum.paymentPending:
        return 'PAYMENT_PENDING';
      case ContractStatusEnum.paymentExpired:
        return 'PAYMENT_EXPIRED';
      case ContractStatusEnum.paymentRefused:
        return 'PAYMENT_REFUSED';
      case ContractStatusEnum.paymentFailed:
        return 'PAYMENT_FAILED';
      case ContractStatusEnum.paid:
        return 'PAID';
      case ContractStatusEnum.completed:
        return 'COMPLETED';
      case ContractStatusEnum.rated:
        return 'RATED';
      case ContractStatusEnum.canceled:
        return 'CANCELED';
    }
  }
}

extension ContractStatusEnumMapperExtension on ContractStatusEnum {
  dynamic toValue() {
    ContractStatusEnumMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ContractStatusEnum>(this);
  }
}

