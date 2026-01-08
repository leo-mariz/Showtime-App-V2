import 'package:dart_mappable/dart_mappable.dart';

part 'contractor_type_enum.mapper.dart';

@MappableEnum()
enum ContractorTypeEnum {
  @MappableValue('ARTIST')
  artist,
  @MappableValue('GROUP')
  group;

  String get value {
    switch (this) {
      case ContractorTypeEnum.artist:
        return 'ARTIST';
      case ContractorTypeEnum.group:
        return 'GROUP';
    }
  }
}

