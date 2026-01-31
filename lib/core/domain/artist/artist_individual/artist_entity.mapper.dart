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
  static List<String>? _$groupsUids(ArtistEntity v) => v.groupsUids;
  static const Field<ArtistEntity, List<String>> _f$groupsUids = Field(
    'groupsUids',
    _$groupsUids,
    opt: true,
  );
  static double? _$rating(ArtistEntity v) => v.rating;
  static const Field<ArtistEntity, double> _f$rating = Field(
    'rating',
    _$rating,
    opt: true,
  );
  static int? _$rateCount(ArtistEntity v) => v.rateCount;
  static const Field<ArtistEntity, int> _f$rateCount = Field(
    'rateCount',
    _$rateCount,
    opt: true,
  );
  static List<String>? _$contractsRatedUids(ArtistEntity v) =>
      v.contractsRatedUids;
  static const Field<ArtistEntity, List<String>> _f$contractsRatedUids = Field(
    'contractsRatedUids',
    _$contractsRatedUids,
    opt: true,
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
    #approved: _f$approved,
    #isActive: _f$isActive,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteSections: _f$incompleteSections,
    #agreedToArtistTermsOfUse: _f$agreedToArtistTermsOfUse,
    #isOnAnyGroup: _f$isOnAnyGroup,
    #groupsUids: _f$groupsUids,
    #rating: _f$rating,
    #rateCount: _f$rateCount,
    #contractsRatedUids: _f$contractsRatedUids,
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
      approved: data.dec(_f$approved),
      isActive: data.dec(_f$isActive),
      hasIncompleteSections: data.dec(_f$hasIncompleteSections),
      incompleteSections: data.dec(_f$incompleteSections),
      agreedToArtistTermsOfUse: data.dec(_f$agreedToArtistTermsOfUse),
      isOnAnyGroup: data.dec(_f$isOnAnyGroup),
      groupsUids: data.dec(_f$groupsUids),
      rating: data.dec(_f$rating),
      rateCount: data.dec(_f$rateCount),
      contractsRatedUids: data.dec(_f$contractsRatedUids),
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
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get groupsUids;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get contractsRatedUids;
  $R call({
    String? uid,
    String? profilePicture,
    String? artistName,
    DateTime? dateRegistered,
    ProfessionalInfoEntity? professionalInfo,
    Map<String, String>? presentationMedias,
    AddressInfoEntity? residenceAddress,
    bool? approved,
    bool? isActive,
    bool? hasIncompleteSections,
    Map<String, List<String>>? incompleteSections,
    bool? agreedToArtistTermsOfUse,
    bool? isOnAnyGroup,
    List<String>? groupsUids,
    double? rating,
    int? rateCount,
    List<String>? contractsRatedUids,
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
  get groupsUids => $value.groupsUids != null
      ? ListCopyWith(
          $value.groupsUids!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(groupsUids: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get contractsRatedUids => $value.contractsRatedUids != null
      ? ListCopyWith(
          $value.contractsRatedUids!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(contractsRatedUids: v),
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
    Object? approved = $none,
    Object? isActive = $none,
    Object? hasIncompleteSections = $none,
    Object? incompleteSections = $none,
    Object? agreedToArtistTermsOfUse = $none,
    Object? isOnAnyGroup = $none,
    Object? groupsUids = $none,
    Object? rating = $none,
    Object? rateCount = $none,
    Object? contractsRatedUids = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (artistName != $none) #artistName: artistName,
      if (dateRegistered != $none) #dateRegistered: dateRegistered,
      if (professionalInfo != $none) #professionalInfo: professionalInfo,
      if (presentationMedias != $none) #presentationMedias: presentationMedias,
      if (residenceAddress != $none) #residenceAddress: residenceAddress,
      if (approved != $none) #approved: approved,
      if (isActive != $none) #isActive: isActive,
      if (hasIncompleteSections != $none)
        #hasIncompleteSections: hasIncompleteSections,
      if (incompleteSections != $none) #incompleteSections: incompleteSections,
      if (agreedToArtistTermsOfUse != $none)
        #agreedToArtistTermsOfUse: agreedToArtistTermsOfUse,
      if (isOnAnyGroup != $none) #isOnAnyGroup: isOnAnyGroup,
      if (groupsUids != $none) #groupsUids: groupsUids,
      if (rating != $none) #rating: rating,
      if (rateCount != $none) #rateCount: rateCount,
      if (contractsRatedUids != $none) #contractsRatedUids: contractsRatedUids,
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
    groupsUids: data.get(#groupsUids, or: $value.groupsUids),
    rating: data.get(#rating, or: $value.rating),
    rateCount: data.get(#rateCount, or: $value.rateCount),
    contractsRatedUids: data.get(
      #contractsRatedUids,
      or: $value.contractsRatedUids,
    ),
  );

  @override
  ArtistEntityCopyWith<$R2, ArtistEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ArtistEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

