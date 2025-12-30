// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'group_entity.dart';

class GroupEntityMapper extends ClassMapperBase<GroupEntity> {
  GroupEntityMapper._();

  static GroupEntityMapper? _instance;
  static GroupEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GroupEntityMapper._());
      ProfessionalInfoEntityMapper.ensureInitialized();
      GroupMemberEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GroupEntity';

  static String? _$uid(GroupEntity v) => v.uid;
  static const Field<GroupEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String? _$profilePicture(GroupEntity v) => v.profilePicture;
  static const Field<GroupEntity, String> _f$profilePicture = Field(
    'profilePicture',
    _$profilePicture,
    opt: true,
  );
  static String? _$groupName(GroupEntity v) => v.groupName;
  static const Field<GroupEntity, String> _f$groupName = Field(
    'groupName',
    _$groupName,
    opt: true,
  );
  static ProfessionalInfoEntity? _$professionalInfo(GroupEntity v) =>
      v.professionalInfo;
  static const Field<GroupEntity, ProfessionalInfoEntity> _f$professionalInfo =
      Field('professionalInfo', _$professionalInfo, opt: true);
  static Map<String, String>? _$presentationMedias(GroupEntity v) =>
      v.presentationMedias;
  static const Field<GroupEntity, Map<String, String>> _f$presentationMedias =
      Field('presentationMedias', _$presentationMedias, opt: true);
  static DateTime? _$dateRegistered(GroupEntity v) => v.dateRegistered;
  static const Field<GroupEntity, DateTime> _f$dateRegistered = Field(
    'dateRegistered',
    _$dateRegistered,
    opt: true,
  );
  static bool? _$isActive(GroupEntity v) => v.isActive;
  static const Field<GroupEntity, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
  );
  static bool? _$hasIncompleteSections(GroupEntity v) =>
      v.hasIncompleteSections;
  static const Field<GroupEntity, bool> _f$hasIncompleteSections = Field(
    'hasIncompleteSections',
    _$hasIncompleteSections,
    opt: true,
  );
  static Map<String, List<String>>? _$incompleteSections(GroupEntity v) =>
      v.incompleteSections;
  static const Field<GroupEntity, Map<String, List<String>>>
  _f$incompleteSections = Field(
    'incompleteSections',
    _$incompleteSections,
    opt: true,
  );
  static List<GroupMemberEntity>? _$members(GroupEntity v) => v.members;
  static const Field<GroupEntity, List<GroupMemberEntity>> _f$members = Field(
    'members',
    _$members,
    opt: true,
  );
  static List<String>? _$invitationEmails(GroupEntity v) => v.invitationEmails;
  static const Field<GroupEntity, List<String>> _f$invitationEmails = Field(
    'invitationEmails',
    _$invitationEmails,
    opt: true,
  );

  @override
  final MappableFields<GroupEntity> fields = const {
    #uid: _f$uid,
    #profilePicture: _f$profilePicture,
    #groupName: _f$groupName,
    #professionalInfo: _f$professionalInfo,
    #presentationMedias: _f$presentationMedias,
    #dateRegistered: _f$dateRegistered,
    #isActive: _f$isActive,
    #hasIncompleteSections: _f$hasIncompleteSections,
    #incompleteSections: _f$incompleteSections,
    #members: _f$members,
    #invitationEmails: _f$invitationEmails,
  };

  static GroupEntity _instantiate(DecodingData data) {
    return GroupEntity(
      uid: data.dec(_f$uid),
      profilePicture: data.dec(_f$profilePicture),
      groupName: data.dec(_f$groupName),
      professionalInfo: data.dec(_f$professionalInfo),
      presentationMedias: data.dec(_f$presentationMedias),
      dateRegistered: data.dec(_f$dateRegistered),
      isActive: data.dec(_f$isActive),
      hasIncompleteSections: data.dec(_f$hasIncompleteSections),
      incompleteSections: data.dec(_f$incompleteSections),
      members: data.dec(_f$members),
      invitationEmails: data.dec(_f$invitationEmails),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GroupEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GroupEntity>(map);
  }

  static GroupEntity fromJson(String json) {
    return ensureInitialized().decodeJson<GroupEntity>(json);
  }
}

