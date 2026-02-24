// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'showtime_payment_status_enum.dart';

class ShowtimePaymentStatusMapper extends EnumMapper<ShowtimePaymentStatus> {
  ShowtimePaymentStatusMapper._();

  static ShowtimePaymentStatusMapper? _instance;
  static ShowtimePaymentStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ShowtimePaymentStatusMapper._());
    }
    return _instance!;
  }

  static ShowtimePaymentStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ShowtimePaymentStatus decode(dynamic value) {
    switch (value) {
      case 'PENDING':
        return ShowtimePaymentStatus.pending;
      case 'PAID':
        return ShowtimePaymentStatus.paid;
      case 'REFUND':
        return ShowtimePaymentStatus.refund;
      case 'IN_DISPUTE':
        return ShowtimePaymentStatus.inDispute;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ShowtimePaymentStatus self) {
    switch (self) {
      case ShowtimePaymentStatus.pending:
        return 'PENDING';
      case ShowtimePaymentStatus.paid:
        return 'PAID';
      case ShowtimePaymentStatus.refund:
        return 'REFUND';
      case ShowtimePaymentStatus.inDispute:
        return 'IN_DISPUTE';
    }
  }
}

extension ShowtimePaymentStatusMapperExtension on ShowtimePaymentStatus {
  dynamic toValue() {
    ShowtimePaymentStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ShowtimePaymentStatus>(this);
  }
}

