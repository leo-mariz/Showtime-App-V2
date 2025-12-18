// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'social_media_links_entity.dart';

class SocialMediaLinksEntityMapper
    extends ClassMapperBase<SocialMediaLinksEntity> {
  SocialMediaLinksEntityMapper._();

  static SocialMediaLinksEntityMapper? _instance;
  static SocialMediaLinksEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SocialMediaLinksEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SocialMediaLinksEntity';

  static String? _$instagram(SocialMediaLinksEntity v) => v.instagram;
  static const Field<SocialMediaLinksEntity, String> _f$instagram = Field(
    'instagram',
    _$instagram,
    opt: true,
  );
  static String? _$youtube(SocialMediaLinksEntity v) => v.youtube;
  static const Field<SocialMediaLinksEntity, String> _f$youtube = Field(
    'youtube',
    _$youtube,
    opt: true,
  );
  static String? _$tiktok(SocialMediaLinksEntity v) => v.tiktok;
  static const Field<SocialMediaLinksEntity, String> _f$tiktok = Field(
    'tiktok',
    _$tiktok,
    opt: true,
  );
  static String? _$spotify(SocialMediaLinksEntity v) => v.spotify;
  static const Field<SocialMediaLinksEntity, String> _f$spotify = Field(
    'spotify',
    _$spotify,
    opt: true,
  );

  @override
  final MappableFields<SocialMediaLinksEntity> fields = const {
    #instagram: _f$instagram,
    #youtube: _f$youtube,
    #tiktok: _f$tiktok,
    #spotify: _f$spotify,
  };

  static SocialMediaLinksEntity _instantiate(DecodingData data) {
    return SocialMediaLinksEntity(
      instagram: data.dec(_f$instagram),
      youtube: data.dec(_f$youtube),
      tiktok: data.dec(_f$tiktok),
      spotify: data.dec(_f$spotify),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SocialMediaLinksEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SocialMediaLinksEntity>(map);
  }

  static SocialMediaLinksEntity fromJson(String json) {
    return ensureInitialized().decodeJson<SocialMediaLinksEntity>(json);
  }
}

mixin SocialMediaLinksEntityMappable {
  String toJson() {
    return SocialMediaLinksEntityMapper.ensureInitialized()
        .encodeJson<SocialMediaLinksEntity>(this as SocialMediaLinksEntity);
  }

  Map<String, dynamic> toMap() {
    return SocialMediaLinksEntityMapper.ensureInitialized()
        .encodeMap<SocialMediaLinksEntity>(this as SocialMediaLinksEntity);
  }

  SocialMediaLinksEntityCopyWith<
    SocialMediaLinksEntity,
    SocialMediaLinksEntity,
    SocialMediaLinksEntity
  >
  get copyWith =>
      _SocialMediaLinksEntityCopyWithImpl<
        SocialMediaLinksEntity,
        SocialMediaLinksEntity
      >(this as SocialMediaLinksEntity, $identity, $identity);
  @override
  String toString() {
    return SocialMediaLinksEntityMapper.ensureInitialized().stringifyValue(
      this as SocialMediaLinksEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return SocialMediaLinksEntityMapper.ensureInitialized().equalsValue(
      this as SocialMediaLinksEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return SocialMediaLinksEntityMapper.ensureInitialized().hashValue(
      this as SocialMediaLinksEntity,
    );
  }
}

extension SocialMediaLinksEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SocialMediaLinksEntity, $Out> {
  SocialMediaLinksEntityCopyWith<$R, SocialMediaLinksEntity, $Out>
  get $asSocialMediaLinksEntity => $base.as(
    (v, t, t2) => _SocialMediaLinksEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SocialMediaLinksEntityCopyWith<
  $R,
  $In extends SocialMediaLinksEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? instagram,
    String? youtube,
    String? tiktok,
    String? spotify,
  });
  SocialMediaLinksEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SocialMediaLinksEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SocialMediaLinksEntity, $Out>
    implements
        SocialMediaLinksEntityCopyWith<$R, SocialMediaLinksEntity, $Out> {
  _SocialMediaLinksEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SocialMediaLinksEntity> $mapper =
      SocialMediaLinksEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? instagram = $none,
    Object? youtube = $none,
    Object? tiktok = $none,
    Object? spotify = $none,
  }) => $apply(
    FieldCopyWithData({
      if (instagram != $none) #instagram: instagram,
      if (youtube != $none) #youtube: youtube,
      if (tiktok != $none) #tiktok: tiktok,
      if (spotify != $none) #spotify: spotify,
    }),
  );
  @override
  SocialMediaLinksEntity $make(CopyWithData data) => SocialMediaLinksEntity(
    instagram: data.get(#instagram, or: $value.instagram),
    youtube: data.get(#youtube, or: $value.youtube),
    tiktok: data.get(#tiktok, or: $value.tiktok),
    spotify: data.get(#spotify, or: $value.spotify),
  );

  @override
  SocialMediaLinksEntityCopyWith<$R2, SocialMediaLinksEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SocialMediaLinksEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

