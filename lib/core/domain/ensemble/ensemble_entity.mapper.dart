// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ensemble_entity.dart';

class EnsembleEntityMapper extends ClassMapperBase<EnsembleEntity> {
  EnsembleEntityMapper._();

  static EnsembleEntityMapper? _instance;
  static EnsembleEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnsembleEntityMapper._());
      ProfessionalInfoEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EnsembleEntity';

  static String? _$id(EnsembleEntity v) => v.id;
  static const Field<EnsembleEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static String _$ownerArtistId(EnsembleEntity v) => v.ownerArtistId;
  static const Field<EnsembleEntity, String> _f$ownerArtistId = Field(
    'ownerArtistId',
    _$ownerArtistId,
  );
  static String? _$profilePhotoUrl(EnsembleEntity v) => v.profilePhotoUrl;
  static const Field<EnsembleEntity, String> _f$profilePhotoUrl = Field(
    'profilePhotoUrl',
    _$profilePhotoUrl,
    opt: true,
  );
  static String? _$ensembleName(EnsembleEntity v) => v.ensembleName;
  static const Field<EnsembleEntity, String> _f$ensembleName = Field(
    'ensembleName',
    _$ensembleName,
    opt: true,
  );
  static ProfessionalInfoEntity? _$professionalInfo(EnsembleEntity v) =>
      v.professionalInfo;
  static const Field<EnsembleEntity, ProfessionalInfoEntity>
  _f$professionalInfo = Field(
    'professionalInfo',
    _$professionalInfo,
    opt: true,
  );
  static String? _$presentationVideoUrl(EnsembleEntity v) =>
      v.presentationVideoUrl;
  static const Field<EnsembleEntity, String> _f$presentationVideoUrl = Field(
    'presentationVideoUrl',
    _$presentationVideoUrl,
    opt: true,
  );
  static int? _$members(EnsembleEntity v) => v.members;
  static const Field<EnsembleEntity, int> _f$members = Field(
    'members',
    _$members,
    opt: true,
  );
  static List<String>? _$talents(EnsembleEntity v) => v.talents;
  static const Field<EnsembleEntity, List<String>> _f$talents = Field(
    'talents',
    _$talents,
    opt: true,
  );
  static String? _$ensembleType(EnsembleEntity v) => v.ensembleType;
  static const Field<EnsembleEntity, String> _f$ensembleType = Field(
    'ensembleType',
    _$ensembleType,
    opt: true,
  );
  static bool? _$isActive(EnsembleEntity v) => v.isActive;
  static const Field<EnsembleEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
  );
  static bool? _$hasIncompleteSections(EnsembleEntity v) =>
      v.hasIncompleteSections;
  static const Field<EnsembleEntity, bool> _f$hasIncompleteSections = Field(
    'hasIncompleteSections',
    _$hasIncompleteSections,
    opt: true,
  );
  static Map<String, List<String>>? _$incompleteSections(EnsembleEntity v) =>
      v.incompleteSections;
  static const Field<EnsembleEntity, Map<String, List<String>>>
  _f$incompleteSections = Field(
    'incompleteSections',
    _$incompleteSections,
    opt: true,
  );
  static DateTime? _$createdAt(EnsembleEntity v) => v.createdAt;
  static const Field<EnsembleEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );
  static DateTime? _$updatedAt(EnsembleEntity v) => v.updatedAt;
  static const Field<EnsembleEntity, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );
  static DateTime? _$lastUpdatedAt(EnsembleEntity v) => v.lastUpdatedAt;
  static const Field<EnsembleEntity, DateTime> _f$lastUpdatedAt = Field(
    'lastUpdatedAt',
    _$lastUpdatedAt,
    opt: true,
  );
  static Map<String, int>? _$updatedInfos(EnsembleEntity v) => v.updatedInfos;
  static const Field<EnsembleEntity, Map<String, int>> _f$updatedInfos = Field(
    'updatedInfos',
    _$updatedInfos,
    opt: true,
  );
  static double? _$rating(EnsembleEntity v) => v.rating;
  static const Field<EnsembleEntity, double> _f$rating = Field(
    'rating',
    _$rating,
    opt: true,
  );
  static int? _$rateCount(EnsembleEntity v) => v.rateCount;
  static const Field<EnsembleEntity, int> _f$rateCount = Field(
    'rateCount',
    _$rateCount,
    opt: true,
  );
  static List<String>? _$contractsRatedUids(EnsembleEntity v) =>
      v.contractsRatedUids;
  static const Field<EnsembleEntity, List<String>> _f$contractsRatedUids =
      Field('contractsRatedUids', _$contractsRatedUids, opt: true);

  @override
  final MappableFields<EnsembleEntity> fields = const {
    #id: _f$id,
    #ownerArtistId: _f$ownerArtistId,
    #profilePhotoUrl: _f$profilePhotoUrl,
    #ensembleName: _f$ensembleName,
    #professionalInfo: _f$professionalInfo,
    #presentationVideoUrl: _f$presentationVideoUrl,
    #members: _f$members,
    #talents: _f$talents,
    #ensembleType: _f$ensembleType,
    #isActive: _f$isActive,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteSections: _f$incompleteSections,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #lastUpdatedAt: _f$lastUpdatedAt,
    #updatedInfos: _f$updatedInfos,
    #rating: _f$rating,
    #rateCount: _f$rateCount,
    #contractsRatedUids: _f$contractsRatedUids,
  };

  static EnsembleEntity _instantiate(DecodingData data) {
    return EnsembleEntity(
      id: data.dec(_f$id),
      ownerArtistId: data.dec(_f$ownerArtistId),
      profilePhotoUrl: data.dec(_f$profilePhotoUrl),
      ensembleName: data.dec(_f$ensembleName),
      professionalInfo: data.dec(_f$professionalInfo),
      presentationVideoUrl: data.dec(_f$presentationVideoUrl),
      members: data.dec(_f$members),
      talents: data.dec(_f$talents),
      ensembleType: data.dec(_f$ensembleType),
      isActive: data.dec(_f$isActive),
      hasIncompleteSections: data.dec(_f$hasIncompleteSections),
      incompleteSections: data.dec(_f$incompleteSections),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      lastUpdatedAt: data.dec(_f$lastUpdatedAt),
      updatedInfos: data.dec(_f$updatedInfos),
      rating: data.dec(_f$rating),
      rateCount: data.dec(_f$rateCount),
      contractsRatedUids: data.dec(_f$contractsRatedUids),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EnsembleEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnsembleEntity>(map);
  }

  static EnsembleEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EnsembleEntity>(json);
  }
}

