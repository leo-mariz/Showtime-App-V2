// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'show_rating_requested_entity.dart';

class ShowRatingRequestedEntityMapper
    extends ClassMapperBase<ShowRatingRequestedEntity> {
  ShowRatingRequestedEntityMapper._();

  static ShowRatingRequestedEntityMapper? _instance;
  static ShowRatingRequestedEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ShowRatingRequestedEntityMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'ShowRatingRequestedEntity';

  static bool _$showRatingRequested(ShowRatingRequestedEntity v) =>
      v.showRatingRequested;
  static const Field<ShowRatingRequestedEntity, bool> _f$showRatingRequested =
      Field('showRatingRequested', _$showRatingRequested);
  static bool _$showRatingSkipped(ShowRatingRequestedEntity v) =>
      v.showRatingSkipped;
  static const Field<ShowRatingRequestedEntity, bool> _f$showRatingSkipped =
      Field('showRatingSkipped', _$showRatingSkipped);
  static bool _$showRatingCompleted(ShowRatingRequestedEntity v) =>
      v.showRatingCompleted;
  static const Field<ShowRatingRequestedEntity, bool> _f$showRatingCompleted =
      Field('showRatingCompleted', _$showRatingCompleted);
  static DateTime _$showRatingRequestedAt(ShowRatingRequestedEntity v) =>
      v.showRatingRequestedAt;
  static const Field<ShowRatingRequestedEntity, DateTime>
  _f$showRatingRequestedAt = Field(
    'showRatingRequestedAt',
    _$showRatingRequestedAt,
  );
  static String _$showRatingRequestedFor(ShowRatingRequestedEntity v) =>
      v.showRatingRequestedFor;
  static const Field<ShowRatingRequestedEntity, String>
  _f$showRatingRequestedFor = Field(
    'showRatingRequestedFor',
    _$showRatingRequestedFor,
  );

  @override
  final MappableFields<ShowRatingRequestedEntity> fields = const {
    #showRatingRequested: _f$showRatingRequested,
    #showRatingSkipped: _f$showRatingSkipped,
    #showRatingCompleted: _f$showRatingCompleted,
    #showRatingRequestedAt: _f$showRatingRequestedAt,
    #showRatingRequestedFor: _f$showRatingRequestedFor,
  };

  static ShowRatingRequestedEntity _instantiate(DecodingData data) {
    return ShowRatingRequestedEntity(
      showRatingRequested: data.dec(_f$showRatingRequested),
      showRatingSkipped: data.dec(_f$showRatingSkipped),
      showRatingCompleted: data.dec(_f$showRatingCompleted),
      showRatingRequestedAt: data.dec(_f$showRatingRequestedAt),
      showRatingRequestedFor: data.dec(_f$showRatingRequestedFor),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ShowRatingRequestedEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ShowRatingRequestedEntity>(map);
  }

  static ShowRatingRequestedEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ShowRatingRequestedEntity>(json);
  }
}

mixin ShowRatingRequestedEntityMappable {
  String toJson() {
    return ShowRatingRequestedEntityMapper.ensureInitialized()
        .encodeJson<ShowRatingRequestedEntity>(
          this as ShowRatingRequestedEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return ShowRatingRequestedEntityMapper.ensureInitialized()
        .encodeMap<ShowRatingRequestedEntity>(
          this as ShowRatingRequestedEntity,
        );
  }

  ShowRatingRequestedEntityCopyWith<
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity
  >
  get copyWith =>
      _ShowRatingRequestedEntityCopyWithImpl<
        ShowRatingRequestedEntity,
        ShowRatingRequestedEntity
      >(this as ShowRatingRequestedEntity, $identity, $identity);
  @override
  String toString() {
    return ShowRatingRequestedEntityMapper.ensureInitialized().stringifyValue(
      this as ShowRatingRequestedEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ShowRatingRequestedEntityMapper.ensureInitialized().equalsValue(
      this as ShowRatingRequestedEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ShowRatingRequestedEntityMapper.ensureInitialized().hashValue(
      this as ShowRatingRequestedEntity,
    );
  }
}

extension ShowRatingRequestedEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ShowRatingRequestedEntity, $Out> {
  ShowRatingRequestedEntityCopyWith<$R, ShowRatingRequestedEntity, $Out>
  get $asShowRatingRequestedEntity => $base.as(
    (v, t, t2) => _ShowRatingRequestedEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ShowRatingRequestedEntityCopyWith<
  $R,
  $In extends ShowRatingRequestedEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    bool? showRatingRequested,
    bool? showRatingSkipped,
    bool? showRatingCompleted,
    DateTime? showRatingRequestedAt,
    String? showRatingRequestedFor,
  });
  ShowRatingRequestedEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ShowRatingRequestedEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ShowRatingRequestedEntity, $Out>
    implements
        ShowRatingRequestedEntityCopyWith<$R, ShowRatingRequestedEntity, $Out> {
  _ShowRatingRequestedEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ShowRatingRequestedEntity> $mapper =
      ShowRatingRequestedEntityMapper.ensureInitialized();
  @override
  $R call({
    bool? showRatingRequested,
    bool? showRatingSkipped,
    bool? showRatingCompleted,
    DateTime? showRatingRequestedAt,
    String? showRatingRequestedFor,
  }) => $apply(
    FieldCopyWithData({
      if (showRatingRequested != null)
        #showRatingRequested: showRatingRequested,
      if (showRatingSkipped != null) #showRatingSkipped: showRatingSkipped,
      if (showRatingCompleted != null)
        #showRatingCompleted: showRatingCompleted,
      if (showRatingRequestedAt != null)
        #showRatingRequestedAt: showRatingRequestedAt,
      if (showRatingRequestedFor != null)
        #showRatingRequestedFor: showRatingRequestedFor,
    }),
  );
  @override
  ShowRatingRequestedEntity $make(CopyWithData data) =>
      ShowRatingRequestedEntity(
        showRatingRequested: data.get(
          #showRatingRequested,
          or: $value.showRatingRequested,
        ),
        showRatingSkipped: data.get(
          #showRatingSkipped,
          or: $value.showRatingSkipped,
        ),
        showRatingCompleted: data.get(
          #showRatingCompleted,
          or: $value.showRatingCompleted,
        ),
        showRatingRequestedAt: data.get(
          #showRatingRequestedAt,
          or: $value.showRatingRequestedAt,
        ),
        showRatingRequestedFor: data.get(
          #showRatingRequestedFor,
          or: $value.showRatingRequestedFor,
        ),
      );

  @override
  ShowRatingRequestedEntityCopyWith<$R2, ShowRatingRequestedEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ShowRatingRequestedEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

