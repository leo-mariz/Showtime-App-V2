// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'artist_entity.dart';

class ArtistEntityMapper extends ClassMapperBase<ArtistEntity> {
  ArtistEntityMapper._();

  static ArtistEntityMapper? _instance;
  static ArtistEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ArtistEntityMapper._());
      ProfessionalInfoEntityMapper.ensureInitialized();
      AddressInfoEntityMapper.ensureInitialized();
      BankAccountEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ArtistEntity';

  static String? _$uid(ArtistEntity v) => v.uid;
  static const Field<ArtistEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String? _$profilePicture(ArtistEntity v) => v.profilePicture;
  static const Field<ArtistEntity, String> _f$profilePicture = Field(
    'profilePicture',
    _$profilePicture,
    opt: true,
  );
  static String? _$artistName(ArtistEntity v) => v.artistName;
  static const Field<ArtistEntity, String> _f$artistName = Field(
    'artistName',
    _$artistName,
    opt: true,
  );
  static DateTime? _$dateRegistered(ArtistEntity v) => v.dateRegistered;
  static const Field<ArtistEntity, DateTime> _f$dateRegistered = Field(
    'dateRegistered',
    _$dateRegistered,
    opt: true,
  );
  static ProfessionalInfoEntity? _$professionalInfo(ArtistEntity v) =>
      v.professionalInfo;
  static const Field<ArtistEntity, ProfessionalInfoEntity> _f$professionalInfo =
      Field('professionalInfo', _$professionalInfo, opt: true);
  static Map<String, String>? _$presentationMedias(ArtistEntity v) =>
      v.presentationMedias;
  static const Field<ArtistEntity, Map<String, String>> _f$presentationMedias =
      Field('presentationMedias', _$presentationMedias, opt: true);
  static AddressInfoEntity? _$residenceAddress(ArtistEntity v) =>
      v.residenceAddress;
  static const Field<ArtistEntity, AddressInfoEntity> _f$residenceAddress =
      Field('residenceAddress', _$residenceAddress, opt: true);
  static BankAccountEntity? _$bankAccount(ArtistEntity v) => v.bankAccount;
  static const Field<ArtistEntity, BankAccountEntity> _f$bankAccount = Field(
    'bankAccount',
    _$bankAccount,
    opt: true,
  );
  static bool? _$approved(ArtistEntity v) => v.approved;
  static const Field<ArtistEntity, bool> _f$approved = Field(
    'approved',
    _$approved,
    opt: true,
  );
  static bool? _$isActive(ArtistEntity v) => v.isActive;
  static const Field<ArtistEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
  );
  static bool? _$hasIncompleteSections(ArtistEntity v) =>
      v.hasIncompleteSections;
  static const Field<ArtistEntity, bool> _f$hasIncompleteSections = Field(
    'hasIncompleteSections',
    _$hasIncompleteSections,
    opt: true,
  );
  static Map<String, List<String>>? _$incompleteSections(ArtistEntity v) =>
      v.incompleteSections;
  static const Field<ArtistEntity, Map<String, List<String>>>
  _f$incompleteSections = Field(
    'incompleteSections',
    _$incompleteSections,
    opt: true,
  );
  static bool? _$agreedToArtistTermsOfUse(ArtistEntity v) =>
      v.agreedToArtistTermsOfUse;
  static const Field<ArtistEntity, bool> _f$agreedToArtistTermsOfUse = Field(
    'agreedToArtistTermsOfUse',
    _$agreedToArtistTermsOfUse,
    opt: true,
  );
  static bool? _$isOnAnyGroup(ArtistEntity v) => v.isOnAnyGroup;
  static const Field<ArtistEntity, bool> _f$isOnAnyGroup = Field(
    'isOnAnyGroup',
    _$isOnAnyGroup,
    opt: true,
  );
  static List<String>? _$groupsInUids(ArtistEntity v) => v.groupsInUids;
  static const Field<ArtistEntity, List<String>> _f$groupsInUids = Field(
    'groupsInUids',
    _$groupsInUids,
    opt: true,
  );
  static double _$rating(ArtistEntity v) => v.rating;
  static const Field<ArtistEntity, double> _f$rating = Field(
    'rating',
    _$rating,
    opt: true,
    def: 0,
  );
  static int _$finalizedContracts(ArtistEntity v) => v.finalizedContracts;
  static const Field<ArtistEntity, int> _f$finalizedContracts = Field(
    'finalizedContracts',
    _$finalizedContracts,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<ArtistEntity> fields = const {
    #uid: _f$uid,
    #profilePicture: _f$profilePicture,
    #artistName: _f$artistName,
    #dateRegistered: _f$dateRegistered,
    #professionalInfo: _f$professionalInfo,
    #presentationMedias: _f$presentationMedias,
    #residenceAddress: _f$residenceAddress,
    #bankAccount: _f$bankAccount,
    #approved: _f$approved,
    #isActive: _f$isActive,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteSections: _f$incompleteSections,
    #agreedToArtistTermsOfUse: _f$agreedToArtistTermsOfUse,
    #isOnAnyGroup: _f$isOnAnyGroup,
    #groupsInUids: _f$groupsInUids,
    #rating: _f$rating,
    #finalizedContracts: _f$finalizedContracts,
  };

  static ArtistEntity _instantiate(DecodingData data) {
    return ArtistEntity(
      uid: data.dec(_f$uid),
      profilePicture: data.dec(_f$profilePicture),
      artistName: data.dec(_f$artistName),
      dateRegistered: data.dec(_f$dateRegistered),
      professionalInfo: data.dec(_f$professionalInfo),
      presentationMedias: data.dec(_f$presentationMedias),
      residenceAddress: data.dec(_f$residenceAddress),
      bankAccount: data.dec(_f$bankAccount),
      approved: data.dec(_f$approved),
      isActive: data.dec(_f$isActive),
      hasIncompleteSections: data.dec(_f$hasIncompleteSections),
      incompleteSections: data.dec(_f$incompleteSections),
      agreedToArtistTermsOfUse: data.dec(_f$agreedToArtistTermsOfUse),
      isOnAnyGroup: data.dec(_f$isOnAnyGroup),
      groupsInUids: data.dec(_f$groupsInUids),
      rating: data.dec(_f$rating),
      finalizedContracts: data.dec(_f$finalizedContracts),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ArtistEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ArtistEntity>(map);
  }

  static ArtistEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ArtistEntity>(json);
  }
}

