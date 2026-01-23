// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'time_slot_status_enum.dart';

class TimeSlotStatusEnumMapper extends EnumMapper<TimeSlotStatusEnum> {
  TimeSlotStatusEnumMapper._();

  static TimeSlotStatusEnumMapper? _instance;
  static TimeSlotStatusEnumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TimeSlotStatusEnumMapper._());
    }
    return _instance!;
  }

  static TimeSlotStatusEnum fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TimeSlotStatusEnum decode(dynamic value) {
    switch (value) {
      case 'AVAILABLE':
        return TimeSlotStatusEnum.available;
      case 'BOOKED':
        return TimeSlotStatusEnum.booked;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TimeSlotStatusEnum self) {
    switch (self) {
      case TimeSlotStatusEnum.available:
        return 'AVAILABLE';
      case TimeSlotStatusEnum.booked:
        return 'BOOKED';
    }
  }
}

extension TimeSlotStatusEnumMapperExtension on TimeSlotStatusEnum {
  dynamic toValue() {
    TimeSlotStatusEnumMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TimeSlotStatusEnum>(this);
  }
}

