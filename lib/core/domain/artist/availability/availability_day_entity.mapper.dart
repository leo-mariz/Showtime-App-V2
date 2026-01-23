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
      TimeSlotMapper.ensureInitialized();
      AddressInfoEntityMapper.ensureInitialized();
      PatternMetadataMapper.ensureInitialized();
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
  static List<TimeSlot> _$slots(AvailabilityDayEntity v) => v.slots;
  static const Field<AvailabilityDayEntity, List<TimeSlot>> _f$slots = Field(
    'slots',
    _$slots,
  );
  static double _$raioAtuacao(AvailabilityDayEntity v) => v.raioAtuacao;
  static const Field<AvailabilityDayEntity, double> _f$raioAtuacao = Field(
    'raioAtuacao',
    _$raioAtuacao,
  );
  static AddressInfoEntity _$endereco(AvailabilityDayEntity v) => v.endereco;
  static const Field<AvailabilityDayEntity, AddressInfoEntity> _f$endereco =
      Field('endereco', _$endereco);
  static bool _$isManualOverride(AvailabilityDayEntity v) => v.isManualOverride;
  static const Field<AvailabilityDayEntity, bool> _f$isManualOverride = Field(
    'isManualOverride',
    _$isManualOverride,
  );
  static DateTime? _$createdAt(AvailabilityDayEntity v) => v.createdAt;
  static const Field<AvailabilityDayEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
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
  static List<PatternMetadata>? _$patternMetadata(AvailabilityDayEntity v) =>
      v.patternMetadata;
  static const Field<AvailabilityDayEntity, List<PatternMetadata>>
  _f$patternMetadata = Field('patternMetadata', _$patternMetadata, opt: true);

  @override
  final MappableFields<AvailabilityDayEntity> fields = const {
    #id: _f$id,
    #date: _f$date,
    #slots: _f$slots,
    #raioAtuacao: _f$raioAtuacao,
    #endereco: _f$endereco,
    #isManualOverride: _f$isManualOverride,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #isActive: _f$isActive,
    #patternMetadata: _f$patternMetadata,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static AvailabilityDayEntity _instantiate(DecodingData data) {
    return AvailabilityDayEntity(
      id: data.dec(_f$id),
      date: data.dec(_f$date),
      slots: data.dec(_f$slots),
      raioAtuacao: data.dec(_f$raioAtuacao),
      endereco: data.dec(_f$endereco),
      isManualOverride: data.dec(_f$isManualOverride),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      isActive: data.dec(_f$isActive),
      patternMetadata: data.dec(_f$patternMetadata),
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
  ListCopyWith<$R, TimeSlot, TimeSlotCopyWith<$R, TimeSlot, TimeSlot>>
  get slots;
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco;
  ListCopyWith<
    $R,
    PatternMetadata,
    PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>
  >?
  get patternMetadata;
  $R call({
    String? id,
    DateTime? date,
    List<TimeSlot>? slots,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    bool? isManualOverride,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<PatternMetadata>? patternMetadata,
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
  ListCopyWith<$R, TimeSlot, TimeSlotCopyWith<$R, TimeSlot, TimeSlot>>
  get slots => ListCopyWith(
    $value.slots,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(slots: v),
  );
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco => $value.endereco.copyWith.$chain((v) => call(endereco: v));
  @override
  ListCopyWith<
    $R,
    PatternMetadata,
    PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>
  >?
  get patternMetadata => $value.patternMetadata != null
      ? ListCopyWith(
          $value.patternMetadata!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(patternMetadata: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    DateTime? date,
    List<TimeSlot>? slots,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    bool? isManualOverride,
    Object? createdAt = $none,
    Object? updatedAt = $none,
    bool? isActive,
    Object? patternMetadata = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (date != null) #date: date,
      if (slots != null) #slots: slots,
      if (raioAtuacao != null) #raioAtuacao: raioAtuacao,
      if (endereco != null) #endereco: endereco,
      if (isManualOverride != null) #isManualOverride: isManualOverride,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (isActive != null) #isActive: isActive,
      if (patternMetadata != $none) #patternMetadata: patternMetadata,
    }),
  );
  @override
  AvailabilityDayEntity $make(CopyWithData data) => AvailabilityDayEntity(
    id: data.get(#id, or: $value.id),
    date: data.get(#date, or: $value.date),
    slots: data.get(#slots, or: $value.slots),
    raioAtuacao: data.get(#raioAtuacao, or: $value.raioAtuacao),
    endereco: data.get(#endereco, or: $value.endereco),
    isManualOverride: data.get(#isManualOverride, or: $value.isManualOverride),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    isActive: data.get(#isActive, or: $value.isActive),
    patternMetadata: data.get(#patternMetadata, or: $value.patternMetadata),
  );

  @override
  AvailabilityDayEntityCopyWith<$R2, AvailabilityDayEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AvailabilityDayEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

