// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'group_incomplete_sections_entity.dart';

class GroupIncompleteSectionsEntityMapper
    extends ClassMapperBase<GroupIncompleteSectionsEntity> {
  GroupIncompleteSectionsEntityMapper._();

  static GroupIncompleteSectionsEntityMapper? _instance;
  static GroupIncompleteSectionsEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = GroupIncompleteSectionsEntityMapper._(),
      );
      GroupEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GroupIncompleteSectionsEntity';

  static const Field<GroupIncompleteSectionsEntity, GroupEntity> _f$group =
      Field('group', null, mode: FieldMode.param);
  static bool _$hasIncompleteSections(GroupIncompleteSectionsEntity v) =>
      v.hasIncompleteSections;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$hasIncompleteSections = Field(
    'hasIncompleteSections',
    _$hasIncompleteSections,
    mode: FieldMode.member,
  );
  static bool _$incompleteProfilePicture(GroupIncompleteSectionsEntity v) =>
      v.incompleteProfilePicture;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$incompleteProfilePicture = Field(
    'incompleteProfilePicture',
    _$incompleteProfilePicture,
    mode: FieldMode.member,
  );
  static bool _$incompleteGroupName(GroupIncompleteSectionsEntity v) =>
      v.incompleteGroupName;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$incompleteGroupName = Field(
    'incompleteGroupName',
    _$incompleteGroupName,
    mode: FieldMode.member,
  );
  static bool _$incompleteProfessionalInfo(GroupIncompleteSectionsEntity v) =>
      v.incompleteProfessionalInfo;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$incompleteProfessionalInfo = Field(
    'incompleteProfessionalInfo',
    _$incompleteProfessionalInfo,
    mode: FieldMode.member,
  );
  static bool _$incompletePresentationMedias(GroupIncompleteSectionsEntity v) =>
      v.incompletePresentationMedias;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$incompletePresentationMedias = Field(
    'incompletePresentationMedias',
    _$incompletePresentationMedias,
    mode: FieldMode.member,
  );
  static bool _$incompleteMembersApproval(GroupIncompleteSectionsEntity v) =>
      v.incompleteMembersApproval;
  static const Field<GroupIncompleteSectionsEntity, bool>
  _f$incompleteMembersApproval = Field(
    'incompleteMembersApproval',
    _$incompleteMembersApproval,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<GroupIncompleteSectionsEntity> fields = const {
    #group: _f$group,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteProfilePicture: _f$incompleteProfilePicture,
    #incompleteGroupName: _f$incompleteGroupName,
    #incompleteProfessionalInfo: _f$incompleteProfessionalInfo,
    #incompletePresentationMedias: _f$incompletePresentationMedias,
    #incompleteMembersApproval: _f$incompleteMembersApproval,
  };

  static GroupIncompleteSectionsEntity _instantiate(DecodingData data) {
    return GroupIncompleteSectionsEntity.verify(group: data.dec(_f$group));
  }

  @override
  final Function instantiate = _instantiate;

  static GroupIncompleteSectionsEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GroupIncompleteSectionsEntity>(map);
  }

  static GroupIncompleteSectionsEntity fromJson(String json) {
    return ensureInitialized().decodeJson<GroupIncompleteSectionsEntity>(json);
  }
}

mixin GroupIncompleteSectionsEntityMappable {
  String toJson() {
    return GroupIncompleteSectionsEntityMapper.ensureInitialized()
        .encodeJson<GroupIncompleteSectionsEntity>(
          this as GroupIncompleteSectionsEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return GroupIncompleteSectionsEntityMapper.ensureInitialized()
        .encodeMap<GroupIncompleteSectionsEntity>(
          this as GroupIncompleteSectionsEntity,
        );
  }

  GroupIncompleteSectionsEntityCopyWith<
    GroupIncompleteSectionsEntity,
    GroupIncompleteSectionsEntity,
    GroupIncompleteSectionsEntity
  >
  get copyWith =>
      _GroupIncompleteSectionsEntityCopyWithImpl<
        GroupIncompleteSectionsEntity,
        GroupIncompleteSectionsEntity
      >(this as GroupIncompleteSectionsEntity, $identity, $identity);
  @override
  String toString() {
    return GroupIncompleteSectionsEntityMapper.ensureInitialized()
        .stringifyValue(this as GroupIncompleteSectionsEntity);
  }

  @override
  bool operator ==(Object other) {
    return GroupIncompleteSectionsEntityMapper.ensureInitialized().equalsValue(
      this as GroupIncompleteSectionsEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return GroupIncompleteSectionsEntityMapper.ensureInitialized().hashValue(
      this as GroupIncompleteSectionsEntity,
    );
  }
}

extension GroupIncompleteSectionsEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GroupIncompleteSectionsEntity, $Out> {
  GroupIncompleteSectionsEntityCopyWith<$R, GroupIncompleteSectionsEntity, $Out>
  get $asGroupIncompleteSectionsEntity => $base.as(
    (v, t, t2) =>
        _GroupIncompleteSectionsEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class GroupIncompleteSectionsEntityCopyWith<
  $R,
  $In extends GroupIncompleteSectionsEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({required GroupEntity group});
  GroupIncompleteSectionsEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GroupIncompleteSectionsEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GroupIncompleteSectionsEntity, $Out>
    implements
        GroupIncompleteSectionsEntityCopyWith<
          $R,
          GroupIncompleteSectionsEntity,
          $Out
        > {
  _GroupIncompleteSectionsEntityCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<GroupIncompleteSectionsEntity> $mapper =
      GroupIncompleteSectionsEntityMapper.ensureInitialized();
  @override
  $R call({required GroupEntity group}) =>
      $apply(FieldCopyWithData({#group: group}));
  @override
  GroupIncompleteSectionsEntity $make(CopyWithData data) =>
      GroupIncompleteSectionsEntity.verify(group: data.get(#group));

  @override
  GroupIncompleteSectionsEntityCopyWith<
    $R2,
    GroupIncompleteSectionsEntity,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GroupIncompleteSectionsEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

