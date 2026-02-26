// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ensemble_member.dart';

class EnsembleMemberMapper extends ClassMapperBase<EnsembleMember> {
  EnsembleMemberMapper._();

  static EnsembleMemberMapper? _instance;
  static EnsembleMemberMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EnsembleMemberMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EnsembleMember';

  static String _$memberId(EnsembleMember v) => v.memberId;
  static const Field<EnsembleMember, String> _f$memberId = Field(
    'memberId',
    _$memberId,
  );
  static List<String>? _$specialty(EnsembleMember v) => v.specialty;
  static const Field<EnsembleMember, List<String>> _f$specialty = Field(
    'specialty',
    _$specialty,
    opt: true,
  );
  static bool _$isOwner(EnsembleMember v) => v.isOwner;
  static const Field<EnsembleMember, bool> _f$isOwner = Field(
    'isOwner',
    _$isOwner,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<EnsembleMember> fields = const {
    #memberId: _f$memberId,
    #specialty: _f$specialty,
    #isOwner: _f$isOwner,
  };

  static EnsembleMember _instantiate(DecodingData data) {
    return EnsembleMember(
      memberId: data.dec(_f$memberId),
      specialty: data.dec(_f$specialty),
      isOwner: data.dec(_f$isOwner),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EnsembleMember fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EnsembleMember>(map);
  }

  static EnsembleMember fromJson(String json) {
    return ensureInitialized().decodeJson<EnsembleMember>(json);
  }
}

mixin EnsembleMemberMappable {
  String toJson() {
    return EnsembleMemberMapper.ensureInitialized().encodeJson<EnsembleMember>(
      this as EnsembleMember,
    );
  }

  Map<String, dynamic> toMap() {
    return EnsembleMemberMapper.ensureInitialized().encodeMap<EnsembleMember>(
      this as EnsembleMember,
    );
  }

  EnsembleMemberCopyWith<EnsembleMember, EnsembleMember, EnsembleMember>
  get copyWith => _EnsembleMemberCopyWithImpl<EnsembleMember, EnsembleMember>(
    this as EnsembleMember,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EnsembleMemberMapper.ensureInitialized().stringifyValue(
      this as EnsembleMember,
    );
  }

  @override
  bool operator ==(Object other) {
    return EnsembleMemberMapper.ensureInitialized().equalsValue(
      this as EnsembleMember,
      other,
    );
  }

  @override
  int get hashCode {
    return EnsembleMemberMapper.ensureInitialized().hashValue(
      this as EnsembleMember,
    );
  }
}

extension EnsembleMemberValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EnsembleMember, $Out> {
  EnsembleMemberCopyWith<$R, EnsembleMember, $Out> get $asEnsembleMember =>
      $base.as((v, t, t2) => _EnsembleMemberCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EnsembleMemberCopyWith<$R, $In extends EnsembleMember, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get specialty;
  $R call({String? memberId, List<String>? specialty, bool? isOwner});
  EnsembleMemberCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EnsembleMemberCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EnsembleMember, $Out>
    implements EnsembleMemberCopyWith<$R, EnsembleMember, $Out> {
  _EnsembleMemberCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EnsembleMember> $mapper =
      EnsembleMemberMapper.ensureInitialized();
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
  $R call({String? memberId, Object? specialty = $none, bool? isOwner}) =>
      $apply(
        FieldCopyWithData({
          if (memberId != null) #memberId: memberId,
          if (specialty != $none) #specialty: specialty,
          if (isOwner != null) #isOwner: isOwner,
        }),
      );
  @override
  EnsembleMember $make(CopyWithData data) => EnsembleMember(
    memberId: data.get(#memberId, or: $value.memberId),
    specialty: data.get(#specialty, or: $value.specialty),
    isOwner: data.get(#isOwner, or: $value.isOwner),
  );

  @override
  EnsembleMemberCopyWith<$R2, EnsembleMember, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EnsembleMemberCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

