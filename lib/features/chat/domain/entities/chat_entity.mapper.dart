// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'chat_entity.dart';

class ChatEntityMapper extends ClassMapperBase<ChatEntity> {
  ChatEntityMapper._();

  static ChatEntityMapper? _instance;
  static ChatEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ChatEntity';

  static String _$chatId(ChatEntity v) => v.chatId;
  static const Field<ChatEntity, String> _f$chatId = Field('chatId', _$chatId);
  static String _$contractId(ChatEntity v) => v.contractId;
  static const Field<ChatEntity, String> _f$contractId = Field(
    'contractId',
    _$contractId,
  );
  static String _$clientId(ChatEntity v) => v.clientId;
  static const Field<ChatEntity, String> _f$clientId = Field(
    'clientId',
    _$clientId,
  );
  static String _$artistId(ChatEntity v) => v.artistId;
  static const Field<ChatEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
  );
  static String _$clientName(ChatEntity v) => v.clientName;
  static const Field<ChatEntity, String> _f$clientName = Field(
    'clientName',
    _$clientName,
  );
  static String _$artistName(ChatEntity v) => v.artistName;
  static const Field<ChatEntity, String> _f$artistName = Field(
    'artistName',
    _$artistName,
  );
  static String? _$clientPhoto(ChatEntity v) => v.clientPhoto;
  static const Field<ChatEntity, String> _f$clientPhoto = Field(
    'clientPhoto',
    _$clientPhoto,
    opt: true,
  );
  static String? _$artistPhoto(ChatEntity v) => v.artistPhoto;
  static const Field<ChatEntity, String> _f$artistPhoto = Field(
    'artistPhoto',
    _$artistPhoto,
    opt: true,
  );
  static String _$status(ChatEntity v) => v.status;
  static const Field<ChatEntity, String> _f$status = Field('status', _$status);
  static DateTime _$createdAt(ChatEntity v) => v.createdAt;
  static const Field<ChatEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime? _$lastMessageAt(ChatEntity v) => v.lastMessageAt;
  static const Field<ChatEntity, DateTime> _f$lastMessageAt = Field(
    'lastMessageAt',
    _$lastMessageAt,
    opt: true,
  );
  static String? _$lastMessage(ChatEntity v) => v.lastMessage;
  static const Field<ChatEntity, String> _f$lastMessage = Field(
    'lastMessage',
    _$lastMessage,
    opt: true,
  );
  static String? _$lastMessageSenderId(ChatEntity v) => v.lastMessageSenderId;
  static const Field<ChatEntity, String> _f$lastMessageSenderId = Field(
    'lastMessageSenderId',
    _$lastMessageSenderId,
    opt: true,
  );
  static Map<String, int> _$unreadCount(ChatEntity v) => v.unreadCount;
  static const Field<ChatEntity, Map<String, int>> _f$unreadCount = Field(
    'unreadCount',
    _$unreadCount,
  );
  static Map<String, bool> _$typing(ChatEntity v) => v.typing;
  static const Field<ChatEntity, Map<String, bool>> _f$typing = Field(
    'typing',
    _$typing,
  );

  @override
  final MappableFields<ChatEntity> fields = const {
    #chatId: _f$chatId,
    #contractId: _f$contractId,
    #clientId: _f$clientId,
    #artistId: _f$artistId,
    #clientName: _f$clientName,
    #artistName: _f$artistName,
    #clientPhoto: _f$clientPhoto,
    #artistPhoto: _f$artistPhoto,
    #status: _f$status,
    #createdAt: _f$createdAt,
    #lastMessageAt: _f$lastMessageAt,
    #lastMessage: _f$lastMessage,
    #lastMessageSenderId: _f$lastMessageSenderId,
    #unreadCount: _f$unreadCount,
    #typing: _f$typing,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static ChatEntity _instantiate(DecodingData data) {
    return ChatEntity(
      chatId: data.dec(_f$chatId),
      contractId: data.dec(_f$contractId),
      clientId: data.dec(_f$clientId),
      artistId: data.dec(_f$artistId),
      clientName: data.dec(_f$clientName),
      artistName: data.dec(_f$artistName),
      clientPhoto: data.dec(_f$clientPhoto),
      artistPhoto: data.dec(_f$artistPhoto),
      status: data.dec(_f$status),
      createdAt: data.dec(_f$createdAt),
      lastMessageAt: data.dec(_f$lastMessageAt),
      lastMessage: data.dec(_f$lastMessage),
      lastMessageSenderId: data.dec(_f$lastMessageSenderId),
      unreadCount: data.dec(_f$unreadCount),
      typing: data.dec(_f$typing),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ChatEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChatEntity>(map);
  }

  static ChatEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ChatEntity>(json);
  }
}

