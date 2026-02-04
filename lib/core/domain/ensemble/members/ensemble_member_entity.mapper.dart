// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ensemble_member_entity.dart';

class EnsembleMemberEntityMapper extends ClassMapperBase<EnsembleMemberEntity> {
  EnsembleMemberEntityMapper._();

  static EnsembleMemberEntityMapper? _instance;
  static EnsembleMemberEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnsembleMemberEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EnsembleMemberEntity';

  static String? _$id(EnsembleMemberEntity v) => v.id;
  static const Field<EnsembleMemberEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static List<String>? _$ensembleIds(EnsembleMemberEntity v) => v.ensembleIds;
  static const Field<EnsembleMemberEntity, List<String>> _f$ensembleIds = Field(
    'ensembleIds',
    _$ensembleIds,
    opt: true,
  );
  static bool _$isOwner(EnsembleMemberEntity v) => v.isOwner;
  static const Field<EnsembleMemberEntity, bool> _f$isOwner = Field(
    'isOwner',
    _$isOwner,
    opt: true,
    def: false,
  );
  static String? _$artistId(EnsembleMemberEntity v) => v.artistId;
  static const Field<EnsembleMemberEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
    opt: true,
  );
  static String? _$name(EnsembleMemberEntity v) => v.name;
  static const Field<EnsembleMemberEntity, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static String? _$cpf(EnsembleMemberEntity v) => v.cpf;
  static const Field<EnsembleMemberEntity, String> _f$cpf = Field(
    'cpf',
    _$cpf,
    opt: true,
  );
  static String? _$email(EnsembleMemberEntity v) => v.email;
  static const Field<EnsembleMemberEntity, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
  );
  static List<String>? _$specialty(EnsembleMemberEntity v) => v.specialty;
  static const Field<EnsembleMemberEntity, List<String>> _f$specialty = Field(
    'specialty',
    _$specialty,
    opt: true,
  );
  static bool _$isApproved(EnsembleMemberEntity v) => v.isApproved;
  static const Field<EnsembleMemberEntity, bool> _f$isApproved = Field(
    'isApproved',
    _$isApproved,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<EnsembleMemberEntity> fields = const {
    #id: _f$id,
    #ensembleIds: _f$ensembleIds,
    #isOwner: _f$isOwner,
    #artistId: _f$artistId,
    #name: _f$name,
    #cpf: _f$cpf,
    #email: _f$email,
    #specialty: _f$specialty,
    #isApproved: _f$isApproved,
  };

  static EnsembleMemberEntity _instantiate(DecodingData data) {
    return EnsembleMemberEntity(
      id: data.dec(_f$id),
      ensembleIds: data.dec(_f$ensembleIds),
      isOwner: data.dec(_f$isOwner),
      artistId: data.dec(_f$artistId),
      name: data.dec(_f$name),
      cpf: data.dec(_f$cpf),
      email: data.dec(_f$email),
      specialty: data.dec(_f$specialty),
      isApproved: data.dec(_f$isApproved),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EnsembleMemberEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnsembleMemberEntity>(map);
  }

  static EnsembleMemberEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EnsembleMemberEntity>(json);
  }
}

mixin EnsembleMemberEntityMappable {
  String toJson() {
    return EnsembleMemberEntityMapper.ensureInitialized()
        .encodeJson<EnsembleMemberEntity>(this as EnsembleMemberEntity);
  }

  Map<String, dynamic> toMap() {
    return EnsembleMemberEntityMapper.ensureInitialized()
        .encodeMap<EnsembleMemberEntity>(this as EnsembleMemberEntity);
  }

  EnsembleMemberEntityCopyWith<
    EnsembleMemberEntity,
    EnsembleMemberEntity,
    EnsembleMemberEntity
  >
  get copyWith =>
      _EnsembleMemberEntityCopyWithImpl<
        EnsembleMemberEntity,
        EnsembleMemberEntity
      >(this as EnsembleMemberEntity, $identity, $identity);
  @override
  String toString() {
    return EnsembleMemberEntityMapper.ensureInitialized().stringifyValue(
      this as EnsembleMemberEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return EnsembleMemberEntityMapper.ensureInitialized().equalsValue(
      this as EnsembleMemberEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return EnsembleMemberEntityMapper.ensureInitialized().hashValue(
      this as EnsembleMemberEntity,
    );
  }
}

extension EnsembleMemberEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnsembleMemberEntity, $Out> {
  EnsembleMemberEntityCopyWith<$R, EnsembleMemberEntity, $Out>
  get $asEnsembleMemberEntity => $base.as(
    (v, t, t2) => _EnsembleMemberEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class EnsembleMemberEntityCopyWith<
  $R,
  $In extends EnsembleMemberEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get ensembleIds;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get specialty;
  $R call({
    String? id,
    List<String>? ensembleIds,
    bool? isOwner,
    String? artistId,
    String? name,
    String? cpf,
    String? email,
    List<String>? specialty,
    bool? isApproved,
  });
  EnsembleMemberEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EnsembleMemberEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnsembleMemberEntity, $Out>
    implements EnsembleMemberEntityCopyWith<$R, EnsembleMemberEntity, $Out> {
  _EnsembleMemberEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnsembleMemberEntity> $mapper =
      EnsembleMemberEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get ensembleIds => $value.ensembleIds != null
      ? ListCopyWith(
          $value.ensembleIds!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(ensembleIds: v),
        )
      : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get specialty =>
      $value.specialty != null
      ? ListCopyWith(
          $value.specialty!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(specialty: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? ensembleIds = $none,
    bool? isOwner,
    Object? artistId = $none,
    Object? name = $none,
    Object? cpf = $none,
    Object? email = $none,
    Object? specialty = $none,
    bool? isApproved,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (ensembleIds != $none) #ensembleIds: ensembleIds,
      if (isOwner != null) #isOwner: isOwner,
      if (artistId != $none) #artistId: artistId,
      if (name != $none) #name: name,
      if (cpf != $none) #cpf: cpf,
      if (email != $none) #email: email,
      if (specialty != $none) #specialty: specialty,
      if (isApproved != null) #isApproved: isApproved,
    }),
  );
  @override
  EnsembleMemberEntity $make(CopyWithData data) => EnsembleMemberEntity(
    id: data.get(#id, or: $value.id),
    ensembleIds: data.get(#ensembleIds, or: $value.ensembleIds),
    isOwner: data.get(#isOwner, or: $value.isOwner),
    artistId: data.get(#artistId, or: $value.artistId),
    name: data.get(#name, or: $value.name),
    cpf: data.get(#cpf, or: $value.cpf),
    email: data.get(#email, or: $value.email),
    specialty: data.get(#specialty, or: $value.specialty),
    isApproved: data.get(#isApproved, or: $value.isApproved),
  );

  @override
  EnsembleMemberEntityCopyWith<$R2, EnsembleMemberEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EnsembleMemberEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

