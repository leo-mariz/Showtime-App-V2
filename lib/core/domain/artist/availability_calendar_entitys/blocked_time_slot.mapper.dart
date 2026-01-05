// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'blocked_time_slot.dart';

class BlockedTimeSlotMapper extends ClassMapperBase<BlockedTimeSlot> {
  BlockedTimeSlotMapper._();

  static BlockedTimeSlotMapper? _instance;
  static BlockedTimeSlotMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BlockedTimeSlotMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BlockedTimeSlot';

  static DateTime _$date(BlockedTimeSlot v) => v.date;
  static const Field<BlockedTimeSlot, DateTime> _f$date = Field('date', _$date);
  static String _$startTime(BlockedTimeSlot v) => v.startTime;
  static const Field<BlockedTimeSlot, String> _f$startTime = Field(
    'startTime',
    _$startTime,
  );
  static String _$endTime(BlockedTimeSlot v) => v.endTime;
  static const Field<BlockedTimeSlot, String> _f$endTime = Field(
    'endTime',
    _$endTime,
  );
  static String? _$note(BlockedTimeSlot v) => v.note;
  static const Field<BlockedTimeSlot, String> _f$note = Field(
    'note',
    _$note,
    opt: true,
  );

  @override
  final MappableFields<BlockedTimeSlot> fields = const {
    #date: _f$date,
    #startTime: _f$startTime,
    #endTime: _f$endTime,
    #note: _f$note,
  };

  static BlockedTimeSlot _instantiate(DecodingData data) {
    return BlockedTimeSlot(
      date: data.dec(_f$date),
      startTime: data.dec(_f$startTime),
      endTime: data.dec(_f$endTime),
      note: data.dec(_f$note),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BlockedTimeSlot fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BlockedTimeSlot>(map);
  }

  static BlockedTimeSlot fromJson(String json) {
    return ensureInitialized().decodeJson<BlockedTimeSlot>(json);
  }
}

mixin BlockedTimeSlotMappable {
  String toJson() {
    return BlockedTimeSlotMapper.ensureInitialized()
        .encodeJson<BlockedTimeSlot>(this as BlockedTimeSlot);
  }

  Map<String, dynamic> toMap() {
    return BlockedTimeSlotMapper.ensureInitialized().encodeMap<BlockedTimeSlot>(
      this as BlockedTimeSlot,
    );
  }

  BlockedTimeSlotCopyWith<BlockedTimeSlot, BlockedTimeSlot, BlockedTimeSlot>
  get copyWith =>
      _BlockedTimeSlotCopyWithImpl<BlockedTimeSlot, BlockedTimeSlot>(
        this as BlockedTimeSlot,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BlockedTimeSlotMapper.ensureInitialized().stringifyValue(
      this as BlockedTimeSlot,
    );
  }

  @override
  bool operator ==(Object other) {
    return BlockedTimeSlotMapper.ensureInitialized().equalsValue(
      this as BlockedTimeSlot,
      other,
    );
  }

  @override
  int get hashCode {
    return BlockedTimeSlotMapper.ensureInitialized().hashValue(
      this as BlockedTimeSlot,
    );
  }
}

extension BlockedTimeSlotValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BlockedTimeSlot, $Out> {
  BlockedTimeSlotCopyWith<$R, BlockedTimeSlot, $Out> get $asBlockedTimeSlot =>
      $base.as((v, t, t2) => _BlockedTimeSlotCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BlockedTimeSlotCopyWith<$R, $In extends BlockedTimeSlot, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? date, String? startTime, String? endTime, String? note});
  BlockedTimeSlotCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BlockedTimeSlotCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BlockedTimeSlot, $Out>
    implements BlockedTimeSlotCopyWith<$R, BlockedTimeSlot, $Out> {
  _BlockedTimeSlotCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BlockedTimeSlot> $mapper =
      BlockedTimeSlotMapper.ensureInitialized();
  @override
  $R call({
    DateTime? date,
    String? startTime,
    String? endTime,
    Object? note = $none,
  }) => $apply(
    FieldCopyWithData({
      if (date != null) #date: date,
      if (startTime != null) #startTime: startTime,
      if (endTime != null) #endTime: endTime,
      if (note != $none) #note: note,
    }),
  );
  @override
  BlockedTimeSlot $make(CopyWithData data) => BlockedTimeSlot(
    date: data.get(#date, or: $value.date),
    startTime: data.get(#startTime, or: $value.startTime),
    endTime: data.get(#endTime, or: $value.endTime),
    note: data.get(#note, or: $value.note),
  );

  @override
  BlockedTimeSlotCopyWith<$R2, BlockedTimeSlot, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BlockedTimeSlotCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

