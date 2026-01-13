// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rating_entity.dart';

class RatingEntityMapper extends ClassMapperBase<RatingEntity> {
  RatingEntityMapper._();

  static RatingEntityMapper? _instance;
  static RatingEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RatingEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'RatingEntity';

  static String? _$comment(RatingEntity v) => v.comment;
  static const Field<RatingEntity, String> _f$comment = Field(
    'comment',
    _$comment,
  );
  static double _$rating(RatingEntity v) => v.rating;
  static const Field<RatingEntity, double> _f$rating = Field(
    'rating',
    _$rating,
  );
  static bool _$isClientRating(RatingEntity v) => v.isClientRating;
  static const Field<RatingEntity, bool> _f$isClientRating = Field(
    'isClientRating',
    _$isClientRating,
  );
  static bool _$skippedRating(RatingEntity v) => v.skippedRating;
  static const Field<RatingEntity, bool> _f$skippedRating = Field(
    'skippedRating',
    _$skippedRating,
  );
  static DateTime? _$ratedAt(RatingEntity v) => v.ratedAt;
  static const Field<RatingEntity, DateTime> _f$ratedAt = Field(
    'ratedAt',
    _$ratedAt,
    opt: true,
  );
  static DateTime _$createdAt(RatingEntity v) => v.createdAt;
  static const Field<RatingEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<RatingEntity> fields = const {
    #comment: _f$comment,
    #rating: _f$rating,
    #isClientRating: _f$isClientRating,
    #skippedRating: _f$skippedRating,
    #ratedAt: _f$ratedAt,
    #createdAt: _f$createdAt,
  };

  static RatingEntity _instantiate(DecodingData data) {
    return RatingEntity(
      comment: data.dec(_f$comment),
      rating: data.dec(_f$rating),
      isClientRating: data.dec(_f$isClientRating),
      skippedRating: data.dec(_f$skippedRating),
      ratedAt: data.dec(_f$ratedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RatingEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RatingEntity>(map);
  }

  static RatingEntity fromJson(String json) {
    return ensureInitialized().decodeJson<RatingEntity>(json);
  }
}

mixin RatingEntityMappable {
  String toJson() {
    return RatingEntityMapper.ensureInitialized().encodeJson<RatingEntity>(
      this as RatingEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return RatingEntityMapper.ensureInitialized().encodeMap<RatingEntity>(
      this as RatingEntity,
    );
  }

  RatingEntityCopyWith<RatingEntity, RatingEntity, RatingEntity> get copyWith =>
      _RatingEntityCopyWithImpl<RatingEntity, RatingEntity>(
        this as RatingEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RatingEntityMapper.ensureInitialized().stringifyValue(
      this as RatingEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return RatingEntityMapper.ensureInitialized().equalsValue(
      this as RatingEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return RatingEntityMapper.ensureInitialized().hashValue(
      this as RatingEntity,
    );
  }
}

extension RatingEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RatingEntity, $Out> {
  RatingEntityCopyWith<$R, RatingEntity, $Out> get $asRatingEntity =>
      $base.as((v, t, t2) => _RatingEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RatingEntityCopyWith<$R, $In extends RatingEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? comment,
    double? rating,
    bool? isClientRating,
    bool? skippedRating,
    DateTime? ratedAt,
  });
  RatingEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RatingEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RatingEntity, $Out>
    implements RatingEntityCopyWith<$R, RatingEntity, $Out> {
  _RatingEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RatingEntity> $mapper =
      RatingEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? comment = $none,
    double? rating,
    bool? isClientRating,
    bool? skippedRating,
    Object? ratedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (comment != $none) #comment: comment,
      if (rating != null) #rating: rating,
      if (isClientRating != null) #isClientRating: isClientRating,
      if (skippedRating != null) #skippedRating: skippedRating,
      if (ratedAt != $none) #ratedAt: ratedAt,
    }),
  );
  @override
  RatingEntity $make(CopyWithData data) => RatingEntity(
    comment: data.get(#comment, or: $value.comment),
    rating: data.get(#rating, or: $value.rating),
    isClientRating: data.get(#isClientRating, or: $value.isClientRating),
    skippedRating: data.get(#skippedRating, or: $value.skippedRating),
    ratedAt: data.get(#ratedAt, or: $value.ratedAt),
  );

  @override
  RatingEntityCopyWith<$R2, RatingEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RatingEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

