// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'documents_entity.dart';

class DocumentsEntityMapper extends ClassMapperBase<DocumentsEntity> {
  DocumentsEntityMapper._();

  static DocumentsEntityMapper? _instance;
  static DocumentsEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentsEntityMapper._());
      AddressInfoEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentsEntity';

  static String _$documentType(DocumentsEntity v) => v.documentType;
  static const Field<DocumentsEntity, String> _f$documentType = Field(
    'documentType',
    _$documentType,
  );
  static String? _$documentOption(DocumentsEntity v) => v.documentOption;
  static const Field<DocumentsEntity, String> _f$documentOption = Field(
    'documentOption',
    _$documentOption,
    opt: true,
  );
  static String? _$url(DocumentsEntity v) => v.url;
  static const Field<DocumentsEntity, String> _f$url = Field(
    'url',
    _$url,
    opt: true,
  );
  static int _$status(DocumentsEntity v) => v.status;
  static const Field<DocumentsEntity, int> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: 0,
  );
  static String? _$observation(DocumentsEntity v) => v.observation;
  static const Field<DocumentsEntity, String> _f$observation = Field(
    'observation',
    _$observation,
    opt: true,
  );
  static AddressInfoEntity? _$address(DocumentsEntity v) => v.address;
  static const Field<DocumentsEntity, AddressInfoEntity> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static String? _$idNumber(DocumentsEntity v) => v.idNumber;
  static const Field<DocumentsEntity, String> _f$idNumber = Field(
    'idNumber',
    _$idNumber,
    opt: true,
  );
  static DateTime? _$updatedAt(DocumentsEntity v) => v.updatedAt;
  static const Field<DocumentsEntity, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<DocumentsEntity> fields = const {
    #documentType: _f$documentType,
    #documentOption: _f$documentOption,
    #url: _f$url,
    #status: _f$status,
    #observation: _f$observation,
    #address: _f$address,
    #idNumber: _f$idNumber,
    #updatedAt: _f$updatedAt,
  };

  static DocumentsEntity _instantiate(DecodingData data) {
    return DocumentsEntity(
      documentType: data.dec(_f$documentType),
      documentOption: data.dec(_f$documentOption),
      url: data.dec(_f$url),
      status: data.dec(_f$status),
      observation: data.dec(_f$observation),
      address: data.dec(_f$address),
      idNumber: data.dec(_f$idNumber),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentsEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentsEntity>(map);
  }

  static DocumentsEntity fromJson(String json) {
    return ensureInitialized().decodeJson<DocumentsEntity>(json);
  }
}

mixin DocumentsEntityMappable {
  String toJson() {
    return DocumentsEntityMapper.ensureInitialized()
        .encodeJson<DocumentsEntity>(this as DocumentsEntity);
  }

  Map<String, dynamic> toMap() {
    return DocumentsEntityMapper.ensureInitialized().encodeMap<DocumentsEntity>(
      this as DocumentsEntity,
    );
  }

  DocumentsEntityCopyWith<DocumentsEntity, DocumentsEntity, DocumentsEntity>
  get copyWith =>
      _DocumentsEntityCopyWithImpl<DocumentsEntity, DocumentsEntity>(
        this as DocumentsEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DocumentsEntityMapper.ensureInitialized().stringifyValue(
      this as DocumentsEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentsEntityMapper.ensureInitialized().equalsValue(
      this as DocumentsEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentsEntityMapper.ensureInitialized().hashValue(
      this as DocumentsEntity,
    );
  }
}

extension DocumentsEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DocumentsEntity, $Out> {
  DocumentsEntityCopyWith<$R, DocumentsEntity, $Out> get $asDocumentsEntity =>
      $base.as((v, t, t2) => _DocumentsEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DocumentsEntityCopyWith<$R, $In extends DocumentsEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get address;
  $R call({
    String? documentType,
    String? documentOption,
    String? url,
    int? status,
    String? observation,
    AddressInfoEntity? address,
    String? idNumber,
    DateTime? updatedAt,
  });
  DocumentsEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentsEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DocumentsEntity, $Out>
    implements DocumentsEntityCopyWith<$R, DocumentsEntity, $Out> {
  _DocumentsEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentsEntity> $mapper =
      DocumentsEntityMapper.ensureInitialized();
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>?
  get address => $value.address?.copyWith.$chain((v) => call(address: v));
  @override
  $R call({
    String? documentType,
    Object? documentOption = $none,
    Object? url = $none,
    int? status,
    Object? observation = $none,
    Object? address = $none,
    Object? idNumber = $none,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (documentType != null) #documentType: documentType,
      if (documentOption != $none) #documentOption: documentOption,
      if (url != $none) #url: url,
      if (status != null) #status: status,
      if (observation != $none) #observation: observation,
      if (address != $none) #address: address,
      if (idNumber != $none) #idNumber: idNumber,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  DocumentsEntity $make(CopyWithData data) => DocumentsEntity(
    documentType: data.get(#documentType, or: $value.documentType),
    documentOption: data.get(#documentOption, or: $value.documentOption),
    url: data.get(#url, or: $value.url),
    status: data.get(#status, or: $value.status),
    observation: data.get(#observation, or: $value.observation),
    address: data.get(#address, or: $value.address),
    idNumber: data.get(#idNumber, or: $value.idNumber),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  DocumentsEntityCopyWith<$R2, DocumentsEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DocumentsEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

