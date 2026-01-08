import 'package:dart_mappable/dart_mappable.dart';

part 'contract_status_enum.mapper.dart';

@MappableEnum()
enum ContractStatusEnum {
  @MappableValue('PENDING')
  pending,           // Cliente solicitou o evento
  @MappableValue('ACCEPTED')
  accepted,         // Artista aceitou o evento
  @MappableValue('REJECTED')
  rejected,         // Artista recusou o evento
  @MappableValue('PAYMENT_PENDING')
  paymentPending,   // Aguardando pagamento
  @MappableValue('PAYMENT_EXPIRED')
  paymentExpired,   // Prazo de pagamento expirado
  @MappableValue('PAYMENT_REFUSED')
  paymentRefused,   // Pagamento recusado
  @MappableValue('PAYMENT_FAILED')
  paymentFailed,   // Pagamento falhou
  @MappableValue('PAID')
  paid,            // Cliente realizou o pagamento
  @MappableValue('CONFIRMED')
  confirmed,       // Show confirmado (código validado)
  @MappableValue('COMPLETED')
  completed,       // Evento finalizado
  @MappableValue('RATED')
  rated,           // Avaliado pelo cliente
  @MappableValue('CANCELED')
  canceled;        // Cancelado por qualquer parte

  String get value {
    switch (this) {
      case ContractStatusEnum.pending:
        return 'PENDING';
      case ContractStatusEnum.accepted:
        return 'ACCEPTED';
      case ContractStatusEnum.rejected:
        return 'REJECTED';
      case ContractStatusEnum.paymentPending:
        return 'PAYMENT_PENDING';
      case ContractStatusEnum.paymentExpired:
        return 'PAYMENT_EXPIRED';
      case ContractStatusEnum.paymentRefused:
        return 'PAYMENT_REFUSED';
      case ContractStatusEnum.paymentFailed:
        return 'PAYMENT_FAILED';
      case ContractStatusEnum.paid:
        return 'PAID';
      case ContractStatusEnum.confirmed:
        return 'CONFIRMED';
      case ContractStatusEnum.completed:
        return 'COMPLETED';
      case ContractStatusEnum.rated:
        return 'RATED';
      case ContractStatusEnum.canceled:
        return 'CANCELED';
    }
  }
}