mixin EnsembleEntityMappable {
  String toJson() {
    return EnsembleEntityMapper.ensureInitialized().encodeJson<EnsembleEntity>(
      this as EnsembleEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return EnsembleEntityMapper.ensureInitialized().encodeMap<EnsembleEntity>(
      this as EnsembleEntity,
    );
  }

  EnsembleEntityCopyWith<EnsembleEntity, EnsembleEntity, EnsembleEntity>
  get copyWith => _EnsembleEntityCopyWithImpl<EnsembleEntity, EnsembleEntity>(
    this as EnsembleEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EnsembleEntityMapper.ensureInitialized().stringifyValue(
      this as EnsembleEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EnsembleEntityMapper.ensureInitialized().equalsValue(
      this as EnsembleEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EnsembleEntityMapper.ensureInitialized().hashValue(
      this as EnsembleEntity,
    );
  }
}

extension EnsembleEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnsembleEntity, $Out> {
  EnsembleEntityCopyWith<$R, EnsembleEntity, $Out> get $asEnsembleEntity =>
      $base.as((v, t, t2) => _EnsembleEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnsembleEntityCopyWith<$R, $In extends EnsembleEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfessionalInfoEntityCopyWith<
    $R,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >?
  get professionalInfo;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get talents;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections;
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>? get updatedInfos;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get contractsRatedUids;
  $R call({
    String? id,
    String? ownerArtistId,
    String? profilePhotoUrl,
    String? ensembleName,
    ProfessionalInfoEntity? professionalInfo,
    String? presentationVideoUrl,
    int? members,
    List<String>? talents,
    String? ensembleType,
    bool? isActive,
    bool? hasIncompleteSections,
    Map<String, List<String>>? incompleteSections,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUpdatedAt,
    Map<String, int>? updatedInfos,
    double? rating,
    int? rateCount,
    List<String>? contractsRatedUids,
  });
  EnsembleEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EnsembleEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnsembleEntity, $Out>
    implements EnsembleEntityCopyWith<$R, EnsembleEntity, $Out> {
  _EnsembleEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnsembleEntity> $mapper =
      EnsembleEntityMapper.ensureInitialized();
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get talents =>
      $value.talents != null
      ? ListCopyWith(
          $value.talents!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(talents: v),
        )
      : null;
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
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>?
  get updatedInfos => $value.updatedInfos != null
      ? MapCopyWith(
          $value.updatedInfos!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(updatedInfos: v),
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
    Object? id = $none,
    String? ownerArtistId,
    Object? profilePhotoUrl = $none,
    Object? ensembleName = $none,
    Object? professionalInfo = $none,
    Object? presentationVideoUrl = $none,
    Object? members = $none,
    Object? talents = $none,
    Object? ensembleType = $none,
    Object? isActive = $none,
    Object? hasIncompleteSections = $none,
    Object? incompleteSections = $none,
    Object? createdAt = $none,
    Object? updatedAt = $none,
    Object? lastUpdatedAt = $none,
    Object? updatedInfos = $none,
    Object? rating = $none,
    Object? rateCount = $none,
    Object? contractsRatedUids = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (ownerArtistId != null) #ownerArtistId: ownerArtistId,
      if (profilePhotoUrl != $none) #profilePhotoUrl: profilePhotoUrl,
      if (ensembleName != $none) #ensembleName: ensembleName,
      if (professionalInfo != $none) #professionalInfo: professionalInfo,
      if (presentationVideoUrl != $none)
        #presentationVideoUrl: presentationVideoUrl,
      if (members != $none) #members: members,
      if (talents != $none) #talents: talents,
      if (ensembleType != $none) #ensembleType: ensembleType,
      if (isActive != $none) #isActive: isActive,
      if (hasIncompleteSections != $none)
        #hasIncompleteSections: hasIncompleteSections,
      if (incompleteSections != $none) #incompleteSections: incompleteSections,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (lastUpdatedAt != $none) #lastUpdatedAt: lastUpdatedAt,
      if (updatedInfos != $none) #updatedInfos: updatedInfos,
      if (rating != $none) #rating: rating,
      if (rateCount != $none) #rateCount: rateCount,
      if (contractsRatedUids != $none) #contractsRatedUids: contractsRatedUids,
    }),
  );
  @override
  EnsembleEntity $make(CopyWithData data) => EnsembleEntity(
    id: data.get(#id, or: $value.id),
    ownerArtistId: data.get(#ownerArtistId, or: $value.ownerArtistId),
    profilePhotoUrl: data.get(#profilePhotoUrl, or: $value.profilePhotoUrl),
    ensembleName: data.get(#ensembleName, or: $value.ensembleName),
    professionalInfo: data.get(#professionalInfo, or: $value.professionalInfo),
    presentationVideoUrl: data.get(
      #presentationVideoUrl,
      or: $value.presentationVideoUrl,
    ),
    members: data.get(#members, or: $value.members),
    talents: data.get(#talents, or: $value.talents),
    ensembleType: data.get(#ensembleType, or: $value.ensembleType),
    isActive: data.get(#isActive, or: $value.isActive),
    hasIncompleteSections: data.get(
      #hasIncompleteSections,
      or: $value.hasIncompleteSections,
    ),
    incompleteSections: data.get(
      #incompleteSections,
      or: $value.incompleteSections,
    ),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    lastUpdatedAt: data.get(#lastUpdatedAt, or: $value.lastUpdatedAt),
    updatedInfos: data.get(#updatedInfos, or: $value.updatedInfos),
    rating: data.get(#rating, or: $value.rating),
    rateCount: data.get(#rateCount, or: $value.rateCount),
    contractsRatedUids: data.get(
      #contractsRatedUids,
      or: $value.contractsRatedUids,
    ),
  );

  @override
  EnsembleEntityCopyWith<$R2, EnsembleEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EnsembleEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

