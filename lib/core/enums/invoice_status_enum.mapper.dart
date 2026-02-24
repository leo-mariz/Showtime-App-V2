// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'invoice_status_enum.dart';

class InvoiceStatusMapper extends EnumMapper<InvoiceStatus> {
  InvoiceStatusMapper._();

  static InvoiceStatusMapper? _instance;
  static InvoiceStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InvoiceStatusMapper._());
    }
    return _instance!;
  }

  static InvoiceStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  InvoiceStatus decode(dynamic value) {
    switch (value) {
      case 'PENDING':
        return InvoiceStatus.pending;
      case 'EMITTED':
        return InvoiceStatus.emitted;
      case 'DISPENSED':
        return InvoiceStatus.dispensed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(InvoiceStatus self) {
    switch (self) {
      case InvoiceStatus.pending:
        return 'PENDING';
      case InvoiceStatus.emitted:
        return 'EMITTED';
      case InvoiceStatus.dispensed:
        return 'DISPENSED';
    }
  }
}

extension InvoiceStatusMapperExtension on InvoiceStatus {
  dynamic toValue() {
    InvoiceStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<InvoiceStatus>(this);
  }
}

