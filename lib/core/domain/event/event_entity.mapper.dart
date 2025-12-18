// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'event_entity.dart';

class EventEntityMapper extends ClassMapperBase<EventEntity> {
  EventEntityMapper._();

  static EventEntityMapper? _instance;
  static EventEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EventEntityMapper._());
      AddressInfoEntityMapper.ensureInitialized();
      EventTypeEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EventEntity';

  static DateTime? _$date(EventEntity v) => v.date;
  static const Field<EventEntity, DateTime> _f$date = Field('date', _$date);
  static String _$time(EventEntity v) => v.time;
  static const Field<EventEntity, String> _f$time = Field('time', _$time);
  static int _$duration(EventEntity v) => v.duration;
  static const Field<EventEntity, int> _f$duration = Field(
    'duration',
    _$duration,
  );
  static AddressInfoEntity? _$address(EventEntity v) => v.address;
  static const Field<EventEntity, AddressInfoEntity> _f$address = Field(
    'address',
    _$address,
  );
  static String? _$uid(EventEntity v) => v.uid;
  static const Field<EventEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String? _$refArtist(EventEntity v) => v.refArtist;
  static const Field<EventEntity, String> _f$refArtist = Field(
    'refArtist',
    _$refArtist,
    opt: true,
  );
  static String? _$refContractor(EventEntity v) => v.refContractor;
  static const Field<EventEntity, String> _f$refContractor = Field(
    'refContractor',
    _$refContractor,
    opt: true,
  );
  static String? _$nameArtist(EventEntity v) => v.nameArtist;
  static const Field<EventEntity, String> _f$nameArtist = Field(
    'nameArtist',
    _$nameArtist,
    opt: true,
  );
  static String? _$nameContractor(EventEntity v) => v.nameContractor;
  static const Field<EventEntity, String> _f$nameContractor = Field(
    'nameContractor',
    _$nameContractor,
    opt: true,
  );
  static String _$status(EventEntity v) => v.status;
  static const Field<EventEntity, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: "PENDING",
  );
  static EventTypeEntity? _$eventType(EventEntity v) => v.eventType;
  static const Field<EventEntity, EventTypeEntity> _f$eventType = Field(
    'eventType',
    _$eventType,
    opt: true,
  );
  static String _$statusPayment(EventEntity v) => v.statusPayment;
  static const Field<EventEntity, String> _f$statusPayment = Field(
    'statusPayment',
    _$statusPayment,
    opt: true,
    def: "PENDING",
  );
  static String _$linkPayment(EventEntity v) => v.linkPayment;
  static const Field<EventEntity, String> _f$linkPayment = Field(
    'linkPayment',
    _$linkPayment,
    opt: true,
    def: "",
  );
  static double _$value(EventEntity v) => v.value;
  static const Field<EventEntity, double> _f$value = Field(
    'value',
    _$value,
    opt: true,
    def: 0.0,
  );
  static String? _$keyCode(EventEntity v) => v.keyCode;
  static const Field<EventEntity, String> _f$keyCode = Field(
    'keyCode',
    _$keyCode,
    opt: true,
  );
  static double _$rating(EventEntity v) => v.rating;
  static const Field<EventEntity, double> _f$rating = Field(
    'rating',
    _$rating,
    opt: true,
    def: 0.0,
  );

  @override
  final MappableFields<EventEntity> fields = const {
    #date: _f$date,
    #time: _f$time,
    #duration: _f$duration,
    #address: _f$address,
    #uid: _f$uid,
    #refArtist: _f$refArtist,
    #refContractor: _f$refContractor,
    #nameArtist: _f$nameArtist,
    #nameContractor: _f$nameContractor,
    #status: _f$status,
    #eventType: _f$eventType,
    #statusPayment: _f$statusPayment,
    #linkPayment: _f$linkPayment,
    #value: _f$value,
    #keyCode: _f$keyCode,
    #rating: _f$rating,
  };

  static EventEntity _instantiate(DecodingData data) {
    return EventEntity(
      date: data.dec(_f$date),
      time: data.dec(_f$time),
      duration: data.dec(_f$duration),
      address: data.dec(_f$address),
      uid: data.dec(_f$uid),
      refArtist: data.dec(_f$refArtist),
      refContractor: data.dec(_f$refContractor),
      nameArtist: data.dec(_f$nameArtist),
      nameContractor: data.dec(_f$nameContractor),
      status: data.dec(_f$status),
      eventType: data.dec(_f$eventType),
      statusPayment: data.dec(_f$statusPayment),
      linkPayment: data.dec(_f$linkPayment),
      value: data.dec(_f$value),
      keyCode: data.dec(_f$keyCode),
      rating: data.dec(_f$rating),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EventEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EventEntity>(map);
  }

  static EventEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EventEntity>(json);
  }
}

