import 'package:dart_mappable/dart_mappable.dart';
part 'bank_account_entity.mapper.dart';

@MappableClass()
class BankAccountEntity with BankAccountEntityMappable {
  String? fullName;
  String? bankName;
  String? agency;
  String? accountNumber;
  String? accountType;
  String? cpfOrCnpj;
  String? pixType;
  String? pixKey;
  

  BankAccountEntity({
    this.fullName,
    this.bankName,
    this.agency,
    this.accountNumber,
    this.accountType,
    this.cpfOrCnpj,
    this.pixKey,
    this.pixType,
  });
}

extension BankAccountEntityReference on BankAccountEntity {
  //Firestore References
  static List<String> pixTypes = [
    'CPF',
    'CNPJ',
    'Email',
    'Telefone',
    'Chave Aleatória',
  ];

  static List<String> accountTypes = [
    'Conta Corrente',
    'Conta Poupança',
  ];
}
