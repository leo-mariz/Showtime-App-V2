// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'availability_day_entity.dart';

class AvailabilityDayEntityMapper
    extends ClassMapperBase<AvailabilityDayEntity> {
  AvailabilityDayEntityMapper._();

  static AvailabilityDayEntityMapper? _instance;
  static AvailabilityDayEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AvailabilityDayEntityMapper._());
      PatternMetadataMapper.ensureInitialized();
      AddressAvailabilityEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AvailabilityDayEntity';

  static String? _$id(AvailabilityDayEntity v) => v.id;
  static const Field<AvailabilityDayEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static DateTime _$date(AvailabilityDayEntity v) => v.date;
  static const Field<AvailabilityDayEntity, DateTime> _f$date = Field(
    'date',
    _$date,
  );
  static PatternMetadata? _$generatedFrom(AvailabilityDayEntity v) =>
      v.generatedFrom;
  static const Field<AvailabilityDayEntity, PatternMetadata> _f$generatedFrom =
      Field('generatedFrom', _$generatedFrom, opt: true);
  static bool _$isOverridden(AvailabilityDayEntity v) => v.isOverridden;
  static const Field<AvailabilityDayEntity, bool> _f$isOverridden = Field(
    'isOverridden',
    _$isOverridden,
    opt: true,
    def: false,
  );
  static Map<String, dynamic>? _$overrides(AvailabilityDayEntity v) =>
      v.overrides;
  static const Field<AvailabilityDayEntity, Map<String, dynamic>> _f$overrides =
      Field('overrides', _$overrides, opt: true);
  static List<AddressAvailabilityEntity> _$addresses(AvailabilityDayEntity v) =>
      v.addresses;
  static const Field<AvailabilityDayEntity, List<AddressAvailabilityEntity>>
  _f$addresses = Field('addresses', _$addresses);
  static DateTime _$createdAt(AvailabilityDayEntity v) => v.createdAt;
  static const Field<AvailabilityDayEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime? _$updatedAt(AvailabilityDayEntity v) => v.updatedAt;
  static const Field<AvailabilityDayEntity, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<AvailabilityDayEntity> fields = const {
    #id: _f$id,
    #date: _f$date,
    #generatedFrom: _f$generatedFrom,
    #isOverridden: _f$isOverridden,
    #overrides: _f$overrides,
    #addresses: _f$addresses,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static AvailabilityDayEntity _instantiate(DecodingData data) {
    return AvailabilityDayEntity(
      id: data.dec(_f$id),
      date: data.dec(_f$date),
      generatedFrom: data.dec(_f$generatedFrom),
      isOverridden: data.dec(_f$isOverridden),
      overrides: data.dec(_f$overrides),
      addresses: data.dec(_f$addresses),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AvailabilityDayEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AvailabilityDayEntity>(map);
  }

  static AvailabilityDayEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AvailabilityDayEntity>(json);
  }
}

mixin AvailabilityDayEntityMappable {
  String toJson() {
    return AvailabilityDayEntityMapper.ensureInitialized()
        .encodeJson<AvailabilityDayEntity>(this as AvailabilityDayEntity);
  }

  Map<String, dynamic> toMap() {
    return AvailabilityDayEntityMapper.ensureInitialized()
        .encodeMap<AvailabilityDayEntity>(this as AvailabilityDayEntity);
  }

  AvailabilityDayEntityCopyWith<
    AvailabilityDayEntity,
    AvailabilityDayEntity,
    AvailabilityDayEntity
  >
  get copyWith =>
      _AvailabilityDayEntityCopyWithImpl<
        AvailabilityDayEntity,
        AvailabilityDayEntity
      >(this as AvailabilityDayEntity, $identity, $identity);
  @override
  String toString() {
    return AvailabilityDayEntityMapper.ensureInitialized().stringifyValue(
      this as AvailabilityDayEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return AvailabilityDayEntityMapper.ensureInitialized().equalsValue(
      this as AvailabilityDayEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return AvailabilityDayEntityMapper.ensureInitialized().hashValue(
      this as AvailabilityDayEntity,
    );
  }
}

extension AvailabilityDayEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AvailabilityDayEntity, $Out> {
  AvailabilityDayEntityCopyWith<$R, AvailabilityDayEntity, $Out>
  get $asAvailabilityDayEntity => $base.as(
    (v, t, t2) => _AvailabilityDayEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AvailabilityDayEntityCopyWith<
  $R,
  $In extends AvailabilityDayEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>?
  get generatedFrom;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get overrides;
  ListCopyWith<
    $R,
    AddressAvailabilityEntity,
    AddressAvailabilityEntityCopyWith<
      $R,
      AddressAvailabilityEntity,
      AddressAvailabilityEntity
    >
  >
  get addresses;
  $R call({
    String? id,
    DateTime? date,
    PatternMetadata? generatedFrom,
    bool? isOverridden,
    Map<String, dynamic>? overrides,
    List<AddressAvailabilityEntity>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  AvailabilityDayEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AvailabilityDayEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AvailabilityDayEntity, $Out>
    implements AvailabilityDayEntityCopyWith<$R, AvailabilityDayEntity, $Out> {
  _AvailabilityDayEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AvailabilityDayEntity> $mapper =
      AvailabilityDayEntityMapper.ensureInitialized();
  @override
  PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>?
  get generatedFrom =>
      $value.generatedFrom?.copyWith.$chain((v) => call(generatedFrom: v));
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get overrides => $value.overrides != null
      ? MapCopyWith(
          $value.overrides!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(overrides: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    AddressAvailabilityEntity,
    AddressAvailabilityEntityCopyWith<
      $R,
      AddressAvailabilityEntity,
      AddressAvailabilityEntity
    >
  >
  get addresses => ListCopyWith(
    $value.addresses,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(addresses: v),
  );
  @override
  $R call({
    Object? id = $none,
    DateTime? date,
    Object? generatedFrom = $none,
    bool? isOverridden,
    Object? overrides = $none,
    List<AddressAvailabilityEntity>? addresses,
    DateTime? createdAt,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (date != null) #date: date,
      if (generatedFrom != $none) #generatedFrom: generatedFrom,
      if (isOverridden != null) #isOverridden: isOverridden,
      if (overrides != $none) #overrides: overrides,
      if (addresses != null) #addresses: addresses,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  AvailabilityDayEntity $make(CopyWithData data) => AvailabilityDayEntity(
    id: data.get(#id, or: $value.id),
    date: data.get(#date, or: $value.date),
    generatedFrom: data.get(#generatedFrom, or: $value.generatedFrom),
    isOverridden: data.get(#isOverridden, or: $value.isOverridden),
    overrides: data.get(#overrides, or: $value.overrides),
    addresses: data.get(#addresses, or: $value.addresses),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  AvailabilityDayEntityCopyWith<$R2, AvailabilityDayEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AvailabilityDayEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