mixin GroupEntityMappable {
  String toJson() {
    return GroupEntityMapper.ensureInitialized().encodeJson<GroupEntity>(
      this as GroupEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return GroupEntityMapper.ensureInitialized().encodeMap<GroupEntity>(
      this as GroupEntity,
    );
  }

  GroupEntityCopyWith<GroupEntity, GroupEntity, GroupEntity> get copyWith =>
      _GroupEntityCopyWithImpl<GroupEntity, GroupEntity>(
        this as GroupEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GroupEntityMapper.ensureInitialized().stringifyValue(
      this as GroupEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return GroupEntityMapper.ensureInitialized().equalsValue(
      this as GroupEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return GroupEntityMapper.ensureInitialized().hashValue(this as GroupEntity);
  }
}

extension GroupEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GroupEntity, $Out> {
  GroupEntityCopyWith<$R, GroupEntity, $Out> get $asGroupEntity =>
      $base.as((v, t, t2) => _GroupEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GroupEntityCopyWith<$R, $In extends GroupEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfessionalInfoEntityCopyWith<
    $R,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >?
  get professionalInfo;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get presentationMedias;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections;
  ListCopyWith<
    $R,
    GroupMemberEntity,
    GroupMemberEntityCopyWith<$R, GroupMemberEntity, GroupMemberEntity>
  >?
  get members;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get invitationEmails;
  $R call({
    String? uid,
    String? profilePicture,
    String? groupName,
    ProfessionalInfoEntity? professionalInfo,
    Map<String, String>? presentationMedias,
    DateTime? dateRegistered,
    bool? isActive,
    bool? hasIncompleteSections,
    Map<String, List<String>>? incompleteSections,
    List<GroupMemberEntity>? members,
    List<String>? invitationEmails,
  });
  GroupEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GroupEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GroupEntity, $Out>
    implements GroupEntityCopyWith<$R, GroupEntity, $Out> {
  _GroupEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GroupEntity> $mapper =
      GroupEntityMapper.ensureInitialized();
  @override
  ProfessionalInfoEntityCopyWith<
    $R,
    ProfessionalInfoEntity,
    ProfessionalInfoEntity
  >?
  get professionalInfo => $value.professionalInfo?.copyWith.$chain(
    (v) => call(professionalInfo: v),
  );
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get presentationMedias => $value.presentationMedias != null
      ? MapCopyWith(
          $value.presentationMedias!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(presentationMedias: v),
        )
      : null;
  @override
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >?
  get incompleteSections => $value.incompleteSections != null
      ? MapCopyWith(
          $value.incompleteSections!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(incompleteSections: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    GroupMemberEntity,
    GroupMemberEntityCopyWith<$R, GroupMemberEntity, GroupMemberEntity>
  >?
  get members => $value.members != null
      ? ListCopyWith(
          $value.members!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(members: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get invitationEmails => $value.invitationEmails != null
      ? ListCopyWith(
          $value.invitationEmails!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(invitationEmails: v),
        )
      : null;
  @override
  $R call({
    Object? uid = $none,
    Object? profilePicture = $none,
    Object? groupName = $none,
    Object? professionalInfo = $none,
    Object? presentationMedias = $none,
    Object? dateRegistered = $none,
    Object? isActive = $none,
    Object? hasIncompleteSections = $none,
    Object? incompleteSections = $none,
    Object? members = $none,
    Object? invitationEmails = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (groupName != $none) #groupName: groupName,
      if (professionalInfo != $none) #professionalInfo: professionalInfo,
      if (presentationMedias != $none) #presentationMedias: presentationMedias,
      if (dateRegistered != $none) #dateRegistered: dateRegistered,
      if (isActive != $none) #isActive: isActive,
      if (hasIncompleteSections != $none)
        #hasIncompleteSections: hasIncompleteSections,
      if (incompleteSections != $none) #incompleteSections: incompleteSections,
      if (members != $none) #members: members,
      if (invitationEmails != $none) #invitationEmails: invitationEmails,
    }),
  );
  @override
  GroupEntity $make(CopyWithData data) => GroupEntity(
    uid: data.get(#uid, or: $value.uid),
    profilePicture: data.get(#profilePicture, or: $value.profilePicture),
    groupName: data.get(#groupName, or: $value.groupName),
    professionalInfo: data.get(#professionalInfo, or: $value.professionalInfo),
    presentationMedias: data.get(
      #presentationMedias,
      or: $value.presentationMedias,
    ),
    dateRegistered: data.get(#dateRegistered, or: $value.dateRegistered),
    isActive: data.get(#isActive, or: $value.isActive),
    hasIncompleteSections: data.get(
      #hasIncompleteSections,
      or: $value.hasIncompleteSections,
    ),
    incompleteSections: data.get(
      #incompleteSections,
      or: $value.incompleteSections,
    ),
    members: data.get(#members, or: $value.members),
    invitationEmails: data.get(#invitationEmails, or: $value.invitationEmails),
  );

  @override
  GroupEntityCopyWith<$R2, GroupEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GroupEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

