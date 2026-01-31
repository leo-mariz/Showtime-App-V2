// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_document_entity.dart';

class MemberDocumentEntityMapper extends ClassMapperBase<MemberDocumentEntity> {
  MemberDocumentEntityMapper._();

  static MemberDocumentEntityMapper? _instance;
  static MemberDocumentEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberDocumentEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MemberDocumentEntity';

  static String _$artistId(MemberDocumentEntity v) => v.artistId;
  static const Field<MemberDocumentEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
  );
  static String _$ensembleId(MemberDocumentEntity v) => v.ensembleId;
  static const Field<MemberDocumentEntity, String> _f$ensembleId = Field(
    'ensembleId',
    _$ensembleId,
  );
  static String _$memberId(MemberDocumentEntity v) => v.memberId;
  static const Field<MemberDocumentEntity, String> _f$memberId = Field(
    'memberId',
    _$memberId,
  );
  static String _$documentType(MemberDocumentEntity v) => v.documentType;
  static const Field<MemberDocumentEntity, String> _f$documentType = Field(
    'documentType',
    _$documentType,
  );
  static int _$status(MemberDocumentEntity v) => v.status;
  static const Field<MemberDocumentEntity, int> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: 0,
  );
  static String? _$url(MemberDocumentEntity v) => v.url;
  static const Field<MemberDocumentEntity, String> _f$url = Field(
    'url',
    _$url,
    opt: true,
  );

  @override
  final MappableFields<MemberDocumentEntity> fields = const {
    #artistId: _f$artistId,
    #ensembleId: _f$ensembleId,
    #memberId: _f$memberId,
    #documentType: _f$documentType,
    #status: _f$status,
    #url: _f$url,
  };

  static MemberDocumentEntity _instantiate(DecodingData data) {
    return MemberDocumentEntity(
      artistId: data.dec(_f$artistId),
      ensembleId: data.dec(_f$ensembleId),
      memberId: data.dec(_f$memberId),
      documentType: data.dec(_f$documentType),
      status: data.dec(_f$status),
      url: data.dec(_f$url),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberDocumentEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberDocumentEntity>(map);
  }

  static MemberDocumentEntity fromJson(String json) {
    return ensureInitialized().decodeJson<MemberDocumentEntity>(json);
  }
}

mixin MemberDocumentEntityMappable {
  String toJson() {
    return MemberDocumentEntityMapper.ensureInitialized()
        .encodeJson<MemberDocumentEntity>(this as MemberDocumentEntity);
  }

  Map<String, dynamic> toMap() {
    return MemberDocumentEntityMapper.ensureInitialized()
        .encodeMap<MemberDocumentEntity>(this as MemberDocumentEntity);
  }

  MemberDocumentEntityCopyWith<
    MemberDocumentEntity,
    MemberDocumentEntity,
    MemberDocumentEntity
  >
  get copyWith =>
      _MemberDocumentEntityCopyWithImpl<
        MemberDocumentEntity,
        MemberDocumentEntity
      >(this as MemberDocumentEntity, $identity, $identity);
  @override
  String toString() {
    return MemberDocumentEntityMapper.ensureInitialized().stringifyValue(
      this as MemberDocumentEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberDocumentEntityMapper.ensureInitialized().equalsValue(
      this as MemberDocumentEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberDocumentEntityMapper.ensureInitialized().hashValue(
      this as MemberDocumentEntity,
    );
  }
}

extension MemberDocumentEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberDocumentEntity, $Out> {
  MemberDocumentEntityCopyWith<$R, MemberDocumentEntity, $Out>
  get $asMemberDocumentEntity => $base.as(
    (v, t, t2) => _MemberDocumentEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MemberDocumentEntityCopyWith<
  $R,
  $In extends MemberDocumentEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? artistId,
    String? ensembleId,
    String? memberId,
    String? documentType,
    int? status,
    String? url,
  });
  MemberDocumentEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MemberDocumentEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberDocumentEntity, $Out>
    implements MemberDocumentEntityCopyWith<$R, MemberDocumentEntity, $Out> {
  _MemberDocumentEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberDocumentEntity> $mapper =
      MemberDocumentEntityMapper.ensureInitialized();
  @override
  $R call({
    String? artistId,
    String? ensembleId,
    String? memberId,
    String? documentType,
    int? status,
    Object? url = $none,
  }) => $apply(
    FieldCopyWithData({
      if (artistId != null) #artistId: artistId,
      if (ensembleId != null) #ensembleId: ensembleId,
      if (memberId != null) #memberId: memberId,
      if (documentType != null) #documentType: documentType,
      if (status != null) #status: status,
      if (url != $none) #url: url,
    }),
  );
  @override
  MemberDocumentEntity $make(CopyWithData data) => MemberDocumentEntity(
    artistId: data.get(#artistId, or: $value.artistId),
    ensembleId: data.get(#ensembleId, or: $value.ensembleId),
    memberId: data.get(#memberId, or: $value.memberId),
    documentType: data.get(#documentType, or: $value.documentType),
    status: data.get(#status, or: $value.status),
    url: data.get(#url, or: $value.url),
  );

  @override
  MemberDocumentEntityCopyWith<$R2, MemberDocumentEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberDocumentEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

