/// Estado local do fluxo de pagamento (cliente).
/// [paying] = UIDs em que o cliente já foi redirecionado e deve ver "Verificar Pagamento".
/// [opening] = UIDs em que o app está abrindo o Mercado Pago (mostrar loading).
class ContractPayingState {
  final Set<String> paying;
  final Set<String> opening;

  const ContractPayingState({
    this.paying = const {},
    this.opening = const {},
  });

  ContractPayingState copyWith({
    Set<String>? paying,
    Set<String>? opening,
  }) =>
      ContractPayingState(
        paying: paying ?? this.paying,
        opening: opening ?? this.opening,
      );
}