mixin ArtistEntityMappable {
  String toJson() {
    return ArtistEntityMapper.ensureInitialized().encodeJson<ArtistEntity>(
      this as ArtistEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return ArtistEntityMapper.ensureInitialized().encodeMap<ArtistEntity>(
      this as ArtistEntity,
    );
  }

  ArtistEntityCopyWith<ArtistEntity, ArtistEntity, ArtistEntity> get copyWith =>
      _ArtistEntityCopyWithImpl<ArtistEntity, ArtistEntity>(
        this as ArtistEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ArtistEntityMapper.ensureInitialized().stringifyValue(
      this as ArtistEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ArtistEntityMapper.ensureInitialized().equalsValue(
      this as ArtistEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ArtistEntityMapper.ensureInitialized().hashValue(
      this as ArtistEntity,
    );
  }
}

extension ArtistEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ArtistEntity, $Out> {
  ArtistEntityCopyWith<$R, ArtistEntity, $Out> get $asArtistEntity =>
      $base.as((v, t, t2) => _ArtistEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ArtistEntityCopyWith<$R, $In extends ArtistEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfessionalInfoEntityCopyWith<
    $R,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >?
  get professionalInfo;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get presentationMedias;
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get residenceAddress;
  BankAccountEntityCopyWith<$R, BankAccountEntity, BankAccountEntity>?
  get bankAccount;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get groupsInUids;
  $R call({
    String? uid,
    String? profilePicture,
    String? artistName,
    DateTime? dateRegistered,
    ProfessionalInfoEntity? professionalInfo,
    Map<String, String>? presentationMedias,
    AddressInfoEntity? residenceAddress,
    BankAccountEntity? bankAccount,
    bool? approved,
    bool? isActive,
    bool? hasIncompleteSections,
    Map<String, List<String>>? incompleteSections,
    bool? agreedToArtistTermsOfUse,
    bool? isOnAnyGroup,
    List<String>? groupsInUids,
    double? rating,
    int? finalizedContracts,
  });
  ArtistEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ArtistEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ArtistEntity, $Out>
    implements ArtistEntityCopyWith<$R, ArtistEntity, $Out> {
  _ArtistEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ArtistEntity> $mapper =
      ArtistEntityMapper.ensureInitialized();
  @override
  ProfessionalInfoEntityCopyWith<
    $R,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >?
  get professionalInfo => $value.professionalInfo?.copyWith.$chain(
    (v) => call(professionalInfo: v),
  );
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get presentationMedias => $value.presentationMedias != null
      ? MapCopyWith(
          $value.presentationMedias!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(presentationMedias: v),
        )
      : null;
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get residenceAddress => $value.residenceAddress?.copyWith.$chain(
    (v) => call(residenceAddress: v),
  );
  @override
  BankAccountEntityCopyWith<$R, BankAccountEntity, BankAccountEntity>?
  get bankAccount =>
      $value.bankAccount?.copyWith.$chain((v) => call(bankAccount: v));
  @override
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections => $value.incompleteSections != null
      ? MapCopyWith(
          $value.incompleteSections!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(incompleteSections: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get groupsInUids => $value.groupsInUids != null
      ? ListCopyWith(
          $value.groupsInUids!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(groupsInUids: v),
        )
      : null;
  @override
  $R call({
    Object? uid = $none,
    Object? profilePicture = $none,
    Object? artistName = $none,
    Object? dateRegistered = $none,
    Object? professionalInfo = $none,
    Object? presentationMedias = $none,
    Object? residenceAddress = $none,
    Object? bankAccount = $none,
    Object? approved = $none,
    Object? isActive = $none,
    Object? hasIncompleteSections = $none,
    Object? incompleteSections = $none,
    Object? agreedToArtistTermsOfUse = $none,
    Object? isOnAnyGroup = $none,
    Object? groupsInUids = $none,
    double? rating,
    int? finalizedContracts,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (artistName != $none) #artistName: artistName,
      if (dateRegistered != $none) #dateRegistered: dateRegistered,
      if (professionalInfo != $none) #professionalInfo: professionalInfo,
      if (presentationMedias != $none) #presentationMedias: presentationMedias,
      if (residenceAddress != $none) #residenceAddress: residenceAddress,
      if (bankAccount != $none) #bankAccount: bankAccount,
      if (approved != $none) #approved: approved,
      if (isActive != $none) #isActive: isActive,
      if (hasIncompleteSections != $none)
        #hasIncompleteSections: hasIncompleteSections,
      if (incompleteSections != $none) #incompleteSections: incompleteSections,
      if (agreedToArtistTermsOfUse != $none)
        #agreedToArtistTermsOfUse: agreedToArtistTermsOfUse,
      if (isOnAnyGroup != $none) #isOnAnyGroup: isOnAnyGroup,
      if (groupsInUids != $none) #groupsInUids: groupsInUids,
      if (rating != null) #rating: rating,
      if (finalizedContracts != null) #finalizedContracts: finalizedContracts,
    }),
  );
  @override
  ArtistEntity $make(CopyWithData data) => ArtistEntity(
    uid: data.get(#uid, or: $value.uid),
    profilePicture: data.get(#profilePicture, or: $value.profilePicture),
    artistName: data.get(#artistName, or: $value.artistName),
    dateRegistered: data.get(#dateRegistered, or: $value.dateRegistered),
    professionalInfo: data.get(#professionalInfo, or: $value.professionalInfo),
    presentationMedias: data.get(
      #presentationMedias,
      or: $value.presentationMedias,
    ),
    residenceAddress: data.get(#residenceAddress, or: $value.residenceAddress),
    bankAccount: data.get(#bankAccount, or: $value.bankAccount),
    approved: data.get(#approved, or: $value.approved),
    isActive: data.get(#isActive, or: $value.isActive),
    hasIncompleteSections: data.get(
      #hasIncompleteSections,
      or: $value.hasIncompleteSections,
    ),
    incompleteSections: data.get(
      #incompleteSections,
      or: $value.incompleteSections,
    ),
    agreedToArtistTermsOfUse: data.get(
      #agreedToArtistTermsOfUse,
      or: $value.agreedToArtistTermsOfUse,
    ),
    isOnAnyGroup: data.get(#isOnAnyGroup, or: $value.isOnAnyGroup),
    groupsInUids: data.get(#groupsInUids, or: $value.groupsInUids),
    rating: data.get(#rating, or: $value.rating),
    finalizedContracts: data.get(
      #finalizedContracts,
      or: $value.finalizedContracts,
    ),
  );

  @override
  ArtistEntityCopyWith<$R2, ArtistEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ArtistEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

