// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'bank_account_entity.dart';

class BankAccountEntityMapper extends ClassMapperBase<BankAccountEntity> {
  BankAccountEntityMapper._();

  static BankAccountEntityMapper? _instance;
  static BankAccountEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BankAccountEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BankAccountEntity';

  static String? _$fullName(BankAccountEntity v) => v.fullName;
  static const Field<BankAccountEntity, String> _f$fullName = Field(
    'fullName',
    _$fullName,
    opt: true,
  );
  static String? _$bankName(BankAccountEntity v) => v.bankName;
  static const Field<BankAccountEntity, String> _f$bankName = Field(
    'bankName',
    _$bankName,
    opt: true,
  );
  static String? _$agency(BankAccountEntity v) => v.agency;
  static const Field<BankAccountEntity, String> _f$agency = Field(
    'agency',
    _$agency,
    opt: true,
  );
  static String? _$accountNumber(BankAccountEntity v) => v.accountNumber;
  static const Field<BankAccountEntity, String> _f$accountNumber = Field(
    'accountNumber',
    _$accountNumber,
    opt: true,
  );
  static String? _$accountType(BankAccountEntity v) => v.accountType;
  static const Field<BankAccountEntity, String> _f$accountType = Field(
    'accountType',
    _$accountType,
    opt: true,
  );
  static String? _$cpfOrCnpj(BankAccountEntity v) => v.cpfOrCnpj;
  static const Field<BankAccountEntity, String> _f$cpfOrCnpj = Field(
    'cpfOrCnpj',
    _$cpfOrCnpj,
    opt: true,
  );
  static String? _$pixKey(BankAccountEntity v) => v.pixKey;
  static const Field<BankAccountEntity, String> _f$pixKey = Field(
    'pixKey',
    _$pixKey,
    opt: true,
  );
  static String? _$pixType(BankAccountEntity v) => v.pixType;
  static const Field<BankAccountEntity, String> _f$pixType = Field(
    'pixType',
    _$pixType,
    opt: true,
  );

  @override
  final MappableFields<BankAccountEntity> fields = const {
    #fullName: _f$fullName,
    #bankName: _f$bankName,
    #agency: _f$agency,
    #accountNumber: _f$accountNumber,
    #accountType: _f$accountType,
    #cpfOrCnpj: _f$cpfOrCnpj,
    #pixKey: _f$pixKey,
    #pixType: _f$pixType,
  };

  static BankAccountEntity _instantiate(DecodingData data) {
    return BankAccountEntity(
      fullName: data.dec(_f$fullName),
      bankName: data.dec(_f$bankName),
      agency: data.dec(_f$agency),
      accountNumber: data.dec(_f$accountNumber),
      accountType: data.dec(_f$accountType),
      cpfOrCnpj: data.dec(_f$cpfOrCnpj),
      pixKey: data.dec(_f$pixKey),
      pixType: data.dec(_f$pixType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BankAccountEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BankAccountEntity>(map);
  }

  static BankAccountEntity fromJson(String json) {
    return ensureInitialized().decodeJson<BankAccountEntity>(json);
  }
}

mixin BankAccountEntityMappable {
  String toJson() {
    return BankAccountEntityMapper.ensureInitialized()
        .encodeJson<BankAccountEntity>(this as BankAccountEntity);
  }

  Map<String, dynamic> toMap() {
    return BankAccountEntityMapper.ensureInitialized()
        .encodeMap<BankAccountEntity>(this as BankAccountEntity);
  }

  BankAccountEntityCopyWith<
    BankAccountEntity,
    BankAccountEntity,
    BankAccountEntity
  >
  get copyWith =>
      _BankAccountEntityCopyWithImpl<BankAccountEntity, BankAccountEntity>(
        this as BankAccountEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BankAccountEntityMapper.ensureInitialized().stringifyValue(
      this as BankAccountEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return BankAccountEntityMapper.ensureInitialized().equalsValue(
      this as BankAccountEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return BankAccountEntityMapper.ensureInitialized().hashValue(
      this as BankAccountEntity,
    );
  }
}

extension BankAccountEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BankAccountEntity, $Out> {
  BankAccountEntityCopyWith<$R, BankAccountEntity, $Out>
  get $asBankAccountEntity => $base.as(
    (v, t, t2) => _BankAccountEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class BankAccountEntityCopyWith<
  $R,
  $In extends BankAccountEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? fullName,
    String? bankName,
    String? agency,
    String? accountNumber,
    String? accountType,
    String? cpfOrCnpj,
    String? pixKey,
    String? pixType,
  });
  BankAccountEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BankAccountEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BankAccountEntity, $Out>
    implements BankAccountEntityCopyWith<$R, BankAccountEntity, $Out> {
  _BankAccountEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BankAccountEntity> $mapper =
      BankAccountEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? fullName = $none,
    Object? bankName = $none,
    Object? agency = $none,
    Object? accountNumber = $none,
    Object? accountType = $none,
    Object? cpfOrCnpj = $none,
    Object? pixKey = $none,
    Object? pixType = $none,
  }) => $apply(
    FieldCopyWithData({
      if (fullName != $none) #fullName: fullName,
      if (bankName != $none) #bankName: bankName,
      if (agency != $none) #agency: agency,
      if (accountNumber != $none) #accountNumber: accountNumber,
      if (accountType != $none) #accountType: accountType,
      if (cpfOrCnpj != $none) #cpfOrCnpj: cpfOrCnpj,
      if (pixKey != $none) #pixKey: pixKey,
      if (pixType != $none) #pixType: pixType,
    }),
  );
  @override
  BankAccountEntity $make(CopyWithData data) => BankAccountEntity(
    fullName: data.get(#fullName, or: $value.fullName),
    bankName: data.get(#bankName, or: $value.bankName),
    agency: data.get(#agency, or: $value.agency),
    accountNumber: data.get(#accountNumber, or: $value.accountNumber),
    accountType: data.get(#accountType, or: $value.accountType),
    cpfOrCnpj: data.get(#cpfOrCnpj, or: $value.cpfOrCnpj),
    pixKey: data.get(#pixKey, or: $value.pixKey),
    pixType: data.get(#pixType, or: $value.pixType),
  );

  @override
  BankAccountEntityCopyWith<$R2, BankAccountEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BankAccountEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

