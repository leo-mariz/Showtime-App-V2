import 'package:equatable/equatable.dart';

abstract class UnreadCountState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UnreadCountInitial extends UnreadCountState {}

// ==================== LOAD UNREAD COUNT STATES ====================

/// Estado de carregamento do contador
class UnreadCountLoading extends UnreadCountState {}

/// Estado de sucesso com contador de mensagens não lidas
class UnreadCountSuccess extends UnreadCountState {
  final int count;

  UnreadCountSuccess({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Estado de erro ao carregar contador
class UnreadCountFailure extends UnreadCountState {
  final String error;

  UnreadCountFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
