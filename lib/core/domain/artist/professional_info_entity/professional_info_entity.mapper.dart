// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'professional_info_entity.dart';

class ProfessionalInfoEntityMapper
    extends ClassMapperBase<ProfessionalInfoEntity> {
  ProfessionalInfoEntityMapper._();

  static ProfessionalInfoEntityMapper? _instance;
  static ProfessionalInfoEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProfessionalInfoEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProfessionalInfoEntity';

  static List<String>? _$specialty(ProfessionalInfoEntity v) => v.specialty;
  static const Field<ProfessionalInfoEntity, List<String>> _f$specialty = Field(
    'specialty',
    _$specialty,
    opt: true,
  );
  static List<String>? _$genrePreferences(ProfessionalInfoEntity v) =>
      v.genrePreferences;
  static const Field<ProfessionalInfoEntity, List<String>> _f$genrePreferences =
      Field('genrePreferences', _$genrePreferences, opt: true);
  static int? _$minimumShowDuration(ProfessionalInfoEntity v) =>
      v.minimumShowDuration;
  static const Field<ProfessionalInfoEntity, int> _f$minimumShowDuration =
      Field('minimumShowDuration', _$minimumShowDuration, opt: true);
  static int? _$preparationTime(ProfessionalInfoEntity v) => v.preparationTime;
  static const Field<ProfessionalInfoEntity, int> _f$preparationTime = Field(
    'preparationTime',
    _$preparationTime,
    opt: true,
  );
  static int? _$requestMinimumEarliness(ProfessionalInfoEntity v) =>
      v.requestMinimumEarliness;
  static const Field<ProfessionalInfoEntity, int> _f$requestMinimumEarliness =
      Field('requestMinimumEarliness', _$requestMinimumEarliness, opt: true);
  static String? _$bio(ProfessionalInfoEntity v) => v.bio;
  static const Field<ProfessionalInfoEntity, String> _f$bio = Field(
    'bio',
    _$bio,
    opt: true,
  );
  static double? _$hourlyRate(ProfessionalInfoEntity v) => v.hourlyRate;
  static const Field<ProfessionalInfoEntity, double> _f$hourlyRate = Field(
    'hourlyRate',
    _$hourlyRate,
    opt: true,
  );

  @override
  final MappableFields<ProfessionalInfoEntity> fields = const {
    #specialty: _f$specialty,
    #genrePreferences: _f$genrePreferences,
    #minimumShowDuration: _f$minimumShowDuration,
    #preparationTime: _f$preparationTime,
    #requestMinimumEarliness: _f$requestMinimumEarliness,
    #bio: _f$bio,
    #hourlyRate: _f$hourlyRate,
  };

  static ProfessionalInfoEntity _instantiate(DecodingData data) {
    return ProfessionalInfoEntity(
      specialty: data.dec(_f$specialty),
      genrePreferences: data.dec(_f$genrePreferences),
      minimumShowDuration: data.dec(_f$minimumShowDuration),
      preparationTime: data.dec(_f$preparationTime),
      requestMinimumEarliness: data.dec(_f$requestMinimumEarliness),
      bio: data.dec(_f$bio),
      hourlyRate: data.dec(_f$hourlyRate),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProfessionalInfoEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProfessionalInfoEntity>(map);
  }

  static ProfessionalInfoEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ProfessionalInfoEntity>(json);
  }
}

mixin ProfessionalInfoEntityMappable {
  String toJson() {
    return ProfessionalInfoEntityMapper.ensureInitialized()
        .encodeJson<ProfessionalInfoEntity>(this as ProfessionalInfoEntity);
  }

  Map<String, dynamic> toMap() {
    return ProfessionalInfoEntityMapper.ensureInitialized()
        .encodeMap<ProfessionalInfoEntity>(this as ProfessionalInfoEntity);
  }

  ProfessionalInfoEntityCopyWith<
    ProfessionalInfoEntity,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >
  get copyWith =>
      _ProfessionalInfoEntityCopyWithImpl<
        ProfessionalInfoEntity,
        ProfessionalInfoEntity
      >(this as ProfessionalInfoEntity, $identity, $identity);
  @override
  String toString() {
    return ProfessionalInfoEntityMapper.ensureInitialized().stringifyValue(
      this as ProfessionalInfoEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProfessionalInfoEntityMapper.ensureInitialized().equalsValue(
      this as ProfessionalInfoEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ProfessionalInfoEntityMapper.ensureInitialized().hashValue(
      this as ProfessionalInfoEntity,
    );
  }
}

extension ProfessionalInfoEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProfessionalInfoEntity, $Out> {
  ProfessionalInfoEntityCopyWith<$R, ProfessionalInfoEntity, $Out>
  get $asProfessionalInfoEntity => $base.as(
    (v, t, t2) => _ProfessionalInfoEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProfessionalInfoEntityCopyWith<
  $R,
  $In extends ProfessionalInfoEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get specialty;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get genrePreferences;
  $R call({
    List<String>? specialty,
    List<String>? genrePreferences,
    int? minimumShowDuration,
    int? preparationTime,
    int? requestMinimumEarliness,
    String? bio,
    double? hourlyRate,
  });
  ProfessionalInfoEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProfessionalInfoEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProfessionalInfoEntity, $Out>
    implements
        ProfessionalInfoEntityCopyWith<$R, ProfessionalInfoEntity, $Out> {
  _ProfessionalInfoEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProfessionalInfoEntity> $mapper =
      ProfessionalInfoEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get specialty =>
      $value.specialty != null
      ? ListCopyWith(
          $value.specialty!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(specialty: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get genrePreferences => $value.genrePreferences != null
      ? ListCopyWith(
          $value.genrePreferences!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(genrePreferences: v),
        )
      : null;
  @override
  $R call({
    Object? specialty = $none,
    Object? genrePreferences = $none,
    Object? minimumShowDuration = $none,
    Object? preparationTime = $none,
    Object? requestMinimumEarliness = $none,
    Object? bio = $none,
    Object? hourlyRate = $none,
  }) => $apply(
    FieldCopyWithData({
      if (specialty != $none) #specialty: specialty,
      if (genrePreferences != $none) #genrePreferences: genrePreferences,
      if (minimumShowDuration != $none)
        #minimumShowDuration: minimumShowDuration,
      if (preparationTime != $none) #preparationTime: preparationTime,
      if (requestMinimumEarliness != $none)
        #requestMinimumEarliness: requestMinimumEarliness,
      if (bio != $none) #bio: bio,
      if (hourlyRate != $none) #hourlyRate: hourlyRate,
    }),
  );
  @override
  ProfessionalInfoEntity $make(CopyWithData data) => ProfessionalInfoEntity(
    specialty: data.get(#specialty, or: $value.specialty),
    genrePreferences: data.get(#genrePreferences, or: $value.genrePreferences),
    minimumShowDuration: data.get(
      #minimumShowDuration,
      or: $value.minimumShowDuration,
    ),
    preparationTime: data.get(#preparationTime, or: $value.preparationTime),
    requestMinimumEarliness: data.get(
      #requestMinimumEarliness,
      or: $value.requestMinimumEarliness,
    ),
    bio: data.get(#bio, or: $value.bio),
    hourlyRate: data.get(#hourlyRate, or: $value.hourlyRate),
  );

  @override
  ProfessionalInfoEntityCopyWith<$R2, ProfessionalInfoEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProfessionalInfoEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