mixin EventEntityMappable {
  String toJson() {
    return EventEntityMapper.ensureInitialized().encodeJson<EventEntity>(
      this as EventEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return EventEntityMapper.ensureInitialized().encodeMap<EventEntity>(
      this as EventEntity,
    );
  }

  EventEntityCopyWith<EventEntity, EventEntity, EventEntity> get copyWith =>
      _EventEntityCopyWithImpl<EventEntity, EventEntity>(
        this as EventEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EventEntityMapper.ensureInitialized().stringifyValue(
      this as EventEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EventEntityMapper.ensureInitialized().equalsValue(
      this as EventEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EventEntityMapper.ensureInitialized().hashValue(this as EventEntity);
  }
}

extension EventEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EventEntity, $Out> {
  EventEntityCopyWith<$R, EventEntity, $Out> get $asEventEntity =>
      $base.as((v, t, t2) => _EventEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EventEntityCopyWith<$R, $In extends EventEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get address;
  EventTypeEntityCopyWith<$R, EventTypeEntity, EventTypeEntity>? get eventType;
  $R call({
    DateTime? date,
    String? time,
    int? duration,
    AddressInfoEntity? address,
    String? uid,
    String? refArtist,
    String? refContractor,
    String? nameArtist,
    String? nameContractor,
    String? status,
    EventTypeEntity? eventType,
    String? statusPayment,
    String? linkPayment,
    double? value,
    String? keyCode,
    double? rating,
  });
  EventEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EventEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EventEntity, $Out>
    implements EventEntityCopyWith<$R, EventEntity, $Out> {
  _EventEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EventEntity> $mapper =
      EventEntityMapper.ensureInitialized();
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get address => $value.address?.copyWith.$chain((v) => call(address: v));
  @override
  EventTypeEntityCopyWith<$R, EventTypeEntity, EventTypeEntity>?
  get eventType => $value.eventType?.copyWith.$chain((v) => call(eventType: v));
  @override
  $R call({
    Object? date = $none,
    String? time,
    int? duration,
    Object? address = $none,
    Object? uid = $none,
    Object? refArtist = $none,
    Object? refContractor = $none,
    Object? nameArtist = $none,
    Object? nameContractor = $none,
    String? status,
    Object? eventType = $none,
    String? statusPayment,
    String? linkPayment,
    double? value,
    Object? keyCode = $none,
    double? rating,
  }) => $apply(
    FieldCopyWithData({
      if (date != $none) #date: date,
      if (time != null) #time: time,
      if (duration != null) #duration: duration,
      if (address != $none) #address: address,
      if (uid != $none) #uid: uid,
      if (refArtist != $none) #refArtist: refArtist,
      if (refContractor != $none) #refContractor: refContractor,
      if (nameArtist != $none) #nameArtist: nameArtist,
      if (nameContractor != $none) #nameContractor: nameContractor,
      if (status != null) #status: status,
      if (eventType != $none) #eventType: eventType,
      if (statusPayment != null) #statusPayment: statusPayment,
      if (linkPayment != null) #linkPayment: linkPayment,
      if (value != null) #value: value,
      if (keyCode != $none) #keyCode: keyCode,
      if (rating != null) #rating: rating,
    }),
  );
  @override
  EventEntity $make(CopyWithData data) => EventEntity(
    date: data.get(#date, or: $value.date),
    time: data.get(#time, or: $value.time),
    duration: data.get(#duration, or: $value.duration),
    address: data.get(#address, or: $value.address),
    uid: data.get(#uid, or: $value.uid),
    refArtist: data.get(#refArtist, or: $value.refArtist),
    refContractor: data.get(#refContractor, or: $value.refContractor),
    nameArtist: data.get(#nameArtist, or: $value.nameArtist),
    nameContractor: data.get(#nameContractor, or: $value.nameContractor),
    status: data.get(#status, or: $value.status),
    eventType: data.get(#eventType, or: $value.eventType),
    statusPayment: data.get(#statusPayment, or: $value.statusPayment),
    linkPayment: data.get(#linkPayment, or: $value.linkPayment),
    value: data.get(#value, or: $value.value),
    keyCode: data.get(#keyCode, or: $value.keyCode),
    rating: data.get(#rating, or: $value.rating),
  );

  @override
  EventEntityCopyWith<$R2, EventEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EventEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

