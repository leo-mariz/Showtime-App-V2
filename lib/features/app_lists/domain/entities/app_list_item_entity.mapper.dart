// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_list_item_entity.dart';

class AppListItemEntityMapper extends ClassMapperBase<AppListItemEntity> {
  AppListItemEntityMapper._();

  static AppListItemEntityMapper? _instance;
  static AppListItemEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppListItemEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppListItemEntity';

  static String? _$id(AppListItemEntity v) => v.id;
  static const Field<AppListItemEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static String _$name(AppListItemEntity v) => v.name;
  static const Field<AppListItemEntity, String> _f$name = Field('name', _$name);
  static String? _$description(AppListItemEntity v) => v.description;
  static const Field<AppListItemEntity, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static int? _$order(AppListItemEntity v) => v.order;
  static const Field<AppListItemEntity, int> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );
  static bool _$isActive(AppListItemEntity v) => v.isActive;
  static const Field<AppListItemEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static DateTime? _$createdAt(AppListItemEntity v) => v.createdAt;
  static const Field<AppListItemEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );
  static DateTime? _$updatedAt(AppListItemEntity v) => v.updatedAt;
  static const Field<AppListItemEntity, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<AppListItemEntity> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #order: _f$order,
    #isActive: _f$isActive,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static AppListItemEntity _instantiate(DecodingData data) {
    return AppListItemEntity(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      order: data.dec(_f$order),
      isActive: data.dec(_f$isActive),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppListItemEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppListItemEntity>(map);
  }

  static AppListItemEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AppListItemEntity>(json);
  }
}

mixin AppListItemEntityMappable {
  String toJson() {
    return AppListItemEntityMapper.ensureInitialized()
        .encodeJson<AppListItemEntity>(this as AppListItemEntity);
  }

  Map<String, dynamic> toMap() {
    return AppListItemEntityMapper.ensureInitialized()
        .encodeMap<AppListItemEntity>(this as AppListItemEntity);
  }

  AppListItemEntityCopyWith<
    AppListItemEntity,
    AppListItemEntity,
    AppListItemEntity
  >
  get copyWith =>
      _AppListItemEntityCopyWithImpl<AppListItemEntity, AppListItemEntity>(
        this as AppListItemEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppListItemEntityMapper.ensureInitialized().stringifyValue(
      this as AppListItemEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return AppListItemEntityMapper.ensureInitialized().equalsValue(
      this as AppListItemEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return AppListItemEntityMapper.ensureInitialized().hashValue(
      this as AppListItemEntity,
    );
  }
}

extension AppListItemEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AppListItemEntity, $Out> {
  AppListItemEntityCopyWith<$R, AppListItemEntity, $Out>
  get $asAppListItemEntity => $base.as(
    (v, t, t2) => _AppListItemEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AppListItemEntityCopyWith<
  $R,
  $In extends AppListItemEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? description,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  AppListItemEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AppListItemEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppListItemEntity, $Out>
    implements AppListItemEntityCopyWith<$R, AppListItemEntity, $Out> {
  _AppListItemEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppListItemEntity> $mapper =
      AppListItemEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    String? name,
    Object? description = $none,
    Object? order = $none,
    bool? isActive,
    Object? createdAt = $none,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (order != $none) #order: order,
      if (isActive != null) #isActive: isActive,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  AppListItemEntity $make(CopyWithData data) => AppListItemEntity(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    order: data.get(#order, or: $value.order),
    isActive: data.get(#isActive, or: $value.isActive),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  AppListItemEntityCopyWith<$R2, AppListItemEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppListItemEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

