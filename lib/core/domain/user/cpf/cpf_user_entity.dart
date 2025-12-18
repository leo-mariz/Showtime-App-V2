import 'package:dart_mappable/dart_mappable.dart';
part 'cpf_user_entity.mapper.dart';

@MappableClass()
class CpfUserEntity with CpfUserEntityMappable{
  final String? cpf;
  final String? firstName;
  final String? lastName;
  final String? birthDate;
  final String? gender;



  CpfUserEntity({
    this.cpf,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.gender,
  });
}





extension CpfUserEntityReference on CpfUserEntity {
  static List<String> cpfUserFields = [
    'cpf',
    'firstName',
    'lastName',
    'birthDate',
    'gender',
  ];
}

