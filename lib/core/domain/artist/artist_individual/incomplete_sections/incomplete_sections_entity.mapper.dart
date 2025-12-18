// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'incomplete_sections_entity.dart';

class UserIncompleteSectionsEntityMapper
    extends ClassMapperBase<UserIncompleteSectionsEntity> {
  UserIncompleteSectionsEntityMapper._();

  static UserIncompleteSectionsEntityMapper? _instance;
  static UserIncompleteSectionsEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = UserIncompleteSectionsEntityMapper._(),
      );
      ArtistEntityMapper.ensureInitialized();
      DocumentsEntityMapper.ensureInitialized();
      AddressInfoEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UserIncompleteSectionsEntity';

  static const Field<UserIncompleteSectionsEntity, ArtistEntity> _f$artist =
      Field('artist', null, mode: FieldMode.param);
  static const Field<UserIncompleteSectionsEntity, List<DocumentsEntity>>
  _f$documents = Field('documents', null, mode: FieldMode.param);
  static const Field<UserIncompleteSectionsEntity, List<AddressInfoEntity>>
  _f$mainAddress = Field('mainAddress', null, mode: FieldMode.param, opt: true);
  static bool _$hasIncompleteSections(UserIncompleteSectionsEntity v) =>
      v.hasIncompleteSections;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$hasIncompleteSections = Field(
    'hasIncompleteSections',
    _$hasIncompleteSections,
    mode: FieldMode.member,
  );
  static bool _$incompleteRegisterData(UserIncompleteSectionsEntity v) =>
      v.incompleteRegisterData;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteRegisterData = Field(
    'incompleteRegisterData',
    _$incompleteRegisterData,
    mode: FieldMode.member,
  );
  static bool _$incompleteArtistArea(UserIncompleteSectionsEntity v) =>
      v.incompleteArtistArea;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteArtistArea = Field(
    'incompleteArtistArea',
    _$incompleteArtistArea,
    mode: FieldMode.member,
  );
  static bool _$incompleteProfessionalInfo(UserIncompleteSectionsEntity v) =>
      v.incompleteProfessionalInfo;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteProfessionalInfo = Field(
    'incompleteProfessionalInfo',
    _$incompleteProfessionalInfo,
    mode: FieldMode.member,
  );
  static bool _$incompleteBankAccount(UserIncompleteSectionsEntity v) =>
      v.incompleteBankAccount;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteBankAccount = Field(
    'incompleteBankAccount',
    _$incompleteBankAccount,
    mode: FieldMode.member,
  );
  static bool _$incompleteDocuments(UserIncompleteSectionsEntity v) =>
      v.incompleteDocuments;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteDocuments = Field(
    'incompleteDocuments',
    _$incompleteDocuments,
    mode: FieldMode.member,
  );
  static bool _$incompletePresentationMedias(UserIncompleteSectionsEntity v) =>
      v.incompletePresentationMedias;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompletePresentationMedias = Field(
    'incompletePresentationMedias',
    _$incompletePresentationMedias,
    mode: FieldMode.member,
  );
  static bool _$incompleteProfilePicture(UserIncompleteSectionsEntity v) =>
      v.incompleteProfilePicture;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteProfilePicture = Field(
    'incompleteProfilePicture',
    _$incompleteProfilePicture,
    mode: FieldMode.member,
  );
  static bool _$incompleteMainAddress(UserIncompleteSectionsEntity v) =>
      v.incompleteMainAddress;
  static const Field<UserIncompleteSectionsEntity, bool>
  _f$incompleteMainAddress = Field(
    'incompleteMainAddress',
    _$incompleteMainAddress,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UserIncompleteSectionsEntity> fields = const {
    #artist: _f$artist,
    #documents: _f$documents,
    #mainAddress: _f$mainAddress,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteRegisterData: _f$incompleteRegisterData,
    #incompleteArtistArea: _f$incompleteArtistArea,
    #incompleteProfessionalInfo: _f$incompleteProfessionalInfo,
    #incompleteBankAccount: _f$incompleteBankAccount,
    #incompleteDocuments: _f$incompleteDocuments,
    #incompletePresentationMedias: _f$incompletePresentationMedias,
    #incompleteProfilePicture: _f$incompleteProfilePicture,
    #incompleteMainAddress: _f$incompleteMainAddress,
  };

  static UserIncompleteSectionsEntity _instantiate(DecodingData data) {
    return UserIncompleteSectionsEntity.verify(
      artist: data.dec(_f$artist),
      documents: data.dec(_f$documents),
      mainAddress: data.dec(_f$mainAddress),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserIncompleteSectionsEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserIncompleteSectionsEntity>(map);
  }

  static UserIncompleteSectionsEntity fromJson(String json) {
    return ensureInitialized().decodeJson<UserIncompleteSectionsEntity>(json);
  }
}

mixin UserIncompleteSectionsEntityMappable {
  String toJson() {
    return UserIncompleteSectionsEntityMapper.ensureInitialized()
        .encodeJson<UserIncompleteSectionsEntity>(
          this as UserIncompleteSectionsEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return UserIncompleteSectionsEntityMapper.ensureInitialized()
        .encodeMap<UserIncompleteSectionsEntity>(
          this as UserIncompleteSectionsEntity,
        );
  }

  UserIncompleteSectionsEntityCopyWith<
    UserIncompleteSectionsEntity,
    UserIncompleteSectionsEntity,
    UserIncompleteSectionsEntity
  >
  get copyWith =>
      _UserIncompleteSectionsEntityCopyWithImpl<
        UserIncompleteSectionsEntity,
        UserIncompleteSectionsEntity
      >(this as UserIncompleteSectionsEntity, $identity, $identity);
  @override
  String toString() {
    return UserIncompleteSectionsEntityMapper.ensureInitialized()
        .stringifyValue(this as UserIncompleteSectionsEntity);
  }

  @override
  bool operator ==(Object other) {
    return UserIncompleteSectionsEntityMapper.ensureInitialized().equalsValue(
      this as UserIncompleteSectionsEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return UserIncompleteSectionsEntityMapper.ensureInitialized().hashValue(
      this as UserIncompleteSectionsEntity,
    );
  }
}

extension UserIncompleteSectionsEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserIncompleteSectionsEntity, $Out> {
  UserIncompleteSectionsEntityCopyWith<$R, UserIncompleteSectionsEntity, $Out>
  get $asUserIncompleteSectionsEntity => $base.as(
    (v, t, t2) => _UserIncompleteSectionsEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UserIncompleteSectionsEntityCopyWith<
  $R,
  $In extends UserIncompleteSectionsEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    required ArtistEntity artist,
    List<DocumentsEntity>? documents,
    List<AddressInfoEntity>? mainAddress,
  });
  UserIncompleteSectionsEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UserIncompleteSectionsEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserIncompleteSectionsEntity, $Out>
    implements
        UserIncompleteSectionsEntityCopyWith<
          $R,
          UserIncompleteSectionsEntity,
          $Out
        > {
  _UserIncompleteSectionsEntityCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<UserIncompleteSectionsEntity> $mapper =
      UserIncompleteSectionsEntityMapper.ensureInitialized();
  @override
  $R call({
    required ArtistEntity artist,
    List<DocumentsEntity>? documents,
    List<AddressInfoEntity>? mainAddress,
  }) => $apply(
    FieldCopyWithData({
      #artist: artist,
      #documents: documents,
      #mainAddress: mainAddress,
    }),
  );
  @override
  UserIncompleteSectionsEntity $make(CopyWithData data) =>
      UserIncompleteSectionsEntity.verify(
        artist: data.get(#artist),
        documents: data.get(#documents),
        mainAddress: data.get(#mainAddress),
      );

  @override
  UserIncompleteSectionsEntityCopyWith<$R2, UserIncompleteSectionsEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserIncompleteSectionsEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

