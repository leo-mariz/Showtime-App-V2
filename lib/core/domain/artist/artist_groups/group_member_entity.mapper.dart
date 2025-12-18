// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'group_member_entity.dart';

class GroupMemberEntityMapper extends ClassMapperBase<GroupMemberEntity> {
  GroupMemberEntityMapper._();

  static GroupMemberEntityMapper? _instance;
  static GroupMemberEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GroupMemberEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GroupMemberEntity';

  static String? _$artistUid(GroupMemberEntity v) => v.artistUid;
  static const Field<GroupMemberEntity, String> _f$artistUid = Field(
    'artistUid',
    _$artistUid,
    opt: true,
  );
  static int _$inviteStatus(GroupMemberEntity v) => v.inviteStatus;
  static const Field<GroupMemberEntity, int> _f$inviteStatus = Field(
    'inviteStatus',
    _$inviteStatus,
    opt: true,
    def: 0,
  );
  static bool _$isAdmin(GroupMemberEntity v) => v.isAdmin;
  static const Field<GroupMemberEntity, bool> _f$isAdmin = Field(
    'isAdmin',
    _$isAdmin,
    opt: true,
    def: false,
  );
  static bool _$isApproved(GroupMemberEntity v) => v.isApproved;
  static const Field<GroupMemberEntity, bool> _f$isApproved = Field(
    'isApproved',
    _$isApproved,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<GroupMemberEntity> fields = const {
    #artistUid: _f$artistUid,
    #inviteStatus: _f$inviteStatus,
    #isAdmin: _f$isAdmin,
    #isApproved: _f$isApproved,
  };

  static GroupMemberEntity _instantiate(DecodingData data) {
    return GroupMemberEntity(
      artistUid: data.dec(_f$artistUid),
      inviteStatus: data.dec(_f$inviteStatus),
      isAdmin: data.dec(_f$isAdmin),
      isApproved: data.dec(_f$isApproved),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GroupMemberEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GroupMemberEntity>(map);
  }

  static GroupMemberEntity fromJson(String json) {
    return ensureInitialized().decodeJson<GroupMemberEntity>(json);
  }
}

mixin GroupMemberEntityMappable {
  String toJson() {
    return GroupMemberEntityMapper.ensureInitialized()
        .encodeJson<GroupMemberEntity>(this as GroupMemberEntity);
  }

  Map<String, dynamic> toMap() {
    return GroupMemberEntityMapper.ensureInitialized()
        .encodeMap<GroupMemberEntity>(this as GroupMemberEntity);
  }

  GroupMemberEntityCopyWith<
    GroupMemberEntity,
    GroupMemberEntity,
    GroupMemberEntity
  >
  get copyWith =>
      _GroupMemberEntityCopyWithImpl<GroupMemberEntity, GroupMemberEntity>(
        this as GroupMemberEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GroupMemberEntityMapper.ensureInitialized().stringifyValue(
      this as GroupMemberEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return GroupMemberEntityMapper.ensureInitialized().equalsValue(
      this as GroupMemberEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return GroupMemberEntityMapper.ensureInitialized().hashValue(
      this as GroupMemberEntity,
    );
  }
}

extension GroupMemberEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GroupMemberEntity, $Out> {
  GroupMemberEntityCopyWith<$R, GroupMemberEntity, $Out>
  get $asGroupMemberEntity => $base.as(
    (v, t, t2) => _GroupMemberEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class GroupMemberEntityCopyWith<
  $R,
  $In extends GroupMemberEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? artistUid,
    int? inviteStatus,
    bool? isAdmin,
    bool? isApproved,
  });
  GroupMemberEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GroupMemberEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GroupMemberEntity, $Out>
    implements GroupMemberEntityCopyWith<$R, GroupMemberEntity, $Out> {
  _GroupMemberEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GroupMemberEntity> $mapper =
      GroupMemberEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? artistUid = $none,
    int? inviteStatus,
    bool? isAdmin,
    bool? isApproved,
  }) => $apply(
    FieldCopyWithData({
      if (artistUid != $none) #artistUid: artistUid,
      if (inviteStatus != null) #inviteStatus: inviteStatus,
      if (isAdmin != null) #isAdmin: isAdmin,
      if (isApproved != null) #isApproved: isApproved,
    }),
  );
  @override
  GroupMemberEntity $make(CopyWithData data) => GroupMemberEntity(
    artistUid: data.get(#artistUid, or: $value.artistUid),
    inviteStatus: data.get(#inviteStatus, or: $value.inviteStatus),
    isAdmin: data.get(#isAdmin, or: $value.isAdmin),
    isApproved: data.get(#isApproved, or: $value.isApproved),
  );

  @override
  GroupMemberEntityCopyWith<$R2, GroupMemberEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GroupMemberEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

