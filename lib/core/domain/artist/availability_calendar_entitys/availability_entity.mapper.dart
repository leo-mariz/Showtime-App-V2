// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'availability_entity.dart';

class AvailabilityEntityMapper extends ClassMapperBase<AvailabilityEntity> {
  AvailabilityEntityMapper._();

  static AvailabilityEntityMapper? _instance;
  static AvailabilityEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AvailabilityEntityMapper._());
      AddressInfoEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AvailabilityEntity';

  static String? _$id(AvailabilityEntity v) => v.id;
  static const Field<AvailabilityEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static DateTime _$dataInicio(AvailabilityEntity v) => v.dataInicio;
  static const Field<AvailabilityEntity, DateTime> _f$dataInicio = Field(
    'dataInicio',
    _$dataInicio,
  );
  static DateTime _$dataFim(AvailabilityEntity v) => v.dataFim;
  static const Field<AvailabilityEntity, DateTime> _f$dataFim = Field(
    'dataFim',
    _$dataFim,
  );
  static String _$horarioInicio(AvailabilityEntity v) => v.horarioInicio;
  static const Field<AvailabilityEntity, String> _f$horarioInicio = Field(
    'horarioInicio',
    _$horarioInicio,
  );
  static String _$horarioFim(AvailabilityEntity v) => v.horarioFim;
  static const Field<AvailabilityEntity, String> _f$horarioFim = Field(
    'horarioFim',
    _$horarioFim,
  );
  static List<String> _$diasDaSemana(AvailabilityEntity v) => v.diasDaSemana;
  static const Field<AvailabilityEntity, List<String>> _f$diasDaSemana = Field(
    'diasDaSemana',
    _$diasDaSemana,
  );
  static double _$valorShow(AvailabilityEntity v) => v.valorShow;
  static const Field<AvailabilityEntity, double> _f$valorShow = Field(
    'valorShow',
    _$valorShow,
  );
  static AddressInfoEntity _$endereco(AvailabilityEntity v) => v.endereco;
  static const Field<AvailabilityEntity, AddressInfoEntity> _f$endereco = Field(
    'endereco',
    _$endereco,
  );
  static double _$raioAtuacao(AvailabilityEntity v) => v.raioAtuacao;
  static const Field<AvailabilityEntity, double> _f$raioAtuacao = Field(
    'raioAtuacao',
    _$raioAtuacao,
  );
  static bool _$repetir(AvailabilityEntity v) => v.repetir;
  static const Field<AvailabilityEntity, bool> _f$repetir = Field(
    'repetir',
    _$repetir,
  );

  @override
  final MappableFields<AvailabilityEntity> fields = const {
    #id: _f$id,
    #dataInicio: _f$dataInicio,
    #dataFim: _f$dataFim,
    #horarioInicio: _f$horarioInicio,
    #horarioFim: _f$horarioFim,
    #diasDaSemana: _f$diasDaSemana,
    #valorShow: _f$valorShow,
    #endereco: _f$endereco,
    #raioAtuacao: _f$raioAtuacao,
    #repetir: _f$repetir,
  };

  static AvailabilityEntity _instantiate(DecodingData data) {
    return AvailabilityEntity(
      id: data.dec(_f$id),
      dataInicio: data.dec(_f$dataInicio),
      dataFim: data.dec(_f$dataFim),
      horarioInicio: data.dec(_f$horarioInicio),
      horarioFim: data.dec(_f$horarioFim),
      diasDaSemana: data.dec(_f$diasDaSemana),
      valorShow: data.dec(_f$valorShow),
      endereco: data.dec(_f$endereco),
      raioAtuacao: data.dec(_f$raioAtuacao),
      repetir: data.dec(_f$repetir),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AvailabilityEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AvailabilityEntity>(map);
  }

  static AvailabilityEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AvailabilityEntity>(json);
  }
}

mixin AvailabilityEntityMappable {
  String toJson() {
    return AvailabilityEntityMapper.ensureInitialized()
        .encodeJson<AvailabilityEntity>(this as AvailabilityEntity);
  }

  Map<String, dynamic> toMap() {
    return AvailabilityEntityMapper.ensureInitialized()
        .encodeMap<AvailabilityEntity>(this as AvailabilityEntity);
  }

  AvailabilityEntityCopyWith<
    AvailabilityEntity,
    AvailabilityEntity,
    AvailabilityEntity
  >
  get copyWith =>
      _AvailabilityEntityCopyWithImpl<AvailabilityEntity, AvailabilityEntity>(
        this as AvailabilityEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AvailabilityEntityMapper.ensureInitialized().stringifyValue(
      this as AvailabilityEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return AvailabilityEntityMapper.ensureInitialized().equalsValue(
      this as AvailabilityEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return AvailabilityEntityMapper.ensureInitialized().hashValue(
      this as AvailabilityEntity,
    );
  }
}

extension AvailabilityEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AvailabilityEntity, $Out> {
  AvailabilityEntityCopyWith<$R, AvailabilityEntity, $Out>
  get $asAvailabilityEntity => $base.as(
    (v, t, t2) => _AvailabilityEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AvailabilityEntityCopyWith<
  $R,
  $In extends AvailabilityEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get diasDaSemana;
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco;
  $R call({
    String? id,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? horarioInicio,
    String? horarioFim,
    List<String>? diasDaSemana,
    double? valorShow,
    AddressInfoEntity? endereco,
    double? raioAtuacao,
    bool? repetir,
  });
  AvailabilityEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AvailabilityEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AvailabilityEntity, $Out>
    implements AvailabilityEntityCopyWith<$R, AvailabilityEntity, $Out> {
  _AvailabilityEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AvailabilityEntity> $mapper =
      AvailabilityEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get diasDaSemana => ListCopyWith(
    $value.diasDaSemana,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(diasDaSemana: v),
  );
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get endereco => $value.endereco.copyWith.$chain((v) => call(endereco: v));
  @override
  $R call({
    Object? id = $none,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? horarioInicio,
    String? horarioFim,
    List<String>? diasDaSemana,
    double? valorShow,
    AddressInfoEntity? endereco,
    double? raioAtuacao,
    bool? repetir,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (dataInicio != null) #dataInicio: dataInicio,
      if (dataFim != null) #dataFim: dataFim,
      if (horarioInicio != null) #horarioInicio: horarioInicio,
      if (horarioFim != null) #horarioFim: horarioFim,
      if (diasDaSemana != null) #diasDaSemana: diasDaSemana,
      if (valorShow != null) #valorShow: valorShow,
      if (endereco != null) #endereco: endereco,
      if (raioAtuacao != null) #raioAtuacao: raioAtuacao,
      if (repetir != null) #repetir: repetir,
    }),
  );
  @override
  AvailabilityEntity $make(CopyWithData data) => AvailabilityEntity(
    id: data.get(#id, or: $value.id),
    dataInicio: data.get(#dataInicio, or: $value.dataInicio),
    dataFim: data.get(#dataFim, or: $value.dataFim),
    horarioInicio: data.get(#horarioInicio, or: $value.horarioInicio),
    horarioFim: data.get(#horarioFim, or: $value.horarioFim),
    diasDaSemana: data.get(#diasDaSemana, or: $value.diasDaSemana),
    valorShow: data.get(#valorShow, or: $value.valorShow),
    endereco: data.get(#endereco, or: $value.endereco),
    raioAtuacao: data.get(#raioAtuacao, or: $value.raioAtuacao),
    repetir: data.get(#repetir, or: $value.repetir),
  );

  @override
  AvailabilityEntityCopyWith<$R2, AvailabilityEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AvailabilityEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

