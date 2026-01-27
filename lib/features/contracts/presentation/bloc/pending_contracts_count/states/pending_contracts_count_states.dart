import 'package:equatable/equatable.dart';

abstract class PendingContractsCountState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PendingContractsCountInitial extends PendingContractsCountState {}

// ==================== LOAD PENDING CONTRACTS COUNT STATES ====================

/// Estado de carregamento do contador
class PendingContractsCountLoading extends PendingContractsCountState {}

/// Estado de sucesso com contadores de contratos por tab
class PendingContractsCountSuccess extends PendingContractsCountState {
  /// Contadores de contratos não vistos por tab
  /// Tab 0: Em aberto
  /// Tab 1: Confirmadas
  /// Tab 2: Finalizadas
  final int tab0Unseen;
  final int tab1Unseen;
  final int tab2Unseen;
  
  /// Contadores totais por tab (para referência)
  final int tab0Total;
  final int tab1Total;
  final int tab2Total;

  PendingContractsCountSuccess({
    required this.tab0Unseen,
    required this.tab1Unseen,
    required this.tab2Unseen,
    required this.tab0Total,
    required this.tab1Total,
    required this.tab2Total,
  });

  /// Retorna o total de contratos não vistos (soma de todas as tabs)
  int get totalUnseen => tab0Unseen + tab1Unseen + tab2Unseen;

  /// Verifica se há contratos não vistos em alguma tab
  bool get hasUnseenContracts => totalUnseen > 0;

  @override
  List<Object?> get props => [tab0Unseen, tab1Unseen, tab2Unseen, tab0Total, tab1Total, tab2Total];
}

/// Estado de erro ao carregar contador
class PendingContractsCountFailure extends PendingContractsCountState {
  final String error;

  PendingContractsCountFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
