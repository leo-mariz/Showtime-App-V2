// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'client_entity.dart';

class ClientEntityMapper extends ClassMapperBase<ClientEntity> {
  ClientEntityMapper._();

  static ClientEntityMapper? _instance;
  static ClientEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ClientEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ClientEntity';

  static String? _$uid(ClientEntity v) => v.uid;
  static const Field<ClientEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String? _$profilePicture(ClientEntity v) => v.profilePicture;
  static const Field<ClientEntity, String> _f$profilePicture = Field(
    'profilePicture',
    _$profilePicture,
    opt: true,
  );
  static DateTime? _$dateRegistered(ClientEntity v) => v.dateRegistered;
  static const Field<ClientEntity, DateTime> _f$dateRegistered = Field(
    'dateRegistered',
    _$dateRegistered,
    opt: true,
  );
  static List<String>? _$preferences(ClientEntity v) => v.preferences;
  static const Field<ClientEntity, List<String>> _f$preferences = Field(
    'preferences',
    _$preferences,
    opt: true,
  );
  static bool? _$agreedToClientTermsOfUse(ClientEntity v) =>
      v.agreedToClientTermsOfUse;
  static const Field<ClientEntity, bool> _f$agreedToClientTermsOfUse = Field(
    'agreedToClientTermsOfUse',
    _$agreedToClientTermsOfUse,
    opt: true,
  );

  @override
  final MappableFields<ClientEntity> fields = const {
    #uid: _f$uid,
    #profilePicture: _f$profilePicture,
    #dateRegistered: _f$dateRegistered,
    #preferences: _f$preferences,
    #agreedToClientTermsOfUse: _f$agreedToClientTermsOfUse,
  };

  static ClientEntity _instantiate(DecodingData data) {
    return ClientEntity(
      uid: data.dec(_f$uid),
      profilePicture: data.dec(_f$profilePicture),
      dateRegistered: data.dec(_f$dateRegistered),
      preferences: data.dec(_f$preferences),
      agreedToClientTermsOfUse: data.dec(_f$agreedToClientTermsOfUse),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ClientEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ClientEntity>(map);
  }

  static ClientEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ClientEntity>(json);
  }
}

mixin ClientEntityMappable {
  String toJson() {
    return ClientEntityMapper.ensureInitialized().encodeJson<ClientEntity>(
      this as ClientEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return ClientEntityMapper.ensureInitialized().encodeMap<ClientEntity>(
      this as ClientEntity,
    );
  }

  ClientEntityCopyWith<ClientEntity, ClientEntity, ClientEntity> get copyWith =>
      _ClientEntityCopyWithImpl<ClientEntity, ClientEntity>(
        this as ClientEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ClientEntityMapper.ensureInitialized().stringifyValue(
      this as ClientEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ClientEntityMapper.ensureInitialized().equalsValue(
      this as ClientEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ClientEntityMapper.ensureInitialized().hashValue(
      this as ClientEntity,
    );
  }
}

extension ClientEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ClientEntity, $Out> {
  ClientEntityCopyWith<$R, ClientEntity, $Out> get $asClientEntity =>
      $base.as((v, t, t2) => _ClientEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ClientEntityCopyWith<$R, $In extends ClientEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get preferences;
  $R call({
    String? uid,
    String? profilePicture,
    DateTime? dateRegistered,
    List<String>? preferences,
    bool? agreedToClientTermsOfUse,
  });
  ClientEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ClientEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ClientEntity, $Out>
    implements ClientEntityCopyWith<$R, ClientEntity, $Out> {
  _ClientEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ClientEntity> $mapper =
      ClientEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get preferences => $value.preferences != null
      ? ListCopyWith(
          $value.preferences!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(preferences: v),
        )
      : null;
  @override
  $R call({
    Object? uid = $none,
    Object? profilePicture = $none,
    Object? dateRegistered = $none,
    Object? preferences = $none,
    Object? agreedToClientTermsOfUse = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (dateRegistered != $none) #dateRegistered: dateRegistered,
      if (preferences != $none) #preferences: preferences,
      if (agreedToClientTermsOfUse != $none)
        #agreedToClientTermsOfUse: agreedToClientTermsOfUse,
    }),
  );
  @override
  ClientEntity $make(CopyWithData data) => ClientEntity(
    uid: data.get(#uid, or: $value.uid),
    profilePicture: data.get(#profilePicture, or: $value.profilePicture),
    dateRegistered: data.get(#dateRegistered, or: $value.dateRegistered),
    preferences: data.get(#preferences, or: $value.preferences),
    agreedToClientTermsOfUse: data.get(
      #agreedToClientTermsOfUse,
      or: $value.agreedToClientTermsOfUse,
    ),
  );

  @override
  ClientEntityCopyWith<$R2, ClientEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ClientEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

