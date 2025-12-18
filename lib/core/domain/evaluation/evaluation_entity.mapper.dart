// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'evaluation_entity.dart';

class EvaluationEntityMapper extends ClassMapperBase<EvaluationEntity> {
  EvaluationEntityMapper._();

  static EvaluationEntityMapper? _instance;
  static EvaluationEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EvaluationEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EvaluationEntity';

  static String _$uid(EvaluationEntity v) => v.uid;
  static const Field<EvaluationEntity, String> _f$uid = Field('uid', _$uid);
  static String? _$comment(EvaluationEntity v) => v.comment;
  static const Field<EvaluationEntity, String> _f$comment = Field(
    'comment',
    _$comment,
    opt: true,
  );
  static int _$rating(EvaluationEntity v) => v.rating;
  static const Field<EvaluationEntity, int> _f$rating = Field(
    'rating',
    _$rating,
  );
  static String _$userId(EvaluationEntity v) => v.userId;
  static const Field<EvaluationEntity, String> _f$userId = Field(
    'userId',
    _$userId,
  );
  static String _$artistId(EvaluationEntity v) => v.artistId;
  static const Field<EvaluationEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
  );
  static String _$eventId(EvaluationEntity v) => v.eventId;
  static const Field<EvaluationEntity, String> _f$eventId = Field(
    'eventId',
    _$eventId,
  );

  @override
  final MappableFields<EvaluationEntity> fields = const {
    #uid: _f$uid,
    #comment: _f$comment,
    #rating: _f$rating,
    #userId: _f$userId,
    #artistId: _f$artistId,
    #eventId: _f$eventId,
  };

  static EvaluationEntity _instantiate(DecodingData data) {
    return EvaluationEntity(
      uid: data.dec(_f$uid),
      comment: data.dec(_f$comment),
      rating: data.dec(_f$rating),
      userId: data.dec(_f$userId),
      artistId: data.dec(_f$artistId),
      eventId: data.dec(_f$eventId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EvaluationEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EvaluationEntity>(map);
  }

  static EvaluationEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EvaluationEntity>(json);
  }
}

mixin EvaluationEntityMappable {
  String toJson() {
    return EvaluationEntityMapper.ensureInitialized()
        .encodeJson<EvaluationEntity>(this as EvaluationEntity);
  }

  Map<String, dynamic> toMap() {
    return EvaluationEntityMapper.ensureInitialized()
        .encodeMap<EvaluationEntity>(this as EvaluationEntity);
  }

  EvaluationEntityCopyWith<EvaluationEntity, EvaluationEntity, EvaluationEntity>
  get copyWith =>
      _EvaluationEntityCopyWithImpl<EvaluationEntity, EvaluationEntity>(
        this as EvaluationEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EvaluationEntityMapper.ensureInitialized().stringifyValue(
      this as EvaluationEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EvaluationEntityMapper.ensureInitialized().equalsValue(
      this as EvaluationEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EvaluationEntityMapper.ensureInitialized().hashValue(
      this as EvaluationEntity,
    );
  }
}

extension EvaluationEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EvaluationEntity, $Out> {
  EvaluationEntityCopyWith<$R, EvaluationEntity, $Out>
  get $asEvaluationEntity =>
      $base.as((v, t, t2) => _EvaluationEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EvaluationEntityCopyWith<$R, $In extends EvaluationEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? uid,
    String? comment,
    int? rating,
    String? userId,
    String? artistId,
    String? eventId,
  });
  EvaluationEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EvaluationEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EvaluationEntity, $Out>
    implements EvaluationEntityCopyWith<$R, EvaluationEntity, $Out> {
  _EvaluationEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EvaluationEntity> $mapper =
      EvaluationEntityMapper.ensureInitialized();
  @override
  $R call({
    String? uid,
    Object? comment = $none,
    int? rating,
    String? userId,
    String? artistId,
    String? eventId,
  }) => $apply(
    FieldCopyWithData({
      if (uid != null) #uid: uid,
      if (comment != $none) #comment: comment,
      if (rating != null) #rating: rating,
      if (userId != null) #userId: userId,
      if (artistId != null) #artistId: artistId,
      if (eventId != null) #eventId: eventId,
    }),
  );
  @override
  EvaluationEntity $make(CopyWithData data) => EvaluationEntity(
    uid: data.get(#uid, or: $value.uid),
    comment: data.get(#comment, or: $value.comment),
    rating: data.get(#rating, or: $value.rating),
    userId: data.get(#userId, or: $value.userId),
    artistId: data.get(#artistId, or: $value.artistId),
    eventId: data.get(#eventId, or: $value.eventId),
  );

  @override
  EvaluationEntityCopyWith<$R2, EvaluationEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EvaluationEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

