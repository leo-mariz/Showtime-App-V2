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
    }
    return _instance!;
  }

  @override
  final String id = 'MessageEntity';

  static String _$messageId(MessageEntity v) => v.messageId;
  static const Field<MessageEntity, String> _f$messageId = Field(
    'messageId',
    _$messageId,
  );
  static String _$senderId(MessageEntity v) => v.senderId;
  static const Field<MessageEntity, String> _f$senderId = Field(
    'senderId',
    _$senderId,
  );
  static String _$text(MessageEntity v) => v.text;
  static const Field<MessageEntity, String> _f$text = Field('text', _$text);
  static DateTime _$createdAt(MessageEntity v) => v.createdAt;
  static const Field<MessageEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static String _$status(MessageEntity v) => v.status;
  static const Field<MessageEntity, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$type(MessageEntity v) => v.type;
  static const Field<MessageEntity, String> _f$type = Field('type', _$type);

  @override
  final MappableFields<MessageEntity> fields = const {
    #messageId: _f$messageId,
    #senderId: _f$senderId,
    #text: _f$text,
    #createdAt: _f$createdAt,
    #status: _f$status,
    #type: _f$type,
  };

  @override
  final MappingHook hook = const TimestampHook();
  static MessageEntity _instantiate(DecodingData data) {
    return MessageEntity(
      messageId: data.dec(_f$messageId),
      senderId: data.dec(_f$senderId),
      text: data.dec(_f$text),
      createdAt: data.dec(_f$createdAt),
      status: data.dec(_f$status),
      type: data.dec(_f$type),
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
    String? messageId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    String? status,
    String? type,
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
    String? messageId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    String? status,
    String? type,
  }) => $apply(
    FieldCopyWithData({
      if (messageId != null) #messageId: messageId,
      if (senderId != null) #senderId: senderId,
      if (text != null) #text: text,
      if (createdAt != null) #createdAt: createdAt,
      if (status != null) #status: status,
      if (type != null) #type: type,
    }),
  );
  @override
  MessageEntity $make(CopyWithData data) => MessageEntity(
    messageId: data.get(#messageId, or: $value.messageId),
    senderId: data.get(#senderId, or: $value.senderId),
    text: data.get(#text, or: $value.text),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    status: data.get(#status, or: $value.status),
    type: data.get(#type, or: $value.type),
  );

  @override
  MessageEntityCopyWith<$R2, MessageEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MessageEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

