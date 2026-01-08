// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'contractor_type_enum.dart';

class ContractorTypeEnumMapper extends EnumMapper<ContractorTypeEnum> {
  ContractorTypeEnumMapper._();

  static ContractorTypeEnumMapper? _instance;
  static ContractorTypeEnumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContractorTypeEnumMapper._());
    }
    return _instance!;
  }

  static ContractorTypeEnum fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ContractorTypeEnum decode(dynamic value) {
    switch (value) {
      case 'ARTIST':
        return ContractorTypeEnum.artist;
      case 'GROUP':
        return ContractorTypeEnum.group;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ContractorTypeEnum self) {
    switch (self) {
      case ContractorTypeEnum.artist:
        return 'ARTIST';
      case ContractorTypeEnum.group:
        return 'GROUP';
    }
  }
}

extension ContractorTypeEnumMapperExtension on ContractorTypeEnum {
  dynamic toValue() {
    ContractorTypeEnumMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ContractorTypeEnum>(this);
  }
}

