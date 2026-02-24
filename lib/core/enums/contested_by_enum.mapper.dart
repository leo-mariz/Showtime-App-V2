// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'contested_by_enum.dart';

class ContestedByMapper extends EnumMapper<ContestedBy> {
  ContestedByMapper._();

  static ContestedByMapper? _instance;
  static ContestedByMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContestedByMapper._());
    }
    return _instance!;
  }

  static ContestedBy fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ContestedBy decode(dynamic value) {
    switch (value) {
      case 'CLIENT':
        return ContestedBy.client;
      case 'ARTIST':
        return ContestedBy.artist;
      case 'PLATFORM':
        return ContestedBy.platform;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ContestedBy self) {
    switch (self) {
      case ContestedBy.client:
        return 'CLIENT';
      case ContestedBy.artist:
        return 'ARTIST';
      case ContestedBy.platform:
        return 'PLATFORM';
    }
  }
}

extension ContestedByMapperExtension on ContestedBy {
  dynamic toValue() {
    ContestedByMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ContestedBy>(this);
  }
}

