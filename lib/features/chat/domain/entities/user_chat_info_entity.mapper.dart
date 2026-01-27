// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_chat_info_entity.dart';

class UserChatInfoEntityMapper extends ClassMapperBase<UserChatInfoEntity> {
  UserChatInfoEntityMapper._();

  static UserChatInfoEntityMapper? _instance;
  static UserChatInfoEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserChatInfoEntityMapper._());
      ChatPreviewEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UserChatInfoEntity';

  static String _$userId(UserChatInfoEntity v) => v.userId;
  static const Field<UserChatInfoEntity, String> _f$userId = Field(
    'userId',
    _$userId,
  );
  static int _$totalUnread(UserChatInfoEntity v) => v.totalUnread;
  static const Field<UserChatInfoEntity, int> _f$totalUnread = Field(
    'totalUnread',
    _$totalUnread,
  );
  static int _$activeChatsCount(UserChatInfoEntity v) => v.activeChatsCount;
  static const Field<UserChatInfoEntity, int> _f$activeChatsCount = Field(
    'activeChatsCount',
    _$activeChatsCount,
  );
  static DateTime _$lastUpdate(UserChatInfoEntity v) => v.lastUpdate;
  static const Field<UserChatInfoEntity, DateTime> _f$lastUpdate = Field(
    'lastUpdate',
    _$lastUpdate,
  );
  static Map<String, ChatPreviewEntity> _$chats(UserChatInfoEntity v) =>
      v.chats;
  static const Field<UserChatInfoEntity, Map<String, ChatPreviewEntity>>
  _f$chats = Field('chats', _$chats);

  @override
  final MappableFields<UserChatInfoEntity> fields = const {
    #userId: _f$userId,
    #totalUnread: _f$totalUnread,
    #activeChatsCount: _f$activeChatsCount,
    #lastUpdate: _f$lastUpdate,
    #chats: _f$chats,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static UserChatInfoEntity _instantiate(DecodingData data) {
    return UserChatInfoEntity(
      userId: data.dec(_f$userId),
      totalUnread: data.dec(_f$totalUnread),
      activeChatsCount: data.dec(_f$activeChatsCount),
      lastUpdate: data.dec(_f$lastUpdate),
      chats: data.dec(_f$chats),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserChatInfoEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserChatInfoEntity>(map);
  }

  static UserChatInfoEntity fromJson(String json) {
    return ensureInitialized().decodeJson<UserChatInfoEntity>(json);
  }
}

