// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'contract_entity.dart';

class ContractEntityMapper extends ClassMapperBase<ContractEntity> {
  ContractEntityMapper._();

  static ContractEntityMapper? _instance;
  static ContractEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContractEntityMapper._());
      AddressInfoEntityMapper.ensureInitialized();
      ContractorTypeEnumMapper.ensureInitialized();
      AvailabilityDayEntityMapper.ensureInitialized();
      EventTypeEntityMapper.ensureInitialized();
      ContractStatusEnumMapper.ensureInitialized();
      RatingEntityMapper.ensureInitialized();
      ShowRatingRequestedEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ContractEntity';

  static DateTime _$date(ContractEntity v) => v.date;
  static const Field<ContractEntity, DateTime> _f$date = Field('date', _$date);
  static String _$time(ContractEntity v) => v.time;
  static const Field<ContractEntity, String> _f$time = Field('time', _$time);
  static int _$duration(ContractEntity v) => v.duration;
  static const Field<ContractEntity, int> _f$duration = Field(
    'duration',
    _$duration,
  );
  static int? _$preparationTime(ContractEntity v) => v.preparationTime;
  static const Field<ContractEntity, int> _f$preparationTime = Field(
    'preparationTime',
    _$preparationTime,
  );
  static AddressInfoEntity _$address(ContractEntity v) => v.address;
  static const Field<ContractEntity, AddressInfoEntity> _f$address = Field(
    'address',
    _$address,
  );
  static ContractorTypeEnum _$contractorType(ContractEntity v) =>
      v.contractorType;
  static const Field<ContractEntity, ContractorTypeEnum> _f$contractorType =
      Field('contractorType', _$contractorType);
  static String? _$refClient(ContractEntity v) => v.refClient;
  static const Field<ContractEntity, String> _f$refClient = Field(
    'refClient',
    _$refClient,
  );
  static String? _$uid(ContractEntity v) => v.uid;
  static const Field<ContractEntity, String> _f$uid = Field(
    'uid',
    _$uid,
    opt: true,
  );
  static String? _$refArtist(ContractEntity v) => v.refArtist;
  static const Field<ContractEntity, String> _f$refArtist = Field(
    'refArtist',
    _$refArtist,
    opt: true,
  );
  static String? _$refGroup(ContractEntity v) => v.refGroup;
  static const Field<ContractEntity, String> _f$refGroup = Field(
    'refGroup',
    _$refGroup,
    opt: true,
  );
  static String? _$refArtistOwner(ContractEntity v) => v.refArtistOwner;
  static const Field<ContractEntity, String> _f$refArtistOwner = Field(
    'refArtistOwner',
    _$refArtistOwner,
    opt: true,
  );
  static String? _$nameArtist(ContractEntity v) => v.nameArtist;
  static const Field<ContractEntity, String> _f$nameArtist = Field(
    'nameArtist',
    _$nameArtist,
    opt: true,
  );
  static String? _$nameGroup(ContractEntity v) => v.nameGroup;
  static const Field<ContractEntity, String> _f$nameGroup = Field(
    'nameGroup',
    _$nameGroup,
    opt: true,
  );
  static String? _$nameClient(ContractEntity v) => v.nameClient;
  static const Field<ContractEntity, String> _f$nameClient = Field(
    'nameClient',
    _$nameClient,
    opt: true,
  );
  static double? _$clientRating(ContractEntity v) => v.clientRating;
  static const Field<ContractEntity, double> _f$clientRating = Field(
    'clientRating',
    _$clientRating,
    opt: true,
  );
  static int? _$clientRatingCount(ContractEntity v) => v.clientRatingCount;
  static const Field<ContractEntity, int> _f$clientRatingCount = Field(
    'clientRatingCount',
    _$clientRatingCount,
    opt: true,
  );
  static AvailabilityDayEntity? _$availabilitySnapshot(ContractEntity v) =>
      v.availabilitySnapshot;
  static const Field<ContractEntity, AvailabilityDayEntity>
  _f$availabilitySnapshot = Field(
    'availabilitySnapshot',
    _$availabilitySnapshot,
    opt: true,
  );
  static EventTypeEntity? _$eventType(ContractEntity v) => v.eventType;
  static const Field<ContractEntity, EventTypeEntity> _f$eventType = Field(
    'eventType',
    _$eventType,
    opt: true,
  );
  static ContractStatusEnum _$status(ContractEntity v) => v.status;
  static const Field<ContractEntity, ContractStatusEnum> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: ContractStatusEnum.pending,
  );
  static double _$value(ContractEntity v) => v.value;
  static const Field<ContractEntity, double> _f$value = Field(
    'value',
    _$value,
    opt: true,
    def: 0.0,
  );
  static String? _$linkPayment(ContractEntity v) => v.linkPayment;
  static const Field<ContractEntity, String> _f$linkPayment = Field(
    'linkPayment',
    _$linkPayment,
    opt: true,
  );
  static DateTime? _$paymentDueDate(ContractEntity v) => v.paymentDueDate;
  static const Field<ContractEntity, DateTime> _f$paymentDueDate = Field(
    'paymentDueDate',
    _$paymentDueDate,
    opt: true,
  );
  static DateTime? _$paymentDate(ContractEntity v) => v.paymentDate;
  static const Field<ContractEntity, DateTime> _f$paymentDate = Field(
    'paymentDate',
    _$paymentDate,
    opt: true,
  );
  static String? _$keyCode(ContractEntity v) => v.keyCode;
  static const Field<ContractEntity, String> _f$keyCode = Field(
    'keyCode',
    _$keyCode,
    opt: true,
  );
  static DateTime? _$showConfirmedAt(ContractEntity v) => v.showConfirmedAt;
  static const Field<ContractEntity, DateTime> _f$showConfirmedAt = Field(
    'showConfirmedAt',
    _$showConfirmedAt,
    opt: true,
  );
  static DateTime? _$ratingsPublishedAt(ContractEntity v) =>
      v.ratingsPublishedAt;
  static const Field<ContractEntity, DateTime> _f$ratingsPublishedAt = Field(
    'ratingsPublishedAt',
    _$ratingsPublishedAt,
    opt: true,
  );
  static RatingEntity? _$rateByClient(ContractEntity v) => v.rateByClient;
  static const Field<ContractEntity, RatingEntity> _f$rateByClient = Field(
    'rateByClient',
    _$rateByClient,
    opt: true,
  );
  static RatingEntity? _$rateByArtist(ContractEntity v) => v.rateByArtist;
  static const Field<ContractEntity, RatingEntity> _f$rateByArtist = Field(
    'rateByArtist',
    _$rateByArtist,
    opt: true,
  );
  static ShowRatingRequestedEntity? _$showRatingRequestedEntityByArtist(
    ContractEntity v,
  ) => v.showRatingRequestedEntityByArtist;
  static const Field<ContractEntity, ShowRatingRequestedEntity>
  _f$showRatingRequestedEntityByArtist = Field(
    'showRatingRequestedEntityByArtist',
    _$showRatingRequestedEntityByArtist,
    opt: true,
  );
  static ShowRatingRequestedEntity? _$showRatingRequestedEntityByClient(
    ContractEntity v,
  ) => v.showRatingRequestedEntityByClient;
  static const Field<ContractEntity, ShowRatingRequestedEntity>
  _f$showRatingRequestedEntityByClient = Field(
    'showRatingRequestedEntityByClient',
    _$showRatingRequestedEntityByClient,
    opt: true,
  );
  static DateTime? _$createdAt(ContractEntity v) => v.createdAt;
  static const Field<ContractEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );
  static DateTime? _$acceptedAt(ContractEntity v) => v.acceptedAt;
  static const Field<ContractEntity, DateTime> _f$acceptedAt = Field(
    'acceptedAt',
    _$acceptedAt,
    opt: true,
  );
  static DateTime? _$rejectedAt(ContractEntity v) => v.rejectedAt;
  static const Field<ContractEntity, DateTime> _f$rejectedAt = Field(
    'rejectedAt',
    _$rejectedAt,
    opt: true,
  );
  static DateTime? _$canceledAt(ContractEntity v) => v.canceledAt;
  static const Field<ContractEntity, DateTime> _f$canceledAt = Field(
    'canceledAt',
    _$canceledAt,
    opt: true,
  );
  static String? _$canceledBy(ContractEntity v) => v.canceledBy;
  static const Field<ContractEntity, String> _f$canceledBy = Field(
    'canceledBy',
    _$canceledBy,
    opt: true,
  );
  static String? _$cancelReason(ContractEntity v) => v.cancelReason;
  static const Field<ContractEntity, String> _f$cancelReason = Field(
    'cancelReason',
    _$cancelReason,
    opt: true,
  );
  static DateTime? _$statusChangedAt(ContractEntity v) => v.statusChangedAt;
  static const Field<ContractEntity, DateTime> _f$statusChangedAt = Field(
    'statusChangedAt',
    _$statusChangedAt,
    opt: true,
  );
  static DateTime? _$acceptDeadline(ContractEntity v) => v.acceptDeadline;
  static const Field<ContractEntity, DateTime> _f$acceptDeadline = Field(
    'acceptDeadline',
    _$acceptDeadline,
    opt: true,
  );
  static String? _$clientPhotoUrl(ContractEntity v) => v.clientPhotoUrl;
  static const Field<ContractEntity, String> _f$clientPhotoUrl = Field(
    'clientPhotoUrl',
    _$clientPhotoUrl,
    opt: true,
  );
  static String? _$contractorPhotoUrl(ContractEntity v) => v.contractorPhotoUrl;
  static const Field<ContractEntity, String> _f$contractorPhotoUrl = Field(
    'contractorPhotoUrl',
    _$contractorPhotoUrl,
    opt: true,
  );
  static bool? _$isPaying(ContractEntity v) => v.isPaying;
  static const Field<ContractEntity, bool> _f$isPaying = Field(
    'isPaying',
    _$isPaying,
    opt: true,
    def: false,
  );
  static bool? _$analyseRefund(ContractEntity v) => v.analyseRefund;
  static const Field<ContractEntity, bool> _f$analyseRefund = Field(
    'analyseRefund',
    _$analyseRefund,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<ContractEntity> fields = const {
    #date: _f$date,
    #time: _f$time,
    #duration: _f$duration,
    #preparationTime: _f$preparationTime,
    #address: _f$address,
    #contractorType: _f$contractorType,
    #refClient: _f$refClient,
    #uid: _f$uid,
    #refArtist: _f$refArtist,
    #refGroup: _f$refGroup,
    #refArtistOwner: _f$refArtistOwner,
    #nameArtist: _f$nameArtist,
    #nameGroup: _f$nameGroup,
    #nameClient: _f$nameClient,
    #clientRating: _f$clientRating,
    #clientRatingCount: _f$clientRatingCount,
    #availabilitySnapshot: _f$availabilitySnapshot,
    #eventType: _f$eventType,
    #status: _f$status,
    #value: _f$value,
    #linkPayment: _f$linkPayment,
    #paymentDueDate: _f$paymentDueDate,
    #paymentDate: _f$paymentDate,
    #keyCode: _f$keyCode,
    #showConfirmedAt: _f$showConfirmedAt,
    #ratingsPublishedAt: _f$ratingsPublishedAt,
    #rateByClient: _f$rateByClient,
    #rateByArtist: _f$rateByArtist,
    #showRatingRequestedEntityByArtist: _f$showRatingRequestedEntityByArtist,
    #showRatingRequestedEntityByClient: _f$showRatingRequestedEntityByClient,
    #createdAt: _f$createdAt,
    #acceptedAt: _f$acceptedAt,
    #rejectedAt: _f$rejectedAt,
    #canceledAt: _f$canceledAt,
    #canceledBy: _f$canceledBy,
    #cancelReason: _f$cancelReason,
    #statusChangedAt: _f$statusChangedAt,
    #acceptDeadline: _f$acceptDeadline,
    #clientPhotoUrl: _f$clientPhotoUrl,
    #contractorPhotoUrl: _f$contractorPhotoUrl,
    #isPaying: _f$isPaying,
    #analyseRefund: _f$analyseRefund,
  };

  static ContractEntity _instantiate(DecodingData data) {
    return ContractEntity(
      date: data.dec(_f$date),
      time: data.dec(_f$time),
      duration: data.dec(_f$duration),
      preparationTime: data.dec(_f$preparationTime),
      address: data.dec(_f$address),
      contractorType: data.dec(_f$contractorType),
      refClient: data.dec(_f$refClient),
      uid: data.dec(_f$uid),
      refArtist: data.dec(_f$refArtist),
      refGroup: data.dec(_f$refGroup),
      refArtistOwner: data.dec(_f$refArtistOwner),
      nameArtist: data.dec(_f$nameArtist),
      nameGroup: data.dec(_f$nameGroup),
      nameClient: data.dec(_f$nameClient),
      clientRating: data.dec(_f$clientRating),
      clientRatingCount: data.dec(_f$clientRatingCount),
      availabilitySnapshot: data.dec(_f$availabilitySnapshot),
      eventType: data.dec(_f$eventType),
      status: data.dec(_f$status),
      value: data.dec(_f$value),
      linkPayment: data.dec(_f$linkPayment),
      paymentDueDate: data.dec(_f$paymentDueDate),
      paymentDate: data.dec(_f$paymentDate),
      keyCode: data.dec(_f$keyCode),
      showConfirmedAt: data.dec(_f$showConfirmedAt),
      ratingsPublishedAt: data.dec(_f$ratingsPublishedAt),
      rateByClient: data.dec(_f$rateByClient),
      rateByArtist: data.dec(_f$rateByArtist),
      showRatingRequestedEntityByArtist: data.dec(
        _f$showRatingRequestedEntityByArtist,
      ),
      showRatingRequestedEntityByClient: data.dec(
        _f$showRatingRequestedEntityByClient,
      ),
      createdAt: data.dec(_f$createdAt),
      acceptedAt: data.dec(_f$acceptedAt),
      rejectedAt: data.dec(_f$rejectedAt),
      canceledAt: data.dec(_f$canceledAt),
      canceledBy: data.dec(_f$canceledBy),
      cancelReason: data.dec(_f$cancelReason),
      statusChangedAt: data.dec(_f$statusChangedAt),
      acceptDeadline: data.dec(_f$acceptDeadline),
      clientPhotoUrl: data.dec(_f$clientPhotoUrl),
      contractorPhotoUrl: data.dec(_f$contractorPhotoUrl),
      isPaying: data.dec(_f$isPaying),
      analyseRefund: data.dec(_f$analyseRefund),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ContractEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ContractEntity>(map);
  }

  static ContractEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ContractEntity>(json);
  }
}

