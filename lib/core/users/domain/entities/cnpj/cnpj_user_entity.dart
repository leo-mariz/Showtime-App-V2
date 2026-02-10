import 'package:dart_mappable/dart_mappable.dart';
part 'cnpj_user_entity.mapper.dart';

@MappableClass()
class CnpjUserEntity with CnpjUserEntityMappable{
  final String? cnpj;
  final String? companyName;
  final String? fantasyName;
  final String? stateRegistration;

  CnpjUserEntity({
    this.cnpj,
    this.companyName,
    this.fantasyName,
    this.stateRegistration,

  });
}


extension CnpjUserEntityReference on CnpjUserEntity {

  static List<String> cnpjUserFields = [
    'cnpj',
    'companyName',
    'fantasyName',
    'stateRegistration',
  ];
}

