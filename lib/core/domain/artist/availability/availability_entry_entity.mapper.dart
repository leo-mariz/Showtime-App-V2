// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'availability_entry_entity.dart';

class AvailabilityEntryMapper extends ClassMapperBase<AvailabilityEntry> {
  AvailabilityEntryMapper._();

  static AvailabilityEntryMapper? _instance;
  static AvailabilityEntryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AvailabilityEntryMapper._());
      PatternMetadataMapper.ensureInitialized();
      AddressInfoEntityMapper.ensureInitialized();
      TimeSlotMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AvailabilityEntry';

  static String _$availabilityId(AvailabilityEntry v) => v.availabilityId;
  static const Field<AvailabilityEntry, String> _f$availabilityId = Field(
    'availabilityId',
    _$availabilityId,
  );
  static PatternMetadata? _$generatedFrom(AvailabilityEntry v) =>
      v.generatedFrom;
  static const Field<AvailabilityEntry, PatternMetadata> _f$generatedFrom =
      Field('generatedFrom', _$generatedFrom, opt: true);
  static String _$addressId(AvailabilityEntry v) => v.addressId;
  static const Field<AvailabilityEntry, String> _f$addressId = Field(
    'addressId',
    _$addressId,
  );
  static double _$raioAtuacao(AvailabilityEntry v) => v.raioAtuacao;
  static const Field<AvailabilityEntry, double> _f$raioAtuacao = Field(
    'raioAtuacao',
    _$raioAtuacao,
  );
  static AddressInfoEntity _$endereco(AvailabilityEntry v) => v.endereco;
  static const Field<AvailabilityEntry, AddressInfoEntity> _f$endereco = Field(
    'endereco',
    _$endereco,
  );
  static List<TimeSlot> _$slots(AvailabilityEntry v) => v.slots;
  static const Field<AvailabilityEntry, List<TimeSlot>> _f$slots = Field(
    'slots',
    _$slots,
  );
  static bool _$isManualOverride(AvailabilityEntry v) => v.isManualOverride;
  static const Field<AvailabilityEntry, bool> _f$isManualOverride = Field(
    'isManualOverride',
    _$isManualOverride,
    opt: true,
    def: false,
  );
  static DateTime _$createdAt(AvailabilityEntry v) => v.createdAt;
  static const Field<AvailabilityEntry, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime? _$updatedAt(AvailabilityEntry v) => v.updatedAt;
  static const Field<AvailabilityEntry, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<AvailabilityEntry> fields = const {
    #availabilityId: _f$availabilityId,
    #generatedFrom: _f$generatedFrom,
    #addressId: _f$addressId,
    #raioAtuacao: _f$raioAtuacao,
    #endereco: _f$endereco,
    #slots: _f$slots,
    #isManualOverride: _f$isManualOverride,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static AvailabilityEntry _instantiate(DecodingData data) {
    return AvailabilityEntry(
      availabilityId: data.dec(_f$availabilityId),
      generatedFrom: data.dec(_f$generatedFrom),
      addressId: data.dec(_f$addressId),
      raioAtuacao: data.dec(_f$raioAtuacao),
      endereco: data.dec(_f$endereco),
      slots: data.dec(_f$slots),
      isManualOverride: data.dec(_f$isManualOverride),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AvailabilityEntry fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AvailabilityEntry>(map);
  }

  static AvailabilityEntry fromJson(String json) {
    return ensureInitialized().decodeJson<AvailabilityEntry>(json);
  }
}

mixin AvailabilityEntryMappable {
  String toJson() {
    return AvailabilityEntryMapper.ensureInitialized()
        .encodeJson<AvailabilityEntry>(this as AvailabilityEntry);
  }

  Map<String, dynamic> toMap() {
    return AvailabilityEntryMapper.ensureInitialized()
        .encodeMap<AvailabilityEntry>(this as AvailabilityEntry);
  }

  AvailabilityEntryCopyWith<
    AvailabilityEntry,
    AvailabilityEntry,
    AvailabilityEntry
  >
  get copyWith =>
      _AvailabilityEntryCopyWithImpl<AvailabilityEntry, AvailabilityEntry>(
        this as AvailabilityEntry,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AvailabilityEntryMapper.ensureInitialized().stringifyValue(
      this as AvailabilityEntry,
    );
  }

  @override
  bool operator ==(Object other) {
    return AvailabilityEntryMapper.ensureInitialized().equalsValue(
      this as AvailabilityEntry,
      other,
    );
  }

  @override
  int get hashCode {
    return AvailabilityEntryMapper.ensureInitialized().hashValue(
      this as AvailabilityEntry,
    );
  }
}

extension AvailabilityEntryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AvailabilityEntry, $Out> {
  AvailabilityEntryCopyWith<$R, AvailabilityEntry, $Out>
  get $asAvailabilityEntry => $base.as(
    (v, t, t2) => _AvailabilityEntryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AvailabilityEntryCopyWith<
  $R,
  $In extends AvailabilityEntry,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>?
  get generatedFrom;
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco;
  ListCopyWith<$R, TimeSlot, TimeSlotCopyWith<$R, TimeSlot, TimeSlot>>
  get slots;
  $R call({
    String? availabilityId,
    PatternMetadata? generatedFrom,
    String? addressId,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    List<TimeSlot>? slots,
    bool? isManualOverride,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  AvailabilityEntryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AvailabilityEntryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AvailabilityEntry, $Out>
    implements AvailabilityEntryCopyWith<$R, AvailabilityEntry, $Out> {
  _AvailabilityEntryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AvailabilityEntry> $mapper =
      AvailabilityEntryMapper.ensureInitialized();
  @override
  PatternMetadataCopyWith<$R, PatternMetadata, PatternMetadata>?
  get generatedFrom =>
      $value.generatedFrom?.copyWith.$chain((v) => call(generatedFrom: v));
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco => $value.endereco.copyWith.$chain((v) => call(endereco: v));
  @override
  ListCopyWith<$R, TimeSlot, TimeSlotCopyWith<$R, TimeSlot, TimeSlot>>
  get slots => ListCopyWith(
    $value.slots,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(slots: v),
  );
  @override
  $R call({
    String? availabilityId,
    Object? generatedFrom = $none,
    String? addressId,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    List<TimeSlot>? slots,
    bool? isManualOverride,
    DateTime? createdAt,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (availabilityId != null) #availabilityId: availabilityId,
      if (generatedFrom != $none) #generatedFrom: generatedFrom,
      if (addressId != null) #addressId: addressId,
      if (raioAtuacao != null) #raioAtuacao: raioAtuacao,
      if (endereco != null) #endereco: endereco,
      if (slots != null) #slots: slots,
      if (isManualOverride != null) #isManualOverride: isManualOverride,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  AvailabilityEntry $make(CopyWithData data) => AvailabilityEntry(
    availabilityId: data.get(#availabilityId, or: $value.availabilityId),
    generatedFrom: data.get(#generatedFrom, or: $value.generatedFrom),
    addressId: data.get(#addressId, or: $value.addressId),
    raioAtuacao: data.get(#raioAtuacao, or: $value.raioAtuacao),
    endereco: data.get(#endereco, or: $value.endereco),
    slots: data.get(#slots, or: $value.slots),
    isManualOverride: data.get(#isManualOverride, or: $value.isManualOverride),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  AvailabilityEntryCopyWith<$R2, AvailabilityEntry, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AvailabilityEntryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

