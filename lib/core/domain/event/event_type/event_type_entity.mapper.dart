// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'event_type_entity.dart';

class EventTypeEntityMapper extends ClassMapperBase<EventTypeEntity> {
  EventTypeEntityMapper._();

  static EventTypeEntityMapper? _instance;
  static EventTypeEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventTypeEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EventTypeEntity';

  static String _$uid(EventTypeEntity v) => v.uid;
  static const Field<EventTypeEntity, String> _f$uid = Field('uid', _$uid);
  static String _$name(EventTypeEntity v) => v.name;
  static const Field<EventTypeEntity, String> _f$name = Field('name', _$name);
  static String _$active(EventTypeEntity v) => v.active;
  static const Field<EventTypeEntity, String> _f$active = Field(
    'active',
    _$active,
  );

  @override
  final MappableFields<EventTypeEntity> fields = const {
    #uid: _f$uid,
    #name: _f$name,
    #active: _f$active,
  };

  static EventTypeEntity _instantiate(DecodingData data) {
    return EventTypeEntity(
      uid: data.dec(_f$uid),
      name: data.dec(_f$name),
      active: data.dec(_f$active),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EventTypeEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EventTypeEntity>(map);
  }

  static EventTypeEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EventTypeEntity>(json);
  }
}

mixin EventTypeEntityMappable {
  String toJson() {
    return EventTypeEntityMapper.ensureInitialized()
        .encodeJson<EventTypeEntity>(this as EventTypeEntity);
  }

  Map<String, dynamic> toMap() {
    return EventTypeEntityMapper.ensureInitialized().encodeMap<EventTypeEntity>(
      this as EventTypeEntity,
    );
  }

  EventTypeEntityCopyWith<EventTypeEntity, EventTypeEntity, EventTypeEntity>
  get copyWith =>
      _EventTypeEntityCopyWithImpl<EventTypeEntity, EventTypeEntity>(
        this as EventTypeEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EventTypeEntityMapper.ensureInitialized().stringifyValue(
      this as EventTypeEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EventTypeEntityMapper.ensureInitialized().equalsValue(
      this as EventTypeEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EventTypeEntityMapper.ensureInitialized().hashValue(
      this as EventTypeEntity,
    );
  }
}

extension EventTypeEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EventTypeEntity, $Out> {
  EventTypeEntityCopyWith<$R, EventTypeEntity, $Out> get $asEventTypeEntity =>
      $base.as((v, t, t2) => _EventTypeEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventTypeEntityCopyWith<$R, $In extends EventTypeEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? uid, String? name, String? active});
  EventTypeEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EventTypeEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EventTypeEntity, $Out>
    implements EventTypeEntityCopyWith<$R, EventTypeEntity, $Out> {
  _EventTypeEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EventTypeEntity> $mapper =
      EventTypeEntityMapper.ensureInitialized();
  @override
  $R call({String? uid, String? name, String? active}) => $apply(
    FieldCopyWithData({
      if (uid != null) #uid: uid,
      if (name != null) #name: name,
      if (active != null) #active: active,
    }),
  );
  @override
  EventTypeEntity $make(CopyWithData data) => EventTypeEntity(
    uid: data.get(#uid, or: $value.uid),
    name: data.get(#name, or: $value.name),
    active: data.get(#active, or: $value.active),
  );

  @override
  EventTypeEntityCopyWith<$R2, EventTypeEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EventTypeEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

