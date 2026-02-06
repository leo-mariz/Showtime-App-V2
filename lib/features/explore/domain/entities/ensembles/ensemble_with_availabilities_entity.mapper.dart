// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ensemble_with_availabilities_entity.dart';

class EnsembleWithAvailabilitiesEntityMapper
    extends ClassMapperBase<EnsembleWithAvailabilitiesEntity> {
  EnsembleWithAvailabilitiesEntityMapper._();

  static EnsembleWithAvailabilitiesEntityMapper? _instance;
  static EnsembleWithAvailabilitiesEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = EnsembleWithAvailabilitiesEntityMapper._(),
      );
      EnsembleEntityMapper.ensureInitialized();
      AvailabilityDayEntityMapper.ensureInitialized();
      ArtistEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EnsembleWithAvailabilitiesEntity';

  static EnsembleEntity _$ensemble(EnsembleWithAvailabilitiesEntity v) =>
      v.ensemble;
  static const Field<EnsembleWithAvailabilitiesEntity, EnsembleEntity>
  _f$ensemble = Field('ensemble', _$ensemble);
  static List<AvailabilityDayEntity> _$availabilities(
    EnsembleWithAvailabilitiesEntity v,
  ) => v.availabilities;
  static const Field<
    EnsembleWithAvailabilitiesEntity,
    List<AvailabilityDayEntity>
  >
  _f$availabilities = Field('availabilities', _$availabilities);
  static ArtistEntity? _$ownerArtist(EnsembleWithAvailabilitiesEntity v) =>
      v.ownerArtist;
  static const Field<EnsembleWithAvailabilitiesEntity, ArtistEntity>
  _f$ownerArtist = Field('ownerArtist', _$ownerArtist, opt: true);

  @override
  final MappableFields<EnsembleWithAvailabilitiesEntity> fields = const {
    #ensemble: _f$ensemble,
    #availabilities: _f$availabilities,
    #ownerArtist: _f$ownerArtist,
  };

  static EnsembleWithAvailabilitiesEntity _instantiate(DecodingData data) {
    return EnsembleWithAvailabilitiesEntity(
      ensemble: data.dec(_f$ensemble),
      availabilities: data.dec(_f$availabilities),
      ownerArtist: data.dec(_f$ownerArtist),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EnsembleWithAvailabilitiesEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnsembleWithAvailabilitiesEntity>(map);
  }

  static EnsembleWithAvailabilitiesEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EnsembleWithAvailabilitiesEntity>(
      json,
    );
  }
}

mixin EnsembleWithAvailabilitiesEntityMappable {
  String toJson() {
    return EnsembleWithAvailabilitiesEntityMapper.ensureInitialized()
        .encodeJson<EnsembleWithAvailabilitiesEntity>(
          this as EnsembleWithAvailabilitiesEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return EnsembleWithAvailabilitiesEntityMapper.ensureInitialized()
        .encodeMap<EnsembleWithAvailabilitiesEntity>(
          this as EnsembleWithAvailabilitiesEntity,
        );
  }

  EnsembleWithAvailabilitiesEntityCopyWith<
    EnsembleWithAvailabilitiesEntity,
    EnsembleWithAvailabilitiesEntity,
    EnsembleWithAvailabilitiesEntity
  >
  get copyWith =>
      _EnsembleWithAvailabilitiesEntityCopyWithImpl<
        EnsembleWithAvailabilitiesEntity,
        EnsembleWithAvailabilitiesEntity
      >(this as EnsembleWithAvailabilitiesEntity, $identity, $identity);
  @override
  String toString() {
    return EnsembleWithAvailabilitiesEntityMapper.ensureInitialized()
        .stringifyValue(this as EnsembleWithAvailabilitiesEntity);
  }

  @override
  bool operator ==(Object other) {
    return EnsembleWithAvailabilitiesEntityMapper.ensureInitialized()
        .equalsValue(this as EnsembleWithAvailabilitiesEntity, other);
  }

  @override
  int get hashCode {
    return EnsembleWithAvailabilitiesEntityMapper.ensureInitialized().hashValue(
      this as EnsembleWithAvailabilitiesEntity,
    );
  }
}

extension EnsembleWithAvailabilitiesEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnsembleWithAvailabilitiesEntity, $Out> {
  EnsembleWithAvailabilitiesEntityCopyWith<
    $R,
    EnsembleWithAvailabilitiesEntity,
    $Out
  >
  get $asEnsembleWithAvailabilitiesEntity => $base.as(
    (v, t, t2) =>
        _EnsembleWithAvailabilitiesEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EnsembleWithAvailabilitiesEntityCopyWith<
  $R,
  $In extends EnsembleWithAvailabilitiesEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  EnsembleEntityCopyWith<$R, EnsembleEntity, EnsembleEntity> get ensemble;
  ListCopyWith<
    $R,
    AvailabilityDayEntity,
    AvailabilityDayEntityCopyWith<
      $R,
      AvailabilityDayEntity,
      AvailabilityDayEntity
    >
  >
  get availabilities;
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity>? get ownerArtist;
  $R call({
    EnsembleEntity? ensemble,
    List<AvailabilityDayEntity>? availabilities,
    ArtistEntity? ownerArtist,
  });
  EnsembleWithAvailabilitiesEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EnsembleWithAvailabilitiesEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnsembleWithAvailabilitiesEntity, $Out>
    implements
        EnsembleWithAvailabilitiesEntityCopyWith<
          $R,
          EnsembleWithAvailabilitiesEntity,
          $Out
        > {
  _EnsembleWithAvailabilitiesEntityCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<EnsembleWithAvailabilitiesEntity> $mapper =
      EnsembleWithAvailabilitiesEntityMapper.ensureInitialized();
  @override
  EnsembleEntityCopyWith<$R, EnsembleEntity, EnsembleEntity> get ensemble =>
      $value.ensemble.copyWith.$chain((v) => call(ensemble: v));
  @override
  ListCopyWith<
    $R,
    AvailabilityDayEntity,
    AvailabilityDayEntityCopyWith<
      $R,
      AvailabilityDayEntity,
      AvailabilityDayEntity
    >
  >
  get availabilities => ListCopyWith(
    $value.availabilities,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(availabilities: v),
  );
  @override
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity>? get ownerArtist =>
      $value.ownerArtist?.copyWith.$chain((v) => call(ownerArtist: v));
  @override
  $R call({
    EnsembleEntity? ensemble,
    List<AvailabilityDayEntity>? availabilities,
    Object? ownerArtist = $none,
  }) => $apply(
    FieldCopyWithData({
      if (ensemble != null) #ensemble: ensemble,
      if (availabilities != null) #availabilities: availabilities,
      if (ownerArtist != $none) #ownerArtist: ownerArtist,
    }),
  );
  @override
  EnsembleWithAvailabilitiesEntity $make(CopyWithData data) =>
      EnsembleWithAvailabilitiesEntity(
        ensemble: data.get(#ensemble, or: $value.ensemble),
        availabilities: data.get(#availabilities, or: $value.availabilities),
        ownerArtist: data.get(#ownerArtist, or: $value.ownerArtist),
      );

  @override
  EnsembleWithAvailabilitiesEntityCopyWith<
    $R2,
    EnsembleWithAvailabilitiesEntity,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EnsembleWithAvailabilitiesEntityCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

