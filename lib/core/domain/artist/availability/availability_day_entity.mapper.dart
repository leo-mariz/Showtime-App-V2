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
      AvailabilityEntryMapper.ensureInitialized();
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
  static List<AvailabilityEntry> _$availabilities(AvailabilityDayEntity v) =>
      v.availabilities;
  static const Field<AvailabilityDayEntity, List<AvailabilityEntry>>
  _f$availabilities = Field('availabilities', _$availabilities);
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
  static bool _$isActive(AvailabilityDayEntity v) => v.isActive;
  static const Field<AvailabilityDayEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<AvailabilityDayEntity> fields = const {
    #id: _f$id,
    #date: _f$date,
    #availabilities: _f$availabilities,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #isActive: _f$isActive,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static AvailabilityDayEntity _instantiate(DecodingData data) {
    return AvailabilityDayEntity(
      id: data.dec(_f$id),
      date: data.dec(_f$date),
      availabilities: data.dec(_f$availabilities),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      isActive: data.dec(_f$isActive),
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
  ListCopyWith<
    $R,
    AvailabilityEntry,
    AvailabilityEntryCopyWith<$R, AvailabilityEntry, AvailabilityEntry>
  >
  get availabilities;
  $R call({
    String? id,
    DateTime? date,
    List<AvailabilityEntry>? availabilities,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
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
  ListCopyWith<
    $R,
    AvailabilityEntry,
    AvailabilityEntryCopyWith<$R, AvailabilityEntry, AvailabilityEntry>
  >
  get availabilities => ListCopyWith(
    $value.availabilities,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(availabilities: v),
  );
  @override
  $R call({
    Object? id = $none,
    DateTime? date,
    List<AvailabilityEntry>? availabilities,
    DateTime? createdAt,
    Object? updatedAt = $none,
    bool? isActive,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (date != null) #date: date,
      if (availabilities != null) #availabilities: availabilities,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (isActive != null) #isActive: isActive,
    }),
  );
  @override
  AvailabilityDayEntity $make(CopyWithData data) => AvailabilityDayEntity(
    id: data.get(#id, or: $value.id),
    date: data.get(#date, or: $value.date),
    availabilities: data.get(#availabilities, or: $value.availabilities),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    isActive: data.get(#isActive, or: $value.isActive),
  );

  @override
  AvailabilityDayEntityCopyWith<$R2, AvailabilityDayEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AvailabilityDayEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

