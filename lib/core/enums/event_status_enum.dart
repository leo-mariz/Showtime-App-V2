enum EventStatusEnum {
  pending('PENDING'), //Cliente solicitou o evento
  accepted('ACCEPTED'), //Artista aceitou o evento
  canceled('CANCELED'), //Cliente ou artista cancelou o evento
  rejected('REJECTED'), //Artista recusou o evento
  finished('FINISHED'), //Evento finalizado
  paid('PAID'), //Cliente realizou o pagamento
  pendingPayment('PENDING_PAYMENT'); //Cliente com pagamento pendente

  final String name;

  const EventStatusEnum(this.name);
}