// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'time_slot_entity.dart';

class TimeSlotMapper extends ClassMapperBase<TimeSlot> {
  TimeSlotMapper._();

  static TimeSlotMapper? _instance;
  static TimeSlotMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TimeSlotMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TimeSlot';

  static String _$slotId(TimeSlot v) => v.slotId;
  static const Field<TimeSlot, String> _f$slotId = Field('slotId', _$slotId);
  static String _$startTime(TimeSlot v) => v.startTime;
  static const Field<TimeSlot, String> _f$startTime = Field(
    'startTime',
    _$startTime,
  );
  static String _$endTime(TimeSlot v) => v.endTime;
  static const Field<TimeSlot, String> _f$endTime = Field('endTime', _$endTime);
  static String _$status(TimeSlot v) => v.status;
  static const Field<TimeSlot, String> _f$status = Field('status', _$status);
  static double? _$valorHora(TimeSlot v) => v.valorHora;
  static const Field<TimeSlot, double> _f$valorHora = Field(
    'valorHora',
    _$valorHora,
    opt: true,
  );
  static String? _$blockReason(TimeSlot v) => v.blockReason;
  static const Field<TimeSlot, String> _f$blockReason = Field(
    'blockReason',
    _$blockReason,
    opt: true,
  );
  static String? _$bookingId(TimeSlot v) => v.bookingId;
  static const Field<TimeSlot, String> _f$bookingId = Field(
    'bookingId',
    _$bookingId,
    opt: true,
  );
  static String? _$sourcePatternId(TimeSlot v) => v.sourcePatternId;
  static const Field<TimeSlot, String> _f$sourcePatternId = Field(
    'sourcePatternId',
    _$sourcePatternId,
    opt: true,
  );

  @override
  final MappableFields<TimeSlot> fields = const {
    #slotId: _f$slotId,
    #startTime: _f$startTime,
    #endTime: _f$endTime,
    #status: _f$status,
    #valorHora: _f$valorHora,
    #blockReason: _f$blockReason,
    #bookingId: _f$bookingId,
    #sourcePatternId: _f$sourcePatternId,
  };

  static TimeSlot _instantiate(DecodingData data) {
    return TimeSlot(
      slotId: data.dec(_f$slotId),
      startTime: data.dec(_f$startTime),
      endTime: data.dec(_f$endTime),
      status: data.dec(_f$status),
      valorHora: data.dec(_f$valorHora),
      blockReason: data.dec(_f$blockReason),
      bookingId: data.dec(_f$bookingId),
      sourcePatternId: data.dec(_f$sourcePatternId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TimeSlot fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TimeSlot>(map);
  }

  static TimeSlot fromJson(String json) {
    return ensureInitialized().decodeJson<TimeSlot>(json);
  }
}

mixin TimeSlotMappable {
  String toJson() {
    return TimeSlotMapper.ensureInitialized().encodeJson<TimeSlot>(
      this as TimeSlot,
    );
  }

  Map<String, dynamic> toMap() {
    return TimeSlotMapper.ensureInitialized().encodeMap<TimeSlot>(
      this as TimeSlot,
    );
  }

  TimeSlotCopyWith<TimeSlot, TimeSlot, TimeSlot> get copyWith =>
      _TimeSlotCopyWithImpl<TimeSlot, TimeSlot>(
        this as TimeSlot,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TimeSlotMapper.ensureInitialized().stringifyValue(this as TimeSlot);
  }

  @override
  bool operator ==(Object other) {
    return TimeSlotMapper.ensureInitialized().equalsValue(
      this as TimeSlot,
      other,
    );
  }

  @override
  int get hashCode {
    return TimeSlotMapper.ensureInitialized().hashValue(this as TimeSlot);
  }
}

extension TimeSlotValueCopy<$R, $Out> on ObjectCopyWith<$R, TimeSlot, $Out> {
  TimeSlotCopyWith<$R, TimeSlot, $Out> get $asTimeSlot =>
      $base.as((v, t, t2) => _TimeSlotCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TimeSlotCopyWith<$R, $In extends TimeSlot, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? slotId,
    String? startTime,
    String? endTime,
    String? status,
    double? valorHora,
    String? blockReason,
    String? bookingId,
    String? sourcePatternId,
  });
  TimeSlotCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TimeSlotCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TimeSlot, $Out>
    implements TimeSlotCopyWith<$R, TimeSlot, $Out> {
  _TimeSlotCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TimeSlot> $mapper =
      TimeSlotMapper.ensureInitialized();
  @override
  $R call({
    String? slotId,
    String? startTime,
    String? endTime,
    String? status,
    Object? valorHora = $none,
    Object? blockReason = $none,
    Object? bookingId = $none,
    Object? sourcePatternId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (slotId != null) #slotId: slotId,
      if (startTime != null) #startTime: startTime,
      if (endTime != null) #endTime: endTime,
      if (status != null) #status: status,
      if (valorHora != $none) #valorHora: valorHora,
      if (blockReason != $none) #blockReason: blockReason,
      if (bookingId != $none) #bookingId: bookingId,
      if (sourcePatternId != $none) #sourcePatternId: sourcePatternId,
    }),
  );
  @override
  TimeSlot $make(CopyWithData data) => TimeSlot(
    slotId: data.get(#slotId, or: $value.slotId),
    startTime: data.get(#startTime, or: $value.startTime),
    endTime: data.get(#endTime, or: $value.endTime),
    status: data.get(#status, or: $value.status),
    valorHora: data.get(#valorHora, or: $value.valorHora),
    blockReason: data.get(#blockReason, or: $value.blockReason),
    bookingId: data.get(#bookingId, or: $value.bookingId),
    sourcePatternId: data.get(#sourcePatternId, or: $value.sourcePatternId),
  );

  @override
  TimeSlotCopyWith<$R2, TimeSlot, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TimeSlotCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

