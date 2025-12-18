// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'register_entity.dart';

class RegisterEntityMapper extends ClassMapperBase<RegisterEntity> {
  RegisterEntityMapper._();

  static RegisterEntityMapper? _instance;
  static RegisterEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RegisterEntityMapper._());
      UserEntityMapper.ensureInitialized();
      ArtistEntityMapper.ensureInitialized();
      ClientEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RegisterEntity';

  static UserEntity _$user(RegisterEntity v) => v.user;
  static const Field<RegisterEntity, UserEntity> _f$user = Field(
    'user',
    _$user,
  );
  static ArtistEntity _$artist(RegisterEntity v) => v.artist;
  static const Field<RegisterEntity, ArtistEntity> _f$artist = Field(
    'artist',
    _$artist,
  );
  static ClientEntity _$client(RegisterEntity v) => v.client;
  static const Field<RegisterEntity, ClientEntity> _f$client = Field(
    'client',
    _$client,
  );

  @override
  final MappableFields<RegisterEntity> fields = const {
    #user: _f$user,
    #artist: _f$artist,
    #client: _f$client,
  };

  static RegisterEntity _instantiate(DecodingData data) {
    return RegisterEntity(
      user: data.dec(_f$user),
      artist: data.dec(_f$artist),
      client: data.dec(_f$client),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RegisterEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RegisterEntity>(map);
  }

  static RegisterEntity fromJson(String json) {
    return ensureInitialized().decodeJson<RegisterEntity>(json);
  }
}

mixin RegisterEntityMappable {
  String toJson() {
    return RegisterEntityMapper.ensureInitialized().encodeJson<RegisterEntity>(
      this as RegisterEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return RegisterEntityMapper.ensureInitialized().encodeMap<RegisterEntity>(
      this as RegisterEntity,
    );
  }

  RegisterEntityCopyWith<RegisterEntity, RegisterEntity, RegisterEntity>
  get copyWith => _RegisterEntityCopyWithImpl<RegisterEntity, RegisterEntity>(
    this as RegisterEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return RegisterEntityMapper.ensureInitialized().stringifyValue(
      this as RegisterEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return RegisterEntityMapper.ensureInitialized().equalsValue(
      this as RegisterEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return RegisterEntityMapper.ensureInitialized().hashValue(
      this as RegisterEntity,
    );
  }
}

extension RegisterEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RegisterEntity, $Out> {
  RegisterEntityCopyWith<$R, RegisterEntity, $Out> get $asRegisterEntity =>
      $base.as((v, t, t2) => _RegisterEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RegisterEntityCopyWith<$R, $In extends RegisterEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  UserEntityCopyWith<$R, UserEntity, UserEntity> get user;
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity> get artist;
  ClientEntityCopyWith<$R, ClientEntity, ClientEntity> get client;
  $R call({UserEntity? user, ArtistEntity? artist, ClientEntity? client});
  RegisterEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RegisterEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RegisterEntity, $Out>
    implements RegisterEntityCopyWith<$R, RegisterEntity, $Out> {
  _RegisterEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RegisterEntity> $mapper =
      RegisterEntityMapper.ensureInitialized();
  @override
  UserEntityCopyWith<$R, UserEntity, UserEntity> get user =>
      $value.user.copyWith.$chain((v) => call(user: v));
  @override
  ArtistEntityCopyWith<$R, ArtistEntity, ArtistEntity> get artist =>
      $value.artist.copyWith.$chain((v) => call(artist: v));
  @override
  ClientEntityCopyWith<$R, ClientEntity, ClientEntity> get client =>
      $value.client.copyWith.$chain((v) => call(client: v));
  @override
  $R call({UserEntity? user, ArtistEntity? artist, ClientEntity? client}) =>
      $apply(
        FieldCopyWithData({
          if (user != null) #user: user,
          if (artist != null) #artist: artist,
          if (client != null) #client: client,
        }),
      );
  @override
  RegisterEntity $make(CopyWithData data) => RegisterEntity(
    user: data.get(#user, or: $value.user),
    artist: data.get(#artist, or: $value.artist),
    client: data.get(#client, or: $value.client),
  );

  @override
  RegisterEntityCopyWith<$R2, RegisterEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RegisterEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