mixin ContractEntityMappable {
  String toJson() {
    return ContractEntityMapper.ensureInitialized().encodeJson<ContractEntity>(
      this as ContractEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return ContractEntityMapper.ensureInitialized().encodeMap<ContractEntity>(
      this as ContractEntity,
    );
  }

  ContractEntityCopyWith<ContractEntity, ContractEntity, ContractEntity>
  get copyWith => _ContractEntityCopyWithImpl<ContractEntity, ContractEntity>(
    this as ContractEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ContractEntityMapper.ensureInitialized().stringifyValue(
      this as ContractEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ContractEntityMapper.ensureInitialized().equalsValue(
      this as ContractEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ContractEntityMapper.ensureInitialized().hashValue(
      this as ContractEntity,
    );
  }
}

extension ContractEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ContractEntity, $Out> {
  ContractEntityCopyWith<$R, ContractEntity, $Out> get $asContractEntity =>
      $base.as((v, t, t2) => _ContractEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ContractEntityCopyWith<$R, $In extends ContractEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get address;
  AvailabilityDayEntityCopyWith<
    $R,
    AvailabilityDayEntity,
    AvailabilityDayEntity
  >?
  get availabilitySnapshot;
  EventTypeEntityCopyWith<$R, EventTypeEntity, EventTypeEntity>? get eventType;
  RatingEntityCopyWith<$R, RatingEntity, RatingEntity>? get rateByClient;
  RatingEntityCopyWith<$R, RatingEntity, RatingEntity>? get rateByArtist;
  ShowRatingRequestedEntityCopyWith<
    $R,
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity
  >?
  get showRatingRequestedEntityByArtist;
  ShowRatingRequestedEntityCopyWith<
    $R,
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity
  >?
  get showRatingRequestedEntityByClient;
  $R call({
    DateTime? date,
    String? time,
    int? duration,
    int? preparationTime,
    AddressInfoEntity? address,
    ContractorTypeEnum? contractorType,
    String? refClient,
    String? uid,
    String? refArtist,
    String? refGroup,
    String? refArtistOwner,
    String? nameArtist,
    String? nameGroup,
    String? nameClient,
    double? clientRating,
    int? clientRatingCount,
    AvailabilityDayEntity? availabilitySnapshot,
    EventTypeEntity? eventType,
    ContractStatusEnum? status,
    double? value,
    String? linkPayment,
    DateTime? paymentDueDate,
    DateTime? paymentDate,
    String? keyCode,
    DateTime? showConfirmedAt,
    DateTime? ratingsPublishedAt,
    RatingEntity? rateByClient,
    RatingEntity? rateByArtist,
    ShowRatingRequestedEntity? showRatingRequestedEntityByArtist,
    ShowRatingRequestedEntity? showRatingRequestedEntityByClient,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? canceledAt,
    String? canceledBy,
    String? cancelReason,
    DateTime? statusChangedAt,
    DateTime? acceptDeadline,
    String? clientPhotoUrl,
    String? contractorPhotoUrl,
    bool? isPaying,
    bool? analyseRefund,
  });
  ContractEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ContractEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ContractEntity, $Out>
    implements ContractEntityCopyWith<$R, ContractEntity, $Out> {
  _ContractEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ContractEntity> $mapper =
      ContractEntityMapper.ensureInitialized();
  @override
  AddressInfoEntityCopyWith<$R, AddressInfoEntity, AddressInfoEntity>
  get address => $value.address.copyWith.$chain((v) => call(address: v));
  @override
  AvailabilityDayEntityCopyWith<
    $R,
    AvailabilityDayEntity,
    AvailabilityDayEntity
  >?
  get availabilitySnapshot => $value.availabilitySnapshot?.copyWith.$chain(
    (v) => call(availabilitySnapshot: v),
  );
  @override
  EventTypeEntityCopyWith<$R, EventTypeEntity, EventTypeEntity>?
  get eventType => $value.eventType?.copyWith.$chain((v) => call(eventType: v));
  @override
  RatingEntityCopyWith<$R, RatingEntity, RatingEntity>? get rateByClient =>
      $value.rateByClient?.copyWith.$chain((v) => call(rateByClient: v));
  @override
  RatingEntityCopyWith<$R, RatingEntity, RatingEntity>? get rateByArtist =>
      $value.rateByArtist?.copyWith.$chain((v) => call(rateByArtist: v));
  @override
  ShowRatingRequestedEntityCopyWith<
    $R,
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity
  >?
  get showRatingRequestedEntityByArtist => $value
      .showRatingRequestedEntityByArtist
      ?.copyWith
      .$chain((v) => call(showRatingRequestedEntityByArtist: v));
  @override
  ShowRatingRequestedEntityCopyWith<
    $R,
    ShowRatingRequestedEntity,
    ShowRatingRequestedEntity
  >?
  get showRatingRequestedEntityByClient => $value
      .showRatingRequestedEntityByClient
      ?.copyWith
      .$chain((v) => call(showRatingRequestedEntityByClient: v));
  @override
  $R call({
    DateTime? date,
    String? time,
    int? duration,
    Object? preparationTime = $none,
    AddressInfoEntity? address,
    ContractorTypeEnum? contractorType,
    Object? refClient = $none,
    Object? uid = $none,
    Object? refArtist = $none,
    Object? refGroup = $none,
    Object? refArtistOwner = $none,
    Object? nameArtist = $none,
    Object? nameGroup = $none,
    Object? nameClient = $none,
    Object? clientRating = $none,
    Object? clientRatingCount = $none,
    Object? availabilitySnapshot = $none,
    Object? eventType = $none,
    ContractStatusEnum? status,
    double? value,
    Object? linkPayment = $none,
    Object? paymentDueDate = $none,
    Object? paymentDate = $none,
    Object? keyCode = $none,
    Object? showConfirmedAt = $none,
    Object? ratingsPublishedAt = $none,
    Object? rateByClient = $none,
    Object? rateByArtist = $none,
    Object? showRatingRequestedEntityByArtist = $none,
    Object? showRatingRequestedEntityByClient = $none,
    Object? createdAt = $none,
    Object? acceptedAt = $none,
    Object? rejectedAt = $none,
    Object? canceledAt = $none,
    Object? canceledBy = $none,
    Object? cancelReason = $none,
    Object? statusChangedAt = $none,
    Object? acceptDeadline = $none,
    Object? clientPhotoUrl = $none,
    Object? contractorPhotoUrl = $none,
    Object? isPaying = $none,
    Object? analyseRefund = $none,
  }) => $apply(
    FieldCopyWithData({
      if (date != null) #date: date,
      if (time != null) #time: time,
      if (duration != null) #duration: duration,
      if (preparationTime != $none) #preparationTime: preparationTime,
      if (address != null) #address: address,
      if (contractorType != null) #contractorType: contractorType,
      if (refClient != $none) #refClient: refClient,
      if (uid != $none) #uid: uid,
      if (refArtist != $none) #refArtist: refArtist,
      if (refGroup != $none) #refGroup: refGroup,
      if (refArtistOwner != $none) #refArtistOwner: refArtistOwner,
      if (nameArtist != $none) #nameArtist: nameArtist,
      if (nameGroup != $none) #nameGroup: nameGroup,
      if (nameClient != $none) #nameClient: nameClient,
      if (clientRating != $none) #clientRating: clientRating,
      if (clientRatingCount != $none) #clientRatingCount: clientRatingCount,
      if (availabilitySnapshot != $none)
        #availabilitySnapshot: availabilitySnapshot,
      if (eventType != $none) #eventType: eventType,
      if (status != null) #status: status,
      if (value != null) #value: value,
      if (linkPayment != $none) #linkPayment: linkPayment,
      if (paymentDueDate != $none) #paymentDueDate: paymentDueDate,
      if (paymentDate != $none) #paymentDate: paymentDate,
      if (keyCode != $none) #keyCode: keyCode,
      if (showConfirmedAt != $none) #showConfirmedAt: showConfirmedAt,
      if (ratingsPublishedAt != $none) #ratingsPublishedAt: ratingsPublishedAt,
      if (rateByClient != $none) #rateByClient: rateByClient,
      if (rateByArtist != $none) #rateByArtist: rateByArtist,
      if (showRatingRequestedEntityByArtist != $none)
        #showRatingRequestedEntityByArtist: showRatingRequestedEntityByArtist,
      if (showRatingRequestedEntityByClient != $none)
        #showRatingRequestedEntityByClient: showRatingRequestedEntityByClient,
      if (createdAt != $none) #createdAt: createdAt,
      if (acceptedAt != $none) #acceptedAt: acceptedAt,
      if (rejectedAt != $none) #rejectedAt: rejectedAt,
      if (canceledAt != $none) #canceledAt: canceledAt,
      if (canceledBy != $none) #canceledBy: canceledBy,
      if (cancelReason != $none) #cancelReason: cancelReason,
      if (statusChangedAt != $none) #statusChangedAt: statusChangedAt,
      if (acceptDeadline != $none) #acceptDeadline: acceptDeadline,
      if (clientPhotoUrl != $none) #clientPhotoUrl: clientPhotoUrl,
      if (contractorPhotoUrl != $none) #contractorPhotoUrl: contractorPhotoUrl,
      if (isPaying != $none) #isPaying: isPaying,
      if (analyseRefund != $none) #analyseRefund: analyseRefund,
    }),
  );
  @override
  ContractEntity $make(CopyWithData data) => ContractEntity(
    date: data.get(#date, or: $value.date),
    time: data.get(#time, or: $value.time),
    duration: data.get(#duration, or: $value.duration),
    preparationTime: data.get(#preparationTime, or: $value.preparationTime),
    address: data.get(#address, or: $value.address),
    contractorType: data.get(#contractorType, or: $value.contractorType),
    refClient: data.get(#refClient, or: $value.refClient),
    uid: data.get(#uid, or: $value.uid),
    refArtist: data.get(#refArtist, or: $value.refArtist),
    refGroup: data.get(#refGroup, or: $value.refGroup),
    refArtistOwner: data.get(#refArtistOwner, or: $value.refArtistOwner),
    nameArtist: data.get(#nameArtist, or: $value.nameArtist),
    nameGroup: data.get(#nameGroup, or: $value.nameGroup),
    nameClient: data.get(#nameClient, or: $value.nameClient),
    clientRating: data.get(#clientRating, or: $value.clientRating),
    clientRatingCount: data.get(
      #clientRatingCount,
      or: $value.clientRatingCount,
    ),
    availabilitySnapshot: data.get(
      #availabilitySnapshot,
      or: $value.availabilitySnapshot,
    ),
    eventType: data.get(#eventType, or: $value.eventType),
    status: data.get(#status, or: $value.status),
    value: data.get(#value, or: $value.value),
    linkPayment: data.get(#linkPayment, or: $value.linkPayment),
    paymentDueDate: data.get(#paymentDueDate, or: $value.paymentDueDate),
    paymentDate: data.get(#paymentDate, or: $value.paymentDate),
    keyCode: data.get(#keyCode, or: $value.keyCode),
    showConfirmedAt: data.get(#showConfirmedAt, or: $value.showConfirmedAt),
    ratingsPublishedAt: data.get(
      #ratingsPublishedAt,
      or: $value.ratingsPublishedAt,
    ),
    rateByClient: data.get(#rateByClient, or: $value.rateByClient),
    rateByArtist: data.get(#rateByArtist, or: $value.rateByArtist),
    showRatingRequestedEntityByArtist: data.get(
      #showRatingRequestedEntityByArtist,
      or: $value.showRatingRequestedEntityByArtist,
    ),
    showRatingRequestedEntityByClient: data.get(
      #showRatingRequestedEntityByClient,
      or: $value.showRatingRequestedEntityByClient,
    ),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    acceptedAt: data.get(#acceptedAt, or: $value.acceptedAt),
    rejectedAt: data.get(#rejectedAt, or: $value.rejectedAt),
    canceledAt: data.get(#canceledAt, or: $value.canceledAt),
    canceledBy: data.get(#canceledBy, or: $value.canceledBy),
    cancelReason: data.get(#cancelReason, or: $value.cancelReason),
    statusChangedAt: data.get(#statusChangedAt, or: $value.statusChangedAt),
    acceptDeadline: data.get(#acceptDeadline, or: $value.acceptDeadline),
    clientPhotoUrl: data.get(#clientPhotoUrl, or: $value.clientPhotoUrl),
    contractorPhotoUrl: data.get(
      #contractorPhotoUrl,
      or: $value.contractorPhotoUrl,
    ),
    isPaying: data.get(#isPaying, or: $value.isPaying),
    analyseRefund: data.get(#analyseRefund, or: $value.analyseRefund),
  );

  @override
  ContractEntityCopyWith<$R2, ContractEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ContractEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

