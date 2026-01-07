// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'artist_with_availabilities_entity.dart';

class ArtistWithAvailabilitiesEntityMapper
    extends ClassMapperBase<ArtistWithAvailabilitiesEntity> {
  ArtistWithAvailabilitiesEntityMapper._();

  static ArtistWithAvailabilitiesEntityMapper? _instance;
  static ArtistWithAvailabilitiesEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ArtistWithAvailabilitiesEntityMapper._(),
      );
      ArtistEntityMapper.ensureInitialized();
      AvailabilityEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ArtistWithAvailabilitiesEntity';

  static ArtistEntity _$artist(ArtistWithAvailabilitiesEntity v) => v.artist;
  static const Field<ArtistWithAvailabilitiesEntity, ArtistEntity> _f$artist =
      Field('artist', _$artist);
  static List<AvailabilityEntity> _$availabilities(
    ArtistWithAvailabilitiesEntity v,
  ) => v.availabilities;
  static const Field<ArtistWithAvailabilitiesEntity, List<AvailabilityEntity>>
  _f$availabilities = Field('availabilities', _$availabilities);

  @override
  final MappableFields<ArtistWithAvailabilitiesEntity> fields = const {
    #artist: _f$artist,
    #availabilities: _f$availabilities,
  };

  static ArtistWithAvailabilitiesEntity _instantiate(DecodingData data) {
    return ArtistWithAvailabilitiesEntity(
      artist: data.dec(_f$artist),
      availabilities: data.dec(_f$availabilities),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ArtistWithAvailabilitiesEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ArtistWithAvailabilitiesEntity>(map);
  }

  static ArtistWithAvailabilitiesEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ArtistWithAvailabilitiesEntity>(json);
  }
}

mixin ArtistWithAvailabilitiesEntityMappable {
  String toJson() {
    return ArtistWithAvailabilitiesEntityMapper.ensureInitialized()
        .encodeJson<ArtistWithAvailabilitiesEntity>(
          this as ArtistWithAvailabilitiesEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return ArtistWithAvailabilitiesEntityMapper.ensureInitialized()
        .encodeMap<ArtistWithAvailabilitiesEntity>(
          this as ArtistWithAvailabilitiesEntity,
        );
  }

  ArtistWithAvailabilitiesEntityCopyWith<
    ArtistWithAvailabilitiesEntity,
    ArtistWithAvailabilitiesEntity,
    ArtistWithAvailabilitiesEntity
  >
  get copyWith =>
      _ArtistWithAvailabilitiesEntityCopyWithImpl<
        ArtistWithAvailabilitiesEntity,
        ArtistWithAvailabilitiesEntity
      >(this as ArtistWithAvailabilitiesEntity, $identity, $identity);
  @override
  String toString() {
    return ArtistWithAvailabilitiesEntityMapper.ensureInitialized()
        .stringifyValue(this as ArtistWithAvailabilitiesEntity);
  }

  @override
  bool operator ==(Object other) {
    return ArtistWithAvailabilitiesEntityMapper.ensureInitialized().equalsValue(
      this as ArtistWithAvailabilitiesEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ArtistWithAvailabilitiesEntityMapper.ensureInitialized().hashValue(
      this as ArtistWithAvailabilitiesEntity,
    );
  }
}

extension ArtistWithAvailabilitiesEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ArtistWithAvailabilitiesEntity, $Out> {
  ArtistWithAvailabilitiesEntityCopyWith<
    $R,
    ArtistWithAvailabilitiesEntity,
    $Out
  >
  get $asArtistWithAvailabilitiesEntity => $base.as(
    (v, t, t2) =>
        _ArtistWithAvailabilitiesEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ArtistWithAvailabilitiesEntityCopyWith<
  $R,
  $In extends ArtistWithAvailabilitiesEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity> get artist;
  ListCopyWith<
    $R,
    AvailabilityEntity,
    AvailabilityEntityCopyWith<$R, AvailabilityEntity, AvailabilityEntity>
  >
  get availabilities;
  $R call({ArtistEntity? artist, List<AvailabilityEntity>? availabilities});
  ArtistWithAvailabilitiesEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ArtistWithAvailabilitiesEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ArtistWithAvailabilitiesEntity, $Out>
    implements
        ArtistWithAvailabilitiesEntityCopyWith<
          $R,
          ArtistWithAvailabilitiesEntity,
          $Out
        > {
  _ArtistWithAvailabilitiesEntityCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<ArtistWithAvailabilitiesEntity> $mapper =
      ArtistWithAvailabilitiesEntityMapper.ensureInitialized();
  @override
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity> get artist =>
      $value.artist.copyWith.$chain((v) => call(artist: v));
  @override
  ListCopyWith<
    $R,
    AvailabilityEntity,
    AvailabilityEntityCopyWith<$R, AvailabilityEntity, AvailabilityEntity>
  >
  get availabilities => ListCopyWith(
    $value.availabilities,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(availabilities: v),
  );
  @override
  $R call({ArtistEntity? artist, List<AvailabilityEntity>? availabilities}) =>
      $apply(
        FieldCopyWithData({
          if (artist != null) #artist: artist,
          if (availabilities != null) #availabilities: availabilities,
        }),
      );
  @override
  ArtistWithAvailabilitiesEntity $make(CopyWithData data) =>
      ArtistWithAvailabilitiesEntity(
        artist: data.get(#artist, or: $value.artist),
        availabilities: data.get(#availabilities, or: $value.availabilities),
      );

  @override
  ArtistWithAvailabilitiesEntityCopyWith<
    $R2,
    ArtistWithAvailabilitiesEntity,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ArtistWithAvailabilitiesEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

