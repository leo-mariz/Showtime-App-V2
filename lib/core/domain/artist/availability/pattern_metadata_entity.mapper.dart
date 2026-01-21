// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pattern_metadata_entity.dart';

class PatternMetadataMapper extends ClassMapperBase<PatternMetadata> {
  PatternMetadataMapper._();

  static PatternMetadataMapper? _instance;
  static PatternMetadataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PatternMetadataMapper._());
      RecurrenceSettingsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PatternMetadata';

  static String _$patternId(PatternMetadata v) => v.patternId;
  static const Field<PatternMetadata, String> _f$patternId = Field(
    'patternId',
    _$patternId,
  );
  static String _$creationType(PatternMetadata v) => v.creationType;
  static const Field<PatternMetadata, String> _f$creationType = Field(
    'creationType',
    _$creationType,
  );
  static RecurrenceSettings? _$recurrence(PatternMetadata v) => v.recurrence;
  static const Field<PatternMetadata, RecurrenceSettings> _f$recurrence = Field(
    'recurrence',
    _$recurrence,
    opt: true,
  );
  static DateTime _$createdAt(PatternMetadata v) => v.createdAt;
  static const Field<PatternMetadata, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime? _$updatedAt(PatternMetadata v) => v.updatedAt;
  static const Field<PatternMetadata, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<PatternMetadata> fields = const {
    #patternId: _f$patternId,
    #creationType: _f$creationType,
    #recurrence: _f$recurrence,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static PatternMetadata _instantiate(DecodingData data) {
    return PatternMetadata(
      patternId: data.dec(_f$patternId),
      creationType: data.dec(_f$creationType),
      recurrence: data.dec(_f$recurrence),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PatternMetadata fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PatternMetadata>(map);
  }

  static PatternMetadata fromJson(String json) {
    return ensureInitialized().decodeJson<PatternMetadata>(json);
  }
}

