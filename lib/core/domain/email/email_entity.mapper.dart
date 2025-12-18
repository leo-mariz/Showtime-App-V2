// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'email_entity.dart';

class EmailEntityMapper extends ClassMapperBase<EmailEntity> {
  EmailEntityMapper._();

  static EmailEntityMapper? _instance;
  static EmailEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmailEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EmailEntity';

  static String? _$id(EmailEntity v) => v.id;
  static const Field<EmailEntity, String> _f$id = Field('id', _$id, opt: true);
  static String? _$key(EmailEntity v) => v.key;
  static const Field<EmailEntity, String> _f$key = Field(
    'key',
    _$key,
    opt: true,
  );
  static String? _$fullName(EmailEntity v) => v.fullName;
  static const Field<EmailEntity, String> _f$fullName = Field(
    'fullName',
    _$fullName,
    opt: true,
  );
  static String? _$from(EmailEntity v) => v.from;
  static const Field<EmailEntity, String> _f$from = Field(
    'from',
    _$from,
    opt: true,
  );
  static List<String>? _$to(EmailEntity v) => v.to;
  static const Field<EmailEntity, List<String>> _f$to = Field(
    'to',
    _$to,
    opt: true,
  );
  static String _$subject(EmailEntity v) => v.subject;
  static const Field<EmailEntity, String> _f$subject = Field(
    'subject',
    _$subject,
  );
  static String _$body(EmailEntity v) => v.body;
  static const Field<EmailEntity, String> _f$body = Field('body', _$body);
  static bool _$isHtml(EmailEntity v) => v.isHtml;
  static const Field<EmailEntity, bool> _f$isHtml = Field(
    'isHtml',
    _$isHtml,
    opt: true,
    def: false,
  );
  static String? _$attachment(EmailEntity v) => v.attachment;
  static const Field<EmailEntity, String> _f$attachment = Field(
    'attachment',
    _$attachment,
    opt: true,
  );
  static String? _$status(EmailEntity v) => v.status;
  static const Field<EmailEntity, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static DateTime? _$createdAt(EmailEntity v) => v.createdAt;
  static const Field<EmailEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );
  static DateTime? _$updatedAt(EmailEntity v) => v.updatedAt;
  static const Field<EmailEntity, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<EmailEntity> fields = const {
    #id: _f$id,
    #key: _f$key,
    #fullName: _f$fullName,
    #from: _f$from,
    #to: _f$to,
    #subject: _f$subject,
    #body: _f$body,
    #isHtml: _f$isHtml,
    #attachment: _f$attachment,
    #status: _f$status,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static EmailEntity _instantiate(DecodingData data) {
    return EmailEntity(
      id: data.dec(_f$id),
      key: data.dec(_f$key),
      fullName: data.dec(_f$fullName),
      from: data.dec(_f$from),
      to: data.dec(_f$to),
      subject: data.dec(_f$subject),
      body: data.dec(_f$body),
      isHtml: data.dec(_f$isHtml),
      attachment: data.dec(_f$attachment),
      status: data.dec(_f$status),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EmailEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EmailEntity>(map);
  }

  static EmailEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EmailEntity>(json);
  }
}

mixin EmailEntityMappable {
  String toJson() {
    return EmailEntityMapper.ensureInitialized().encodeJson<EmailEntity>(
      this as EmailEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return EmailEntityMapper.ensureInitialized().encodeMap<EmailEntity>(
      this as EmailEntity,
    );
  }

  EmailEntityCopyWith<EmailEntity, EmailEntity, EmailEntity> get copyWith =>
      _EmailEntityCopyWithImpl<EmailEntity, EmailEntity>(
        this as EmailEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EmailEntityMapper.ensureInitialized().stringifyValue(
      this as EmailEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EmailEntityMapper.ensureInitialized().equalsValue(
      this as EmailEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EmailEntityMapper.ensureInitialized().hashValue(this as EmailEntity);
  }
}

extension EmailEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EmailEntity, $Out> {
  EmailEntityCopyWith<$R, EmailEntity, $Out> get $asEmailEntity =>
      $base.as((v, t, t2) => _EmailEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EmailEntityCopyWith<$R, $In extends EmailEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get to;
  $R call({
    String? id,
    String? key,
    String? fullName,
    String? from,
    List<String>? to,
    String? subject,
    String? body,
    bool? isHtml,
    String? attachment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  EmailEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EmailEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EmailEntity, $Out>
    implements EmailEntityCopyWith<$R, EmailEntity, $Out> {
  _EmailEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EmailEntity> $mapper =
      EmailEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get to =>
      $value.to != null
      ? ListCopyWith(
          $value.to!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(to: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? key = $none,
    Object? fullName = $none,
    Object? from = $none,
    Object? to = $none,
    String? subject,
    String? body,
    bool? isHtml,
    Object? attachment = $none,
    Object? status = $none,
    Object? createdAt = $none,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (key != $none) #key: key,
      if (fullName != $none) #fullName: fullName,
      if (from != $none) #from: from,
      if (to != $none) #to: to,
      if (subject != null) #subject: subject,
      if (body != null) #body: body,
      if (isHtml != null) #isHtml: isHtml,
      if (attachment != $none) #attachment: attachment,
      if (status != $none) #status: status,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  EmailEntity $make(CopyWithData data) => EmailEntity(
    id: data.get(#id, or: $value.id),
    key: data.get(#key, or: $value.key),
    fullName: data.get(#fullName, or: $value.fullName),
    from: data.get(#from, or: $value.from),
    to: data.get(#to, or: $value.to),
    subject: data.get(#subject, or: $value.subject),
    body: data.get(#body, or: $value.body),
    isHtml: data.get(#isHtml, or: $value.isHtml),
    attachment: data.get(#attachment, or: $value.attachment),
    status: data.get(#status, or: $value.status),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  EmailEntityCopyWith<$R2, EmailEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EmailEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

