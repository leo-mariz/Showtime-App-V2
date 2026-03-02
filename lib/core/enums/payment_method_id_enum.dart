import 'package:dart_mappable/dart_mappable.dart';

part 'payment_method_id_enum.mapper.dart';

/// Métodos de pagamento do Mercado Pago (payment_method_id ou payment_method.id).
/// Valores em minúsculas para coincidir com o Firestore e com o backend.
@MappableEnum()
enum PaymentMethodIdEnum {
  @MappableValue('pix')
  pix,

  @MappableValue('account_money')
  accountMoney,

  @MappableValue('credit_card')
  creditCard,

  @MappableValue('debit_card')
  debitCard,

  @MappableValue('prepaid_card')
  prepaidCard,

  @MappableValue('ticket')
  ticket,

  @MappableValue('visa')
  visa,

  @MappableValue('master')
  master,

  @MappableValue('mastercard')
  mastercard,

  @MappableValue('amex')
  amex,

  @MappableValue('hipercard')
  hipercard,

  @MappableValue('elo')
  elo,

  @MappableValue('naranja')
  naranja,

  @MappableValue('debvisa')
  debVisa,

  @MappableValue('debmaster')
  debMaster,

  @MappableValue('other')
  other,
}

extension PaymentMethodIdDisplay on PaymentMethodIdEnum {
  String get displayName {
    switch (this) {
      case PaymentMethodIdEnum.pix:
        return 'PIX';
      case PaymentMethodIdEnum.accountMoney:
        return 'Saldo em conta';
      case PaymentMethodIdEnum.creditCard:
        return 'Cartão de crédito';
      case PaymentMethodIdEnum.debitCard:
        return 'Cartão de débito';
      case PaymentMethodIdEnum.prepaidCard:
        return 'Cartão pré-pago';
      case PaymentMethodIdEnum.ticket:
        return 'Boleto';
      case PaymentMethodIdEnum.visa:
        return 'Visa';
      case PaymentMethodIdEnum.master:
        return 'Master';
      case PaymentMethodIdEnum.mastercard:
        return 'Mastercard';
      case PaymentMethodIdEnum.amex:
        return 'American Express';
      case PaymentMethodIdEnum.hipercard:
        return 'Hipercard';
      case PaymentMethodIdEnum.elo:
        return 'Elo';
      case PaymentMethodIdEnum.naranja:
        return 'Naranja';
      case PaymentMethodIdEnum.debVisa:
        return 'Débito Visa';
      case PaymentMethodIdEnum.debMaster:
        return 'Débito Master';
      case PaymentMethodIdEnum.other:
        return 'Outro';
    }
  }
}

PaymentMethodIdEnum? tryParsePaymentMethodId(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return PaymentMethodIdEnumMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
