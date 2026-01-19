// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'address_availability_entity.dart';

class AddressAvailabilityEntityMapper
    extends ClassMapperBase<AddressAvailabilityEntity> {
  AddressAvailabilityEntityMapper._();

  static AddressAvailabilityEntityMapper? _instance;
  static AddressAvailabilityEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = AddressAvailabilityEntityMapper._(),
      );
      AddressInfoEntityMapper.ensureInitialized();
      TimeSlotMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AddressAvailabilityEntity';

  static String _$addressId(AddressAvailabilityEntity v) => v.addressId;
  static const Field<AddressAvailabilityEntity, String> _f$addressId = Field(
    'addressId',
    _$addressId,
  );
  static double _$raioAtuacao(AddressAvailabilityEntity v) => v.raioAtuacao;
  static const Field<AddressAvailabilityEntity, double> _f$raioAtuacao = Field(
    'raioAtuacao',
    _$raioAtuacao,
  );
  static AddressInfoEntity _$endereco(AddressAvailabilityEntity v) =>
      v.endereco;
  static const Field<AddressAvailabilityEntity, AddressInfoEntity> _f$endereco =
      Field('endereco', _$endereco);
  static List<TimeSlot> _$slots(AddressAvailabilityEntity v) => v.slots;
  static const Field<AddressAvailabilityEntity, List<TimeSlot>> _f$slots =
      Field('slots', _$slots);

  @override
  final MappableFields<AddressAvailabilityEntity> fields = const {
    #addressId: _f$addressId,
    #raioAtuacao: _f$raioAtuacao,
    #endereco: _f$endereco,
    #slots: _f$slots,
  };

  static AddressAvailabilityEntity _instantiate(DecodingData data) {
    return AddressAvailabilityEntity(
      addressId: data.dec(_f$addressId),
      raioAtuacao: data.dec(_f$raioAtuacao),
      endereco: data.dec(_f$endereco),
      slots: data.dec(_f$slots),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddressAvailabilityEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddressAvailabilityEntity>(map);
  }

  static AddressAvailabilityEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AddressAvailabilityEntity>(json);
  }
}

mixin AddressAvailabilityEntityMappable {
  String toJson() {
    return AddressAvailabilityEntityMapper.ensureInitialized()
        .encodeJson<AddressAvailabilityEntity>(
          this as AddressAvailabilityEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return AddressAvailabilityEntityMapper.ensureInitialized()
        .encodeMap<AddressAvailabilityEntity>(
          this as AddressAvailabilityEntity,
        );
  }

  AddressAvailabilityEntityCopyWith<
    AddressAvailabilityEntity,
    AddressAvailabilityEntity,
    AddressAvailabilityEntity
  >
  get copyWith =>
      _AddressAvailabilityEntityCopyWithImpl<
        AddressAvailabilityEntity,
        AddressAvailabilityEntity
      >(this as AddressAvailabilityEntity, $identity, $identity);
  @override
  String toString() {
    return AddressAvailabilityEntityMapper.ensureInitialized().stringifyValue(
      this as AddressAvailabilityEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddressAvailabilityEntityMapper.ensureInitialized().equalsValue(
      this as AddressAvailabilityEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return AddressAvailabilityEntityMapper.ensureInitialized().hashValue(
      this as AddressAvailabilityEntity,
    );
  }
}

extension AddressAvailabilityEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddressAvailabilityEntity, $Out> {
  AddressAvailabilityEntityCopyWith<$R, AddressAvailabilityEntity, $Out>
  get $asAddressAvailabilityEntity => $base.as(
    (v, t, t2) => _AddressAvailabilityEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AddressAvailabilityEntityCopyWith<
  $R,
  $In extends AddressAvailabilityEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco;
  ListCopyWith<$R, TimeSlot, TimeSlotCopyWith<$R, TimeSlot, TimeSlot>>
  get slots;
  $R call({
    String? addressId,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    List<TimeSlot>? slots,
  });
  AddressAvailabilityEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AddressAvailabilityEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddressAvailabilityEntity, $Out>
    implements
        AddressAvailabilityEntityCopyWith<$R, AddressAvailabilityEntity, $Out> {
  _AddressAvailabilityEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddressAvailabilityEntity> $mapper =
      AddressAvailabilityEntityMapper.ensureInitialized();
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
    String? addressId,
    double? raioAtuacao,
    AddressInfoEntity? endereco,
    List<TimeSlot>? slots,
  }) => $apply(
    FieldCopyWithData({
      if (addressId != null) #addressId: addressId,
      if (raioAtuacao != null) #raioAtuacao: raioAtuacao,
      if (endereco != null) #endereco: endereco,
      if (slots != null) #slots: slots,
    }),
  );
  @override
  AddressAvailabilityEntity $make(CopyWithData data) =>
      AddressAvailabilityEntity(
        addressId: data.get(#addressId, or: $value.addressId),
        raioAtuacao: data.get(#raioAtuacao, or: $value.raioAtuacao),
        endereco: data.get(#endereco, or: $value.endereco),
        slots: data.get(#slots, or: $value.slots),
      );

  @override
  AddressAvailabilityEntityCopyWith<$R2, AddressAvailabilityEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddressAvailabilityEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