mixin PatternMetadataMappable {
  String toJson() {
    return PatternMetadataMapper.ensureInitialized()
        .encodeJson<PatternMetadata>(this as PatternMetadata);
  }

  Map<String, dynamic> toMap() {
    return PatternMetadataMapper.ensureInitialized().encodeMap<PatternMetadata>(
      this as PatternMetadata,
    );
  }

  PatternMetadataCopyWith<PatternMetadata, PatternMetadata, PatternMetadata>
  get copyWith =>
      _PatternMetadataCopyWithImpl<PatternMetadata, PatternMetadata>(
        this as PatternMetadata,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PatternMetadataMapper.ensureInitialized().stringifyValue(
      this as PatternMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return PatternMetadataMapper.ensureInitialized().equalsValue(
      this as PatternMetadata,
      other,
    );
  }

  @override
  int get hashCode {
    return PatternMetadataMapper.ensureInitialized().hashValue(
      this as PatternMetadata,
    );
  }
}

extension PatternMetadataValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PatternMetadata, $Out> {
  PatternMetadataCopyWith<$R, PatternMetadata, $Out> get $asPatternMetadata =>
      $base.as((v, t, t2) => _PatternMetadataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PatternMetadataCopyWith<$R, $In extends PatternMetadata, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  RecurrenceSettingsCopyWith<$R, RecurrenceSettings, RecurrenceSettings>?
  get recurrence;
  $R call({
    String? patternId,
    String? creationType,
    RecurrenceSettings? recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  PatternMetadataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PatternMetadataCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PatternMetadata, $Out>
    implements PatternMetadataCopyWith<$R, PatternMetadata, $Out> {
  _PatternMetadataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PatternMetadata> $mapper =
      PatternMetadataMapper.ensureInitialized();
  @override
  RecurrenceSettingsCopyWith<$R, RecurrenceSettings, RecurrenceSettings>?
  get recurrence =>
      $value.recurrence?.copyWith.$chain((v) => call(recurrence: v));
  @override
  $R call({
    String? patternId,
    String? creationType,
    Object? recurrence = $none,
    DateTime? createdAt,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (patternId != null) #patternId: patternId,
      if (creationType != null) #creationType: creationType,
      if (recurrence != $none) #recurrence: recurrence,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  PatternMetadata $make(CopyWithData data) => PatternMetadata(
    patternId: data.get(#patternId, or: $value.patternId),
    creationType: data.get(#creationType, or: $value.creationType),
    recurrence: data.get(#recurrence, or: $value.recurrence),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  PatternMetadataCopyWith<$R2, PatternMetadata, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PatternMetadataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RecurrenceSettingsMapper extends ClassMapperBase<RecurrenceSettings> {
  RecurrenceSettingsMapper._();

  static RecurrenceSettingsMapper? _instance;
  static RecurrenceSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RecurrenceSettingsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'RecurrenceSettings';

  static List<String>? _$weekdays(RecurrenceSettings v) => v.weekdays;
  static const Field<RecurrenceSettings, List<String>> _f$weekdays = Field(
    'weekdays',
    _$weekdays,
    opt: true,
  );
  static DateTime _$originalStartDate(RecurrenceSettings v) =>
      v.originalStartDate;
  static const Field<RecurrenceSettings, DateTime> _f$originalStartDate = Field(
    'originalStartDate',
    _$originalStartDate,
  );
  static DateTime _$originalEndDate(RecurrenceSettings v) => v.originalEndDate;
  static const Field<RecurrenceSettings, DateTime> _f$originalEndDate = Field(
    'originalEndDate',
    _$originalEndDate,
  );
  static String _$originalStartTime(RecurrenceSettings v) =>
      v.originalStartTime;
  static const Field<RecurrenceSettings, String> _f$originalStartTime = Field(
    'originalStartTime',
    _$originalStartTime,
  );
  static String _$originalEndTime(RecurrenceSettings v) => v.originalEndTime;
  static const Field<RecurrenceSettings, String> _f$originalEndTime = Field(
    'originalEndTime',
    _$originalEndTime,
  );
  static double _$originalValorHora(RecurrenceSettings v) =>
      v.originalValorHora;
  static const Field<RecurrenceSettings, double> _f$originalValorHora = Field(
    'originalValorHora',
    _$originalValorHora,
  );
  static String _$originalAddressId(RecurrenceSettings v) =>
      v.originalAddressId;
  static const Field<RecurrenceSettings, String> _f$originalAddressId = Field(
    'originalAddressId',
    _$originalAddressId,
  );

  @override
  final MappableFields<RecurrenceSettings> fields = const {
    #weekdays: _f$weekdays,
    #originalStartDate: _f$originalStartDate,
    #originalEndDate: _f$originalEndDate,
    #originalStartTime: _f$originalStartTime,
    #originalEndTime: _f$originalEndTime,
    #originalValorHora: _f$originalValorHora,
    #originalAddressId: _f$originalAddressId,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static RecurrenceSettings _instantiate(DecodingData data) {
    return RecurrenceSettings(
      weekdays: data.dec(_f$weekdays),
      originalStartDate: data.dec(_f$originalStartDate),
      originalEndDate: data.dec(_f$originalEndDate),
      originalStartTime: data.dec(_f$originalStartTime),
      originalEndTime: data.dec(_f$originalEndTime),
      originalValorHora: data.dec(_f$originalValorHora),
      originalAddressId: data.dec(_f$originalAddressId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RecurrenceSettings fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RecurrenceSettings>(map);
  }

  static RecurrenceSettings fromJson(String json) {
    return ensureInitialized().decodeJson<RecurrenceSettings>(json);
  }
}

mixin RecurrenceSettingsMappable {
  String toJson() {
    return RecurrenceSettingsMapper.ensureInitialized()
        .encodeJson<RecurrenceSettings>(this as RecurrenceSettings);
  }

  Map<String, dynamic> toMap() {
    return RecurrenceSettingsMapper.ensureInitialized()
        .encodeMap<RecurrenceSettings>(this as RecurrenceSettings);
  }

  RecurrenceSettingsCopyWith<
    RecurrenceSettings,
    RecurrenceSettings,
    RecurrenceSettings
  >
  get copyWith =>
      _RecurrenceSettingsCopyWithImpl<RecurrenceSettings, RecurrenceSettings>(
        this as RecurrenceSettings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RecurrenceSettingsMapper.ensureInitialized().stringifyValue(
      this as RecurrenceSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return RecurrenceSettingsMapper.ensureInitialized().equalsValue(
      this as RecurrenceSettings,
      other,
    );
  }

  @override
  int get hashCode {
    return RecurrenceSettingsMapper.ensureInitialized().hashValue(
      this as RecurrenceSettings,
    );
  }
}

extension RecurrenceSettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RecurrenceSettings, $Out> {
  RecurrenceSettingsCopyWith<$R, RecurrenceSettings, $Out>
  get $asRecurrenceSettings => $base.as(
    (v, t, t2) => _RecurrenceSettingsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RecurrenceSettingsCopyWith<
  $R,
  $In extends RecurrenceSettings,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get weekdays;
  $R call({
    List<String>? weekdays,
    DateTime? originalStartDate,
    DateTime? originalEndDate,
    String? originalStartTime,
    String? originalEndTime,
    double? originalValorHora,
    String? originalAddressId,
  });
  RecurrenceSettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RecurrenceSettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RecurrenceSettings, $Out>
    implements RecurrenceSettingsCopyWith<$R, RecurrenceSettings, $Out> {
  _RecurrenceSettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RecurrenceSettings> $mapper =
      RecurrenceSettingsMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get weekdays =>
      $value.weekdays != null
      ? ListCopyWith(
          $value.weekdays!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(weekdays: v),
        )
      : null;
  @override
  $R call({
    Object? weekdays = $none,
    DateTime? originalStartDate,
    DateTime? originalEndDate,
    String? originalStartTime,
    String? originalEndTime,
    double? originalValorHora,
    String? originalAddressId,
  }) => $apply(
    FieldCopyWithData({
      if (weekdays != $none) #weekdays: weekdays,
      if (originalStartDate != null) #originalStartDate: originalStartDate,
      if (originalEndDate != null) #originalEndDate: originalEndDate,
      if (originalStartTime != null) #originalStartTime: originalStartTime,
      if (originalEndTime != null) #originalEndTime: originalEndTime,
      if (originalValorHora != null) #originalValorHora: originalValorHora,
      if (originalAddressId != null) #originalAddressId: originalAddressId,
    }),
  );
  @override
  RecurrenceSettings $make(CopyWithData data) => RecurrenceSettings(
    weekdays: data.get(#weekdays, or: $value.weekdays),
    originalStartDate: data.get(
      #originalStartDate,
      or: $value.originalStartDate,
    ),
    originalEndDate: data.get(#originalEndDate, or: $value.originalEndDate),
    originalStartTime: data.get(
      #originalStartTime,
      or: $value.originalStartTime,
    ),
    originalEndTime: data.get(#originalEndTime, or: $value.originalEndTime),
    originalValorHora: data.get(
      #originalValorHora,
      or: $value.originalValorHora,
    ),
    originalAddressId: data.get(
      #originalAddressId,
      or: $value.originalAddressId,
    ),
  );

  @override
  RecurrenceSettingsCopyWith<$R2, RecurrenceSettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RecurrenceSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

