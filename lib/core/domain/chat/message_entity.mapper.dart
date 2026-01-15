// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'message_entity.dart';

class MessageEntityMapper extends ClassMapperBase<MessageEntity> {
  MessageEntityMapper._();

  static MessageEntityMapper? _instance;
  static MessageEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageEntityMapper._());
      MessageSenderTypeEnumMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MessageEntity';

  static String? _$uid(MessageEntity v) => v.uid;
  static const Field<MessageEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String _$contractId(MessageEntity v) => v.contractId;
  static const Field<MessageEntity, String> _f$contractId = Field(
    'contractId',
    _$contractId,
  );
  static String _$text(MessageEntity v) => v.text;
  static const Field<MessageEntity, String> _f$text = Field('text', _$text);
  static String? _$senderId(MessageEntity v) => v.senderId;
  static const Field<MessageEntity, String> _f$senderId = Field(
    'senderId',
    _$senderId,
    opt: true,
  );
  static String? _$senderName(MessageEntity v) => v.senderName;
  static const Field<MessageEntity, String> _f$senderName = Field(
    'senderName',
    _$senderName,
    opt: true,
  );
  static MessageSenderTypeEnum _$senderType(MessageEntity v) => v.senderType;
  static const Field<MessageEntity, MessageSenderTypeEnum> _f$senderType =
      Field('senderType', _$senderType);
  static DateTime _$timestamp(MessageEntity v) => v.timestamp;
  static const Field<MessageEntity, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
    opt: true,
  );
  static bool _$isRead(MessageEntity v) => v.isRead;
  static const Field<MessageEntity, bool> _f$isRead = Field(
    'isRead',
    _$isRead,
    opt: true,
    def: false,
  );
  static String? _$senderAvatarUrl(MessageEntity v) => v.senderAvatarUrl;
  static const Field<MessageEntity, String> _f$senderAvatarUrl = Field(
    'senderAvatarUrl',
    _$senderAvatarUrl,
    opt: true,
  );

  @override
  final MappableFields<MessageEntity> fields = const {
    #uid: _f$uid,
    #contractId: _f$contractId,
    #text: _f$text,
    #senderId: _f$senderId,
    #senderName: _f$senderName,
    #senderType: _f$senderType,
    #timestamp: _f$timestamp,
    #isRead: _f$isRead,
    #senderAvatarUrl: _f$senderAvatarUrl,
  };

  static MessageEntity _instantiate(DecodingData data) {
    return MessageEntity(
      uid: data.dec(_f$uid),
      contractId: data.dec(_f$contractId),
      text: data.dec(_f$text),
      senderId: data.dec(_f$senderId),
      senderName: data.dec(_f$senderName),
      senderType: data.dec(_f$senderType),
      timestamp: data.dec(_f$timestamp),
      isRead: data.dec(_f$isRead),
      senderAvatarUrl: data.dec(_f$senderAvatarUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MessageEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MessageEntity>(map);
  }

  static MessageEntity fromJson(String json) {
    return ensureInitialized().decodeJson<MessageEntity>(json);
  }
}

mixin MessageEntityMappable {
  String toJson() {
    return MessageEntityMapper.ensureInitialized().encodeJson<MessageEntity>(
      this as MessageEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return MessageEntityMapper.ensureInitialized().encodeMap<MessageEntity>(
      this as MessageEntity,
    );
  }

  MessageEntityCopyWith<MessageEntity, MessageEntity, MessageEntity>
  get copyWith => _MessageEntityCopyWithImpl<MessageEntity, MessageEntity>(
    this as MessageEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MessageEntityMapper.ensureInitialized().stringifyValue(
      this as MessageEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return MessageEntityMapper.ensureInitialized().equalsValue(
      this as MessageEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return MessageEntityMapper.ensureInitialized().hashValue(
      this as MessageEntity,
    );
  }
}

extension MessageEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MessageEntity, $Out> {
  MessageEntityCopyWith<$R, MessageEntity, $Out> get $asMessageEntity =>
      $base.as((v, t, t2) => _MessageEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MessageEntityCopyWith<$R, $In extends MessageEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? uid,
    String? contractId,
    String? text,
    String? senderId,
    String? senderName,
    MessageSenderTypeEnum? senderType,
    DateTime? timestamp,
    bool? isRead,
    String? senderAvatarUrl,
  });
  MessageEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MessageEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MessageEntity, $Out>
    implements MessageEntityCopyWith<$R, MessageEntity, $Out> {
  _MessageEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MessageEntity> $mapper =
      MessageEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? uid = $none,
    String? contractId,
    String? text,
    Object? senderId = $none,
    Object? senderName = $none,
    MessageSenderTypeEnum? senderType,
    Object? timestamp = $none,
    bool? isRead,
    Object? senderAvatarUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uid != $none) #uid: uid,
      if (contractId != null) #contractId: contractId,
      if (text != null) #text: text,
      if (senderId != $none) #senderId: senderId,
      if (senderName != $none) #senderName: senderName,
      if (senderType != null) #senderType: senderType,
      if (timestamp != $none) #timestamp: timestamp,
      if (isRead != null) #isRead: isRead,
      if (senderAvatarUrl != $none) #senderAvatarUrl: senderAvatarUrl,
    }),
  );
  @override
  MessageEntity $make(CopyWithData data) => MessageEntity(
    uid: data.get(#uid, or: $value.uid),
    contractId: data.get(#contractId, or: $value.contractId),
    text: data.get(#text, or: $value.text),
    senderId: data.get(#senderId, or: $value.senderId),
    senderName: data.get(#senderName, or: $value.senderName),
    senderType: data.get(#senderType, or: $value.senderType),
    timestamp: data.get(#timestamp, or: $value.timestamp),
    isRead: data.get(#isRead, or: $value.isRead),
    senderAvatarUrl: data.get(#senderAvatarUrl, or: $value.senderAvatarUrl),
  );

  @override
  MessageEntityCopyWith<$R2, MessageEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MessageEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

