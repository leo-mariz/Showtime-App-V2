// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'address_info_entity.dart';

class AddressInfoEntityMapper extends ClassMapperBase<AddressInfoEntity> {
  AddressInfoEntityMapper._();

  static AddressInfoEntityMapper? _instance;
  static AddressInfoEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddressInfoEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AddressInfoEntity';

  static String? _$uid(AddressInfoEntity v) => v.uid;
  static const Field<AddressInfoEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String _$title(AddressInfoEntity v) => v.title;
  static const Field<AddressInfoEntity, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
    def: '',
  );
  static String _$zipCode(AddressInfoEntity v) => v.zipCode;
  static const Field<AddressInfoEntity, String> _f$zipCode = Field(
    'zipCode',
    _$zipCode,
    key: r'cep',
  );
  static String? _$street(AddressInfoEntity v) => v.street;
  static const Field<AddressInfoEntity, String> _f$street = Field(
    'street',
    _$street,
    key: r'logradouro',
    opt: true,
  );
  static String? _$number(AddressInfoEntity v) => v.number;
  static const Field<AddressInfoEntity, String> _f$number = Field(
    'number',
    _$number,
    opt: true,
  );
  static String? _$district(AddressInfoEntity v) => v.district;
  static const Field<AddressInfoEntity, String> _f$district = Field(
    'district',
    _$district,
    key: r'bairro',
    opt: true,
  );
  static String? _$city(AddressInfoEntity v) => v.city;
  static const Field<AddressInfoEntity, String> _f$city = Field(
    'city',
    _$city,
    key: r'localidade',
    opt: true,
  );
  static String? _$state(AddressInfoEntity v) => v.state;
  static const Field<AddressInfoEntity, String> _f$state = Field(
    'state',
    _$state,
    key: r'uf',
    opt: true,
  );
  static bool _$isPrimary(AddressInfoEntity v) => v.isPrimary;
  static const Field<AddressInfoEntity, bool> _f$isPrimary = Field(
    'isPrimary',
    _$isPrimary,
    opt: true,
    def: false,
  );
  static double? _$latitude(AddressInfoEntity v) => v.latitude;
  static const Field<AddressInfoEntity, double> _f$latitude = Field(
    'latitude',
    _$latitude,
    opt: true,
  );
  static double? _$longitude(AddressInfoEntity v) => v.longitude;
  static const Field<AddressInfoEntity, double> _f$longitude = Field(
    'longitude',
    _$longitude,
    opt: true,
  );
  static double? _$coverageRadius(AddressInfoEntity v) => v.coverageRadius;
  static const Field<AddressInfoEntity, double> _f$coverageRadius = Field(
    'coverageRadius',
    _$coverageRadius,
    opt: true,
  );
  static String? _$complement(AddressInfoEntity v) => v.complement;
  static const Field<AddressInfoEntity, String> _f$complement = Field(
    'complement',
    _$complement,
    opt: true,
  );

  @override
  final MappableFields<AddressInfoEntity> fields = const {
    #uid: _f$uid,
    #title: _f$title,
    #zipCode: _f$zipCode,
    #street: _f$street,
    #number: _f$number,
    #district: _f$district,
    #city: _f$city,
    #state: _f$state,
    #isPrimary: _f$isPrimary,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #coverageRadius: _f$coverageRadius,
    #complement: _f$complement,
  };

  static AddressInfoEntity _instantiate(DecodingData data) {
    return AddressInfoEntity(
      uid: data.dec(_f$uid),
      title: data.dec(_f$title),
      zipCode: data.dec(_f$zipCode),
      street: data.dec(_f$street),
      number: data.dec(_f$number),
      district: data.dec(_f$district),
      city: data.dec(_f$city),
      state: data.dec(_f$state),
      isPrimary: data.dec(_f$isPrimary),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
      coverageRadius: data.dec(_f$coverageRadius),
      complement: data.dec(_f$complement),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddressInfoEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddressInfoEntity>(map);
  }

  static AddressInfoEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AddressInfoEntity>(json);
  }
}

mixin AddressInfoEntityMappable {
  String toJson() {
    return AddressInfoEntityMapper.ensureInitialized()
        .encodeJson<AddressInfoEntity>(this as AddressInfoEntity);
  }

  Map<String, dynamic> toMap() {
    return AddressInfoEntityMapper.ensureInitialized()
        .encodeMap<AddressInfoEntity>(this as AddressInfoEntity);
  }

  AddressInfoEntityCopyWith<
    AddressInfoEntity,
    AddressInfoEntity,
    AddressInfoEntity
  >
  get copyWith =>
      _AddressInfoEntityCopyWithImpl<AddressInfoEntity, AddressInfoEntity>(
        this as AddressInfoEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddressInfoEntityMapper.ensureInitialized().stringifyValue(
      this as AddressInfoEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddressInfoEntityMapper.ensureInitialized().equalsValue(
      this as AddressInfoEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return AddressInfoEntityMapper.ensureInitialized().hashValue(
      this as AddressInfoEntity,
    );
  }
}

extension AddressInfoEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddressInfoEntity, $Out> {
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, $Out>
  get $asAddressInfoEntity => $base.as(
    (v, t, t2) => _AddressInfoEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AddressInfoEntityCopyWith<
  $R,
  $In extends AddressInfoEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? uid,
    String? title,
    String? zipCode,
    String? street,
    String? number,
    String? district,
    String? city,
    String? state,
    bool? isPrimary,
    double? latitude,
    double? longitude,
    double? coverageRadius,
    String? complement,
  });
  AddressInfoEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AddressInfoEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddressInfoEntity, $Out>
    implements AddressInfoEntityCopyWith<$R, AddressInfoEntity, $Out> {
  _AddressInfoEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddressInfoEntity> $mapper =
      AddressInfoEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? uid = $none,
    String? title,
    String? zipCode,
    Object? street = $none,
    Object? number = $none,
    Object? district = $none,
    Object? city = $none,
    Object? state = $none,
    bool? isPrimary,
    Object? latitude = $none,
    Object? longitude = $none,
    Object? coverageRadius = $none,
    Object? complement = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (title != null) #title: title,
      if (zipCode != null) #zipCode: zipCode,
      if (street != $none) #street: street,
      if (number != $none) #number: number,
      if (district != $none) #district: district,
      if (city != $none) #city: city,
      if (state != $none) #state: state,
      if (isPrimary != null) #isPrimary: isPrimary,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
      if (coverageRadius != $none) #coverageRadius: coverageRadius,
      if (complement != $none) #complement: complement,
    }),
  );
  @override
  AddressInfoEntity $make(CopyWithData data) => AddressInfoEntity(
    uid: data.get(#uid, or: $value.uid),
    title: data.get(#title, or: $value.title),
    zipCode: data.get(#zipCode, or: $value.zipCode),
    street: data.get(#street, or: $value.street),
    number: data.get(#number, or: $value.number),
    district: data.get(#district, or: $value.district),
    city: data.get(#city, or: $value.city),
    state: data.get(#state, or: $value.state),
    isPrimary: data.get(#isPrimary, or: $value.isPrimary),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
    coverageRadius: data.get(#coverageRadius, or: $value.coverageRadius),
    complement: data.get(#complement, or: $value.complement),
  );

  @override
  AddressInfoEntityCopyWith<$R2, AddressInfoEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AddressInfoEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

