import 'package:app/features/contracts/domain/entities/user_contracts_index_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PendingContractsCountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== LOAD PENDING CONTRACTS COUNT EVENTS ====================

/// Evento para carregar contador de contratos pendentes
/// 
/// Inicia stream otimizado do índice user_contracts_index/{userId}
/// O stream escuta apenas o documento de índice, não todos os contratos
/// 
/// [isArtist] - Define qual role usar (artista ou cliente) para filtrar os contadores
class LoadPendingContractsCountEvent extends PendingContractsCountEvent {
  final bool isArtist;

  LoadPendingContractsCountEvent({this.isArtist = false});

  @override
  List<Object?> get props => [isArtist];
}

/// Evento interno disparado quando o stream do índice atualiza
/// 
/// Não deve ser chamado diretamente pela UI
class PendingContractsCountUpdatedEvent extends PendingContractsCountEvent {
  final UserContractsIndexEntity indexEntity;
  final bool isArtist;

  PendingContractsCountUpdatedEvent({
    required this.indexEntity,
    this.isArtist = false,
  });

  @override
  List<Object?> get props => [indexEntity, isArtist];
}

// ==================== MARK AS SEEN EVENTS ====================

/// Evento para marcar uma tab como vista
/// 
/// Atualiza o timestamp de última visualização da tab especificada
/// Tab: 0 = Em aberto, 1 = Confirmadas, 2 = Finalizadas
/// 
/// [isArtist] - Define qual role usar (artista ou cliente) para marcar como visto
class MarkTabAsSeenEvent extends PendingContractsCountEvent {
  final int tabIndex;
  final bool isArtist;

  MarkTabAsSeenEvent({required this.tabIndex, this.isArtist = false});

  @override
  List<Object?> get props => [tabIndex, isArtist];
}

// ==================== RESET EVENT ====================

/// Evento para resetar o BLoC ao estado inicial
/// 
/// Cancela subscriptions e emite estado inicial
class ResetPendingContractsCountEvent extends PendingContractsCountEvent {}
