// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_method_id_enum.dart';

class PaymentMethodIdEnumMapper extends EnumMapper<PaymentMethodIdEnum> {
  PaymentMethodIdEnumMapper._();

  static PaymentMethodIdEnumMapper? _instance;
  static PaymentMethodIdEnumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentMethodIdEnumMapper._());
    }
    return _instance!;
  }

  static PaymentMethodIdEnum fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PaymentMethodIdEnum decode(dynamic value) {
    switch (value) {
      case 'pix':
        return PaymentMethodIdEnum.pix;
      case 'account_money':
        return PaymentMethodIdEnum.accountMoney;
      case 'credit_card':
        return PaymentMethodIdEnum.creditCard;
      case 'debit_card':
        return PaymentMethodIdEnum.debitCard;
      case 'prepaid_card':
        return PaymentMethodIdEnum.prepaidCard;
      case 'ticket':
        return PaymentMethodIdEnum.ticket;
      case 'visa':
        return PaymentMethodIdEnum.visa;
      case 'master':
        return PaymentMethodIdEnum.master;
      case 'mastercard':
        return PaymentMethodIdEnum.mastercard;
      case 'amex':
        return PaymentMethodIdEnum.amex;
      case 'hipercard':
        return PaymentMethodIdEnum.hipercard;
      case 'elo':
        return PaymentMethodIdEnum.elo;
      case 'naranja':
        return PaymentMethodIdEnum.naranja;
      case 'debvisa':
        return PaymentMethodIdEnum.debVisa;
      case 'debmaster':
        return PaymentMethodIdEnum.debMaster;
      case 'other':
        return PaymentMethodIdEnum.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PaymentMethodIdEnum self) {
    switch (self) {
      case PaymentMethodIdEnum.pix:
        return 'pix';
      case PaymentMethodIdEnum.accountMoney:
        return 'account_money';
      case PaymentMethodIdEnum.creditCard:
        return 'credit_card';
      case PaymentMethodIdEnum.debitCard:
        return 'debit_card';
      case PaymentMethodIdEnum.prepaidCard:
        return 'prepaid_card';
      case PaymentMethodIdEnum.ticket:
        return 'ticket';
      case PaymentMethodIdEnum.visa:
        return 'visa';
      case PaymentMethodIdEnum.master:
        return 'master';
      case PaymentMethodIdEnum.mastercard:
        return 'mastercard';
      case PaymentMethodIdEnum.amex:
        return 'amex';
      case PaymentMethodIdEnum.hipercard:
        return 'hipercard';
      case PaymentMethodIdEnum.elo:
        return 'elo';
      case PaymentMethodIdEnum.naranja:
        return 'naranja';
      case PaymentMethodIdEnum.debVisa:
        return 'debvisa';
      case PaymentMethodIdEnum.debMaster:
        return 'debmaster';
      case PaymentMethodIdEnum.other:
        return 'other';
    }
  }
}

extension PaymentMethodIdEnumMapperExtension on PaymentMethodIdEnum {
  dynamic toValue() {
    PaymentMethodIdEnumMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PaymentMethodIdEnum>(this);
  }
}

