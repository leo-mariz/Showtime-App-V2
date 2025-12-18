// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_entity.dart';

class UserEntityMapper extends ClassMapperBase<UserEntity> {
  UserEntityMapper._();

  static UserEntityMapper? _instance;
  static UserEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserEntityMapper._());
      CpfUserEntityMapper.ensureInitialized();
      CnpjUserEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UserEntity';

  static String? _$uid(UserEntity v) => v.uid;
  static const Field<UserEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String _$email(UserEntity v) => v.email;
  static const Field<UserEntity, String> _f$email = Field('email', _$email);
  static String? _$password(UserEntity v) => v.password;
  static const Field<UserEntity, String> _f$password = Field(
    'password',
    _$password,
    opt: true,
  );
  static String? _$phoneNumber(UserEntity v) => v.phoneNumber;
  static const Field<UserEntity, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    opt: true,
  );
  static CpfUserEntity? _$cpfUser(UserEntity v) => v.cpfUser;
  static const Field<UserEntity, CpfUserEntity> _f$cpfUser = Field(
    'cpfUser',
    _$cpfUser,
    opt: true,
  );
  static CnpjUserEntity? _$cnpjUser(UserEntity v) => v.cnpjUser;
  static const Field<UserEntity, CnpjUserEntity> _f$cnpjUser = Field(
    'cnpjUser',
    _$cnpjUser,
    opt: true,
  );
  static bool? _$isCnpj(UserEntity v) => v.isCnpj;
  static const Field<UserEntity, bool> _f$isCnpj = Field(
    'isCnpj',
    _$isCnpj,
    opt: true,
  );
  static bool? _$isArtist(UserEntity v) => v.isArtist;
  static const Field<UserEntity, bool> _f$isArtist = Field(
    'isArtist',
    _$isArtist,
    opt: true,
  );
  static bool? _$isEmailVerified(UserEntity v) => v.isEmailVerified;
  static const Field<UserEntity, bool> _f$isEmailVerified = Field(
    'isEmailVerified',
    _$isEmailVerified,
    opt: true,
  );
  static bool? _$isActive(UserEntity v) => v.isActive;
  static const Field<UserEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
  );
  static bool? _$agreedToPrivacyPolicy(UserEntity v) => v.agreedToPrivacyPolicy;
  static const Field<UserEntity, bool> _f$agreedToPrivacyPolicy = Field(
    'agreedToPrivacyPolicy',
    _$agreedToPrivacyPolicy,
    opt: true,
  );
  static bool? _$isDeleted(UserEntity v) => v.isDeleted;
  static const Field<UserEntity, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
  );
  static bool? _$isDeletedByAdmin(UserEntity v) => v.isDeletedByAdmin;
  static const Field<UserEntity, bool> _f$isDeletedByAdmin = Field(
    'isDeletedByAdmin',
    _$isDeletedByAdmin,
    opt: true,
  );
  static DateTime? _$deletedAt(UserEntity v) => v.deletedAt;
  static const Field<UserEntity, DateTime> _f$deletedAt = Field(
    'deletedAt',
    _$deletedAt,
    opt: true,
  );

  @override
  final MappableFields<UserEntity> fields = const {
    #uid: _f$uid,
    #email: _f$email,
    #password: _f$password,
    #phoneNumber: _f$phoneNumber,
    #cpfUser: _f$cpfUser,
    #cnpjUser: _f$cnpjUser,
    #isCnpj: _f$isCnpj,
    #isArtist: _f$isArtist,
    #isEmailVerified: _f$isEmailVerified,
    #isActive: _f$isActive,
    #agreedToPrivacyPolicy: _f$agreedToPrivacyPolicy,
    #isDeleted: _f$isDeleted,
    #isDeletedByAdmin: _f$isDeletedByAdmin,
    #deletedAt: _f$deletedAt,
  };

  static UserEntity _instantiate(DecodingData data) {
    return UserEntity(
      uid: data.dec(_f$uid),
      email: data.dec(_f$email),
      password: data.dec(_f$password),
      phoneNumber: data.dec(_f$phoneNumber),
      cpfUser: data.dec(_f$cpfUser),
      cnpjUser: data.dec(_f$cnpjUser),
      isCnpj: data.dec(_f$isCnpj),
      isArtist: data.dec(_f$isArtist),
      isEmailVerified: data.dec(_f$isEmailVerified),
      isActive: data.dec(_f$isActive),
      agreedToPrivacyPolicy: data.dec(_f$agreedToPrivacyPolicy),
      isDeleted: data.dec(_f$isDeleted),
      isDeletedByAdmin: data.dec(_f$isDeletedByAdmin),
      deletedAt: data.dec(_f$deletedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserEntity>(map);
  }

  static UserEntity fromJson(String json) {
    return ensureInitialized().decodeJson<UserEntity>(json);
  }
}

mixin UserEntityMappable {
  String toJson() {
    return UserEntityMapper.ensureInitialized().encodeJson<UserEntity>(
      this as UserEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return UserEntityMapper.ensureInitialized().encodeMap<UserEntity>(
      this as UserEntity,
    );
  }

  UserEntityCopyWith<UserEntity, UserEntity, UserEntity> get copyWith =>
      _UserEntityCopyWithImpl<UserEntity, UserEntity>(
        this as UserEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserEntityMapper.ensureInitialized().stringifyValue(
      this as UserEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserEntityMapper.ensureInitialized().equalsValue(
      this as UserEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return UserEntityMapper.ensureInitialized().hashValue(this as UserEntity);
  }
}

extension UserEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserEntity, $Out> {
  UserEntityCopyWith<$R, UserEntity, $Out> get $asUserEntity =>
      $base.as((v, t, t2) => _UserEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserEntityCopyWith<$R, $In extends UserEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  CpfUserEntityCopyWith<$R, CpfUserEntity, CpfUserEntity>? get cpfUser;
  CnpjUserEntityCopyWith<$R, CnpjUserEntity, CnpjUserEntity>? get cnpjUser;
  $R call({
    String? uid,
    String? email,
    String? password,
    String? phoneNumber,
    CpfUserEntity? cpfUser,
    CnpjUserEntity? cnpjUser,
    bool? isCnpj,
    bool? isArtist,
    bool? isEmailVerified,
    bool? isActive,
    bool? agreedToPrivacyPolicy,
    bool? isDeleted,
    bool? isDeletedByAdmin,
    DateTime? deletedAt,
  });
  UserEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserEntity, $Out>
    implements UserEntityCopyWith<$R, UserEntity, $Out> {
  _UserEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserEntity> $mapper =
      UserEntityMapper.ensureInitialized();
  @override
  CpfUserEntityCopyWith<$R, CpfUserEntity, CpfUserEntity>? get cpfUser =>
      $value.cpfUser?.copyWith.$chain((v) => call(cpfUser: v));
  @override
  CnpjUserEntityCopyWith<$R, CnpjUserEntity, CnpjUserEntity>? get cnpjUser =>
      $value.cnpjUser?.copyWith.$chain((v) => call(cnpjUser: v));
  @override
  $R call({
    Object? uid = $none,
    String? email,
    Object? password = $none,
    Object? phoneNumber = $none,
    Object? cpfUser = $none,
    Object? cnpjUser = $none,
    Object? isCnpj = $none,
    Object? isArtist = $none,
    Object? isEmailVerified = $none,
    Object? isActive = $none,
    Object? agreedToPrivacyPolicy = $none,
    Object? isDeleted = $none,
    Object? isDeletedByAdmin = $none,
    Object? deletedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (email != null) #email: email,
      if (password != $none) #password: password,
      if (phoneNumber != $none) #phoneNumber: phoneNumber,
      if (cpfUser != $none) #cpfUser: cpfUser,
      if (cnpjUser != $none) #cnpjUser: cnpjUser,
      if (isCnpj != $none) #isCnpj: isCnpj,
      if (isArtist != $none) #isArtist: isArtist,
      if (isEmailVerified != $none) #isEmailVerified: isEmailVerified,
      if (isActive != $none) #isActive: isActive,
      if (agreedToPrivacyPolicy != $none)
        #agreedToPrivacyPolicy: agreedToPrivacyPolicy,
      if (isDeleted != $none) #isDeleted: isDeleted,
      if (isDeletedByAdmin != $none) #isDeletedByAdmin: isDeletedByAdmin,
      if (deletedAt != $none) #deletedAt: deletedAt,
    }),
  );
  @override
  UserEntity $make(CopyWithData data) => UserEntity(
    uid: data.get(#uid, or: $value.uid),
    email: data.get(#email, or: $value.email),
    password: data.get(#password, or: $value.password),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
    cpfUser: data.get(#cpfUser, or: $value.cpfUser),
    cnpjUser: data.get(#cnpjUser, or: $value.cnpjUser),
    isCnpj: data.get(#isCnpj, or: $value.isCnpj),
    isArtist: data.get(#isArtist, or: $value.isArtist),
    isEmailVerified: data.get(#isEmailVerified, or: $value.isEmailVerified),
    isActive: data.get(#isActive, or: $value.isActive),
    agreedToPrivacyPolicy: data.get(
      #agreedToPrivacyPolicy,
      or: $value.agreedToPrivacyPolicy,
    ),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    isDeletedByAdmin: data.get(#isDeletedByAdmin, or: $value.isDeletedByAdmin),
    deletedAt: data.get(#deletedAt, or: $value.deletedAt),
  );

  @override
  UserEntityCopyWith<$R2, UserEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

