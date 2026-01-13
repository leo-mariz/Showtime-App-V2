// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'favorite_artist_entity.dart';

class FavoriteArtistEntityMapper extends ClassMapperBase<FavoriteArtistEntity> {
  FavoriteArtistEntityMapper._();

  static FavoriteArtistEntityMapper? _instance;
  static FavoriteArtistEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FavoriteArtistEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FavoriteArtistEntity';

  static String _$artistId(FavoriteArtistEntity v) => v.artistId;
  static const Field<FavoriteArtistEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
  );
  static String? _$artistName(FavoriteArtistEntity v) => v.artistName;
  static const Field<FavoriteArtistEntity, String> _f$artistName = Field(
    'artistName',
    _$artistName,
    opt: true,
  );
  static String? _$artistPhoto(FavoriteArtistEntity v) => v.artistPhoto;
  static const Field<FavoriteArtistEntity, String> _f$artistPhoto = Field(
    'artistPhoto',
    _$artistPhoto,
    opt: true,
  );
  static double? _$artistRating(FavoriteArtistEntity v) => v.artistRating;
  static const Field<FavoriteArtistEntity, double> _f$artistRating = Field(
    'artistRating',
    _$artistRating,
    opt: true,
  );
  static int? _$artistRatedPresentations(FavoriteArtistEntity v) =>
      v.artistRatedPresentations;
  static const Field<FavoriteArtistEntity, int> _f$artistRatedPresentations =
      Field('artistRatedPresentations', _$artistRatedPresentations, opt: true);
  static DateTime _$addedAt(FavoriteArtistEntity v) => v.addedAt;
  static const Field<FavoriteArtistEntity, DateTime> _f$addedAt = Field(
    'addedAt',
    _$addedAt,
    opt: true,
  );
  static List<String>? _$tags(FavoriteArtistEntity v) => v.tags;
  static const Field<FavoriteArtistEntity, List<String>> _f$tags = Field(
    'tags',
    _$tags,
    opt: true,
  );
  static String? _$notes(FavoriteArtistEntity v) => v.notes;
  static const Field<FavoriteArtistEntity, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );

  @override
  final MappableFields<FavoriteArtistEntity> fields = const {
    #artistId: _f$artistId,
    #artistName: _f$artistName,
    #artistPhoto: _f$artistPhoto,
    #artistRating: _f$artistRating,
    #artistRatedPresentations: _f$artistRatedPresentations,
    #addedAt: _f$addedAt,
    #tags: _f$tags,
    #notes: _f$notes,
  };

  static FavoriteArtistEntity _instantiate(DecodingData data) {
    return FavoriteArtistEntity(
      artistId: data.dec(_f$artistId),
      artistName: data.dec(_f$artistName),
      artistPhoto: data.dec(_f$artistPhoto),
      artistRating: data.dec(_f$artistRating),
      artistRatedPresentations: data.dec(_f$artistRatedPresentations),
      addedAt: data.dec(_f$addedAt),
      tags: data.dec(_f$tags),
      notes: data.dec(_f$notes),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FavoriteArtistEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FavoriteArtistEntity>(map);
  }

  static FavoriteArtistEntity fromJson(String json) {
    return ensureInitialized().decodeJson<FavoriteArtistEntity>(json);
  }
}

mixin FavoriteArtistEntityMappable {
  String toJson() {
    return FavoriteArtistEntityMapper.ensureInitialized()
        .encodeJson<FavoriteArtistEntity>(this as FavoriteArtistEntity);
  }

  Map<String, dynamic> toMap() {
    return FavoriteArtistEntityMapper.ensureInitialized()
        .encodeMap<FavoriteArtistEntity>(this as FavoriteArtistEntity);
  }

  FavoriteArtistEntityCopyWith<
    FavoriteArtistEntity,
    FavoriteArtistEntity,
    FavoriteArtistEntity
  >
  get copyWith =>
      _FavoriteArtistEntityCopyWithImpl<
        FavoriteArtistEntity,
        FavoriteArtistEntity
      >(this as FavoriteArtistEntity, $identity, $identity);
  @override
  String toString() {
    return FavoriteArtistEntityMapper.ensureInitialized().stringifyValue(
      this as FavoriteArtistEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return FavoriteArtistEntityMapper.ensureInitialized().equalsValue(
      this as FavoriteArtistEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return FavoriteArtistEntityMapper.ensureInitialized().hashValue(
      this as FavoriteArtistEntity,
    );
  }
}

extension FavoriteArtistEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FavoriteArtistEntity, $Out> {
  FavoriteArtistEntityCopyWith<$R, FavoriteArtistEntity, $Out>
  get $asFavoriteArtistEntity => $base.as(
    (v, t, t2) => _FavoriteArtistEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FavoriteArtistEntityCopyWith<
  $R,
  $In extends FavoriteArtistEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get tags;
  $R call({
    String? artistId,
    String? artistName,
    String? artistPhoto,
    double? artistRating,
    int? artistRatedPresentations,
    DateTime? addedAt,
    List<String>? tags,
    String? notes,
  });
  FavoriteArtistEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FavoriteArtistEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FavoriteArtistEntity, $Out>
    implements FavoriteArtistEntityCopyWith<$R, FavoriteArtistEntity, $Out> {
  _FavoriteArtistEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FavoriteArtistEntity> $mapper =
      FavoriteArtistEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get tags =>
      $value.tags != null
      ? ListCopyWith(
          $value.tags!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(tags: v),
        )
      : null;
  @override
  $R call({
    String? artistId,
    Object? artistName = $none,
    Object? artistPhoto = $none,
    Object? artistRating = $none,
    Object? artistRatedPresentations = $none,
    Object? addedAt = $none,
    Object? tags = $none,
    Object? notes = $none,
  }) => $apply(
    FieldCopyWithData({
      if (artistId != null) #artistId: artistId,
      if (artistName != $none) #artistName: artistName,
      if (artistPhoto != $none) #artistPhoto: artistPhoto,
      if (artistRating != $none) #artistRating: artistRating,
      if (artistRatedPresentations != $none)
        #artistRatedPresentations: artistRatedPresentations,
      if (addedAt != $none) #addedAt: addedAt,
      if (tags != $none) #tags: tags,
      if (notes != $none) #notes: notes,
    }),
  );
  @override
  FavoriteArtistEntity $make(CopyWithData data) => FavoriteArtistEntity(
    artistId: data.get(#artistId, or: $value.artistId),
    artistName: data.get(#artistName, or: $value.artistName),
    artistPhoto: data.get(#artistPhoto, or: $value.artistPhoto),
    artistRating: data.get(#artistRating, or: $value.artistRating),
    artistRatedPresentations: data.get(
      #artistRatedPresentations,
      or: $value.artistRatedPresentations,
    ),
    addedAt: data.get(#addedAt, or: $value.addedAt),
    tags: data.get(#tags, or: $value.tags),
    notes: data.get(#notes, or: $value.notes),
  );

  @override
  FavoriteArtistEntityCopyWith<$R2, FavoriteArtistEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FavoriteArtistEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

