import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  /// Referência ao documento de conta bancária na subcoleção
  /// Estrutura: Artists/{artistId}/BankAccount/account
  /// Como cada artista tem apenas uma conta bancária, usamos um docId fixo "account"
  static DocumentReference firebaseUidReference(
    FirebaseFirestore firestore,
    String artistId,
  ) {
    final artistDocRef = firestore.collection('Artists').doc(artistId);
    return artistDocRef.collection('BankAccount').doc('account');
  }

  /// Referência à subcoleção BankAccount do artista
  /// Estrutura: Artists/{artistId}/BankAccount
  static CollectionReference firebaseCollectionReference(
    FirebaseFirestore firestore,
    String artistId,
  ) {
    final artistDocRef = firestore.collection('Artists').doc(artistId);
    return artistDocRef.collection('BankAccount');
  }

  /// Chave para cache local da conta bancária
  static String cachedKey(String artistId) {
    return 'CACHED_BANK_ACCOUNT_$artistId';
  }

  // Listas auxiliares
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