mixin UserChatInfoEntityMappable {
  String toJson() {
    return UserChatInfoEntityMapper.ensureInitialized()
        .encodeJson<UserChatInfoEntity>(this as UserChatInfoEntity);
  }

  Map<String, dynamic> toMap() {
    return UserChatInfoEntityMapper.ensureInitialized()
        .encodeMap<UserChatInfoEntity>(this as UserChatInfoEntity);
  }

  UserChatInfoEntityCopyWith<
    UserChatInfoEntity,
    UserChatInfoEntity,
    UserChatInfoEntity
  >
  get copyWith =>
      _UserChatInfoEntityCopyWithImpl<UserChatInfoEntity, UserChatInfoEntity>(
        this as UserChatInfoEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserChatInfoEntityMapper.ensureInitialized().stringifyValue(
      this as UserChatInfoEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserChatInfoEntityMapper.ensureInitialized().equalsValue(
      this as UserChatInfoEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return UserChatInfoEntityMapper.ensureInitialized().hashValue(
      this as UserChatInfoEntity,
    );
  }
}

extension UserChatInfoEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserChatInfoEntity, $Out> {
  UserChatInfoEntityCopyWith<$R, UserChatInfoEntity, $Out>
  get $asUserChatInfoEntity => $base.as(
    (v, t, t2) => _UserChatInfoEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UserChatInfoEntityCopyWith<
  $R,
  $In extends UserChatInfoEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<
    $R,
    String,
    ChatPreviewEntity,
    ChatPreviewEntityCopyWith<$R, ChatPreviewEntity, ChatPreviewEntity>
  >
  get chats;
  $R call({
    String? userId,
    int? totalUnread,
    int? activeChatsCount,
    DateTime? lastUpdate,
    Map<String, ChatPreviewEntity>? chats,
  });
  UserChatInfoEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UserChatInfoEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserChatInfoEntity, $Out>
    implements UserChatInfoEntityCopyWith<$R, UserChatInfoEntity, $Out> {
  _UserChatInfoEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserChatInfoEntity> $mapper =
      UserChatInfoEntityMapper.ensureInitialized();
  @override
  MapCopyWith<
    $R,
    String,
    ChatPreviewEntity,
    ChatPreviewEntityCopyWith<$R, ChatPreviewEntity, ChatPreviewEntity>
  >
  get chats => MapCopyWith(
    $value.chats,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(chats: v),
  );
  @override
  $R call({
    String? userId,
    int? totalUnread,
    int? activeChatsCount,
    DateTime? lastUpdate,
    Map<String, ChatPreviewEntity>? chats,
  }) => $apply(
    FieldCopyWithData({
      if (userId != null) #userId: userId,
      if (totalUnread != null) #totalUnread: totalUnread,
      if (activeChatsCount != null) #activeChatsCount: activeChatsCount,
      if (lastUpdate != null) #lastUpdate: lastUpdate,
      if (chats != null) #chats: chats,
    }),
  );
  @override
  UserChatInfoEntity $make(CopyWithData data) => UserChatInfoEntity(
    userId: data.get(#userId, or: $value.userId),
    totalUnread: data.get(#totalUnread, or: $value.totalUnread),
    activeChatsCount: data.get(#activeChatsCount, or: $value.activeChatsCount),
    lastUpdate: data.get(#lastUpdate, or: $value.lastUpdate),
    chats: data.get(#chats, or: $value.chats),
  );

  @override
  UserChatInfoEntityCopyWith<$R2, UserChatInfoEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserChatInfoEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChatPreviewEntityMapper extends ClassMapperBase<ChatPreviewEntity> {
  ChatPreviewEntityMapper._();

  static ChatPreviewEntityMapper? _instance;
  static ChatPreviewEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatPreviewEntityMapper._());
      ChatUserRoleEnumMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChatPreviewEntity';

  static String _$chatId(ChatPreviewEntity v) => v.chatId;
  static const Field<ChatPreviewEntity, String> _f$chatId = Field(
    'chatId',
    _$chatId,
  );
  static ChatUserRoleEnum _$userRole(ChatPreviewEntity v) => v.userRole;
  static const Field<ChatPreviewEntity, ChatUserRoleEnum> _f$userRole = Field(
    'userRole',
    _$userRole,
  );
  static int _$unread(ChatPreviewEntity v) => v.unread;
  static const Field<ChatPreviewEntity, int> _f$unread = Field(
    'unread',
    _$unread,
  );
  static DateTime _$lastMessageAt(ChatPreviewEntity v) => v.lastMessageAt;
  static const Field<ChatPreviewEntity, DateTime> _f$lastMessageAt = Field(
    'lastMessageAt',
    _$lastMessageAt,
  );
  static String _$otherUserId(ChatPreviewEntity v) => v.otherUserId;
  static const Field<ChatPreviewEntity, String> _f$otherUserId = Field(
    'otherUserId',
    _$otherUserId,
  );
  static String _$otherUserName(ChatPreviewEntity v) => v.otherUserName;
  static const Field<ChatPreviewEntity, String> _f$otherUserName = Field(
    'otherUserName',
    _$otherUserName,
  );
  static String? _$otherUserPhoto(ChatPreviewEntity v) => v.otherUserPhoto;
  static const Field<ChatPreviewEntity, String> _f$otherUserPhoto = Field(
    'otherUserPhoto',
    _$otherUserPhoto,
    opt: true,
  );
  static String _$lastMessage(ChatPreviewEntity v) => v.lastMessage;
  static const Field<ChatPreviewEntity, String> _f$lastMessage = Field(
    'lastMessage',
    _$lastMessage,
  );
  static String _$contractId(ChatPreviewEntity v) => v.contractId;
  static const Field<ChatPreviewEntity, String> _f$contractId = Field(
    'contractId',
    _$contractId,
  );

  @override
  final MappableFields<ChatPreviewEntity> fields = const {
    #chatId: _f$chatId,
    #userRole: _f$userRole,
    #unread: _f$unread,
    #lastMessageAt: _f$lastMessageAt,
    #otherUserId: _f$otherUserId,
    #otherUserName: _f$otherUserName,
    #otherUserPhoto: _f$otherUserPhoto,
    #lastMessage: _f$lastMessage,
    #contractId: _f$contractId,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static ChatPreviewEntity _instantiate(DecodingData data) {
    return ChatPreviewEntity(
      chatId: data.dec(_f$chatId),
      userRole: data.dec(_f$userRole),
      unread: data.dec(_f$unread),
      lastMessageAt: data.dec(_f$lastMessageAt),
      otherUserId: data.dec(_f$otherUserId),
      otherUserName: data.dec(_f$otherUserName),
      otherUserPhoto: data.dec(_f$otherUserPhoto),
      lastMessage: data.dec(_f$lastMessage),
      contractId: data.dec(_f$contractId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatPreviewEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatPreviewEntity>(map);
  }

  static ChatPreviewEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ChatPreviewEntity>(json);
  }
}

mixin ChatPreviewEntityMappable {
  String toJson() {
    return ChatPreviewEntityMapper.ensureInitialized()
        .encodeJson<ChatPreviewEntity>(this as ChatPreviewEntity);
  }

  Map<String, dynamic> toMap() {
    return ChatPreviewEntityMapper.ensureInitialized()
        .encodeMap<ChatPreviewEntity>(this as ChatPreviewEntity);
  }

  ChatPreviewEntityCopyWith<
    ChatPreviewEntity,
    ChatPreviewEntity,
    ChatPreviewEntity
  >
  get copyWith =>
      _ChatPreviewEntityCopyWithImpl<ChatPreviewEntity, ChatPreviewEntity>(
        this as ChatPreviewEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatPreviewEntityMapper.ensureInitialized().stringifyValue(
      this as ChatPreviewEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatPreviewEntityMapper.ensureInitialized().equalsValue(
      this as ChatPreviewEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatPreviewEntityMapper.ensureInitialized().hashValue(
      this as ChatPreviewEntity,
    );
  }
}

extension ChatPreviewEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatPreviewEntity, $Out> {
  ChatPreviewEntityCopyWith<$R, ChatPreviewEntity, $Out>
  get $asChatPreviewEntity => $base.as(
    (v, t, t2) => _ChatPreviewEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ChatPreviewEntityCopyWith<
  $R,
  $In extends ChatPreviewEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? chatId,
    ChatUserRoleEnum? userRole,
    int? unread,
    DateTime? lastMessageAt,
    String? otherUserId,
    String? otherUserName,
    String? otherUserPhoto,
    String? lastMessage,
    String? contractId,
  });
  ChatPreviewEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ChatPreviewEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatPreviewEntity, $Out>
    implements ChatPreviewEntityCopyWith<$R, ChatPreviewEntity, $Out> {
  _ChatPreviewEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatPreviewEntity> $mapper =
      ChatPreviewEntityMapper.ensureInitialized();
  @override
  $R call({
    String? chatId,
    ChatUserRoleEnum? userRole,
    int? unread,
    DateTime? lastMessageAt,
    String? otherUserId,
    String? otherUserName,
    Object? otherUserPhoto = $none,
    String? lastMessage,
    String? contractId,
  }) => $apply(
    FieldCopyWithData({
      if (chatId != null) #chatId: chatId,
      if (userRole != null) #userRole: userRole,
      if (unread != null) #unread: unread,
      if (lastMessageAt != null) #lastMessageAt: lastMessageAt,
      if (otherUserId != null) #otherUserId: otherUserId,
      if (otherUserName != null) #otherUserName: otherUserName,
      if (otherUserPhoto != $none) #otherUserPhoto: otherUserPhoto,
      if (lastMessage != null) #lastMessage: lastMessage,
      if (contractId != null) #contractId: contractId,
    }),
  );
  @override
  ChatPreviewEntity $make(CopyWithData data) => ChatPreviewEntity(
    chatId: data.get(#chatId, or: $value.chatId),
    userRole: data.get(#userRole, or: $value.userRole),
    unread: data.get(#unread, or: $value.unread),
    lastMessageAt: data.get(#lastMessageAt, or: $value.lastMessageAt),
    otherUserId: data.get(#otherUserId, or: $value.otherUserId),
    otherUserName: data.get(#otherUserName, or: $value.otherUserName),
    otherUserPhoto: data.get(#otherUserPhoto, or: $value.otherUserPhoto),
    lastMessage: data.get(#lastMessage, or: $value.lastMessage),
    contractId: data.get(#contractId, or: $value.contractId),
  );

  @override
  ChatPreviewEntityCopyWith<$R2, ChatPreviewEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatPreviewEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

