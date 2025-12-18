enum EventStatusPaymentEnum {
  pending('PENDING'),
  approved('APPROVED');

  final String name;

  const EventStatusPaymentEnum(this.name);
}