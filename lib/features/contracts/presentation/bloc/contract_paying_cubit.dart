import 'package:flutter_bloc/flutter_bloc.dart';

import 'contract_paying_state.dart';

export 'contract_paying_state.dart';

/// Cubit que controla estado local do fluxo de pagamento (cliente não escreve em contratos).
class ContractPayingCubit extends Cubit<ContractPayingState> {
  ContractPayingCubit() : super(const ContractPayingState());

  /// Marca que o checkout está sendo aberto (exibir loading). Chamar antes de disparar MakePaymentEvent.
  void addOpening(String contractUid) {
    if (contractUid.isEmpty) return;
    emit(state.copyWith(
      opening: Set<String>.from(state.opening)..add(contractUid),
    ));
  }

  /// Remove do estado "abertura" e marca como "pagando" (exibir Verificar Pagamento). Chamar após o delay.
  void finishOpeningAndSetPaying(String contractUid) {
    if (contractUid.isEmpty) return;
    final newOpening = Set<String>.from(state.opening)..remove(contractUid);
    final newPaying = Set<String>.from(state.paying)..add(contractUid);
    emit(state.copyWith(opening: newOpening, paying: newPaying));
  }

  /// Remove do estado "abertura" (ex.: em caso de falha ao abrir o pagamento).
  void removeOpening(String contractUid) {
    if (contractUid.isEmpty) return;
    emit(state.copyWith(
      opening: Set<String>.from(state.opening)..remove(contractUid),
    ));
  }

  void addPaying(String contractUid) {
    if (contractUid.isEmpty) return;
    emit(state.copyWith(
      paying: Set<String>.from(state.paying)..add(contractUid),
    ));
  }

  void removePaying(String contractUid) {
    if (contractUid.isEmpty) return;
    emit(state.copyWith(
      paying: Set<String>.from(state.paying)..remove(contractUid),
    ));
  }

  bool isPaying(String? contractUid) =>
      contractUid != null &&
      contractUid.isNotEmpty &&
      state.paying.contains(contractUid);

  bool isOpening(String? contractUid) =>
      contractUid != null &&
      contractUid.isNotEmpty &&
      state.opening.contains(contractUid);
}