mixin ChatEntityMappable {
  String toJson() {
    return ChatEntityMapper.ensureInitialized().encodeJson<ChatEntity>(
      this as ChatEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return ChatEntityMapper.ensureInitialized().encodeMap<ChatEntity>(
      this as ChatEntity,
    );
  }

  ChatEntityCopyWith<ChatEntity, ChatEntity, ChatEntity> get copyWith =>
      _ChatEntityCopyWithImpl<ChatEntity, ChatEntity>(
        this as ChatEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChatEntityMapper.ensureInitialized().stringifyValue(
      this as ChatEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChatEntityMapper.ensureInitialized().equalsValue(
      this as ChatEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ChatEntityMapper.ensureInitialized().hashValue(this as ChatEntity);
  }
}

extension ChatEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChatEntity, $Out> {
  ChatEntityCopyWith<$R, ChatEntity, $Out> get $asChatEntity =>
      $base.as((v, t, t2) => _ChatEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChatEntityCopyWith<$R, $In extends ChatEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>> get unreadCount;
  MapCopyWith<$R, String, bool, ObjectCopyWith<$R, bool, bool>> get typing;
  $R call({
    String? chatId,
    String? contractId,
    String? clientId,
    String? artistId,
    String? clientName,
    String? artistName,
    String? clientPhoto,
    String? artistPhoto,
    String? status,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? typing,
  });
  ChatEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChatEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChatEntity, $Out>
    implements ChatEntityCopyWith<$R, ChatEntity, $Out> {
  _ChatEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChatEntity> $mapper =
      ChatEntityMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>> get unreadCount =>
      MapCopyWith(
        $value.unreadCount,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(unreadCount: v),
      );
  @override
  MapCopyWith<$R, String, bool, ObjectCopyWith<$R, bool, bool>> get typing =>
      MapCopyWith(
        $value.typing,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(typing: v),
      );
  @override
  $R call({
    String? chatId,
    String? contractId,
    String? clientId,
    String? artistId,
    String? clientName,
    String? artistName,
    Object? clientPhoto = $none,
    Object? artistPhoto = $none,
    String? status,
    DateTime? createdAt,
    Object? lastMessageAt = $none,
    Object? lastMessage = $none,
    Object? lastMessageSenderId = $none,
    Map<String, int>? unreadCount,
    Map<String, bool>? typing,
  }) => $apply(
    FieldCopyWithData({
      if (chatId != null) #chatId: chatId,
      if (contractId != null) #contractId: contractId,
      if (clientId != null) #clientId: clientId,
      if (artistId != null) #artistId: artistId,
      if (clientName != null) #clientName: clientName,
      if (artistName != null) #artistName: artistName,
      if (clientPhoto != $none) #clientPhoto: clientPhoto,
      if (artistPhoto != $none) #artistPhoto: artistPhoto,
      if (status != null) #status: status,
      if (createdAt != null) #createdAt: createdAt,
      if (lastMessageAt != $none) #lastMessageAt: lastMessageAt,
      if (lastMessage != $none) #lastMessage: lastMessage,
      if (lastMessageSenderId != $none)
        #lastMessageSenderId: lastMessageSenderId,
      if (unreadCount != null) #unreadCount: unreadCount,
      if (typing != null) #typing: typing,
    }),
  );
  @override
  ChatEntity $make(CopyWithData data) => ChatEntity(
    chatId: data.get(#chatId, or: $value.chatId),
    contractId: data.get(#contractId, or: $value.contractId),
    clientId: data.get(#clientId, or: $value.clientId),
    artistId: data.get(#artistId, or: $value.artistId),
    clientName: data.get(#clientName, or: $value.clientName),
    artistName: data.get(#artistName, or: $value.artistName),
    clientPhoto: data.get(#clientPhoto, or: $value.clientPhoto),
    artistPhoto: data.get(#artistPhoto, or: $value.artistPhoto),
    status: data.get(#status, or: $value.status),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    lastMessageAt: data.get(#lastMessageAt, or: $value.lastMessageAt),
    lastMessage: data.get(#lastMessage, or: $value.lastMessage),
    lastMessageSenderId: data.get(
      #lastMessageSenderId,
      or: $value.lastMessageSenderId,
    ),
    unreadCount: data.get(#unreadCount, or: $value.unreadCount),
    typing: data.get(#typing, or: $value.typing),
  );

  @override
  ChatEntityCopyWith<$R2, ChatEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChatEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

