import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar índice de contratos
/// 
/// RESPONSABILIDADES:
/// - Calcular qual tab um contrato pertence baseado no status
/// - Atualizar contadores totais e não vistos no índice
/// - Atualizar índices tanto do artista quanto do cliente
/// 
/// LÓGICA DE TABS:
/// Para ARTISTA:
/// - Tab 0 (Em aberto): PENDING
/// - Tab 1 (Confirmadas): PAID
/// - Tab 2 (Finalizadas): COMPLETED, REJECTED, CANCELED, RATED
/// 
/// Para CLIENTE:
/// - Tab 0 (Em aberto): PENDING, PAYMENT_PENDING
/// - Tab 1 (Confirmadas): PAID
/// - Tab 2 (Finalizadas): COMPLETED, REJECTED, CANCELED, RATED
class UpdateContractsIndexUseCase {
  final IContractRepository repository;

  UpdateContractsIndexUseCase({
    required this.repository,
  });

  /// Atualiza o índice de contratos para um contrato específico
  /// 
  /// [contract] - Contrato que foi criado/atualizado (ou removido, se [removed] true)
  /// [oldStatus] - Status anterior (opcional, para decrementar contador antigo)
  /// [removed] - Se true, apenas decrementa os contadores da tab do contrato (ex.: após delete)
  Future<Either<Failure, void>> call({
    required ContractEntity contract,
    ContractStatusEnum? oldStatus,
    bool removed = false,
  }) async {
    try {
      // Atualizar índice do artista (contrato individual)
      if (contract.refArtist != null) {
        await _updateIndexForUser(
          userId: contract.refArtist!,
          contract: contract,
          oldStatus: removed ? contract.status : oldStatus,
          isArtist: true,
          removed: removed,
        );
      }

      // Atualizar índice do dono do conjunto (contrato de grupo) — usar refArtistOwner, não refGroup
      if (contract.refGroup != null && contract.refArtistOwner != null) {
        await _updateIndexForUser(
          userId: contract.refArtistOwner!,
          contract: contract,
          oldStatus: removed ? contract.status : oldStatus,
          isArtist: true,
          removed: removed,
        );
      }

      // Atualizar índice do cliente (se houver)
      if (contract.refClient != null) {
        await _updateIndexForUser(
          userId: contract.refClient!,
          contract: contract,
          oldStatus: removed ? contract.status : oldStatus,
          isArtist: false,
          removed: removed,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Atualiza o índice para um usuário específico
  /// [removed] - Se true, só decrementa a tab do contrato (ex.: após delete), sem incrementar
  Future<void> _updateIndexForUser({
    required String userId,
    required ContractEntity contract,
    ContractStatusEnum? oldStatus,
    required bool isArtist,
    bool removed = false,
  }) async {
    final newTabIndex = _getTabIndexForStatus(contract.status, isArtist);
    int? oldTabIndex;
    if (oldStatus != null) {
      oldTabIndex = _getTabIndexForStatus(oldStatus, isArtist);
    }

    if (!removed && oldTabIndex != null && oldTabIndex == newTabIndex) {
      return;
    }

    final currentIndex = await repository.getContractsIndexStream(userId).first;
    final rolePrefix = isArtist ? 'artist' : 'client';
    final updates = <String, dynamic>{};

    if (oldTabIndex != null) {
      final oldTabTotal = '${rolePrefix}Tab${oldTabIndex}Total';
      final oldTabUnseen = '${rolePrefix}Tab${oldTabIndex}Unseen';
      final currentTotal = currentIndex.getTotalForTab(oldTabIndex, isArtist);
      final currentUnseen = currentIndex.getUnseenForTab(oldTabIndex, isArtist);
      updates[oldTabTotal] = (currentTotal > 0) ? currentTotal - 1 : 0;
      updates[oldTabUnseen] = (currentUnseen > 0) ? currentUnseen - 1 : 0;
    }

    if (!removed) {
      final newTabTotal = '${rolePrefix}Tab${newTabIndex}Total';
      final newTabUnseen = '${rolePrefix}Tab${newTabIndex}Unseen';
      final currentNewTotal = currentIndex.getTotalForTab(newTabIndex, isArtist);
      final currentNewUnseen = currentIndex.getUnseenForTab(newTabIndex, isArtist);
      updates[newTabTotal] = currentNewTotal + 1;
      final lastSeen = currentIndex.getLastSeenForTab(newTabIndex, isArtist);
      final contractChangedAt = contract.statusChangedAt ?? contract.createdAt ?? DateTime.now();
      final isUnseen = lastSeen == null || contractChangedAt.isAfter(lastSeen);
      updates[newTabUnseen] = isUnseen ? currentNewUnseen + 1 : currentNewUnseen;
    }

    if (updates.isEmpty) return;
    await repository.updateContractsIndex(userId, updates);
  }

  /// Determina qual tab um status pertence
  /// 
  /// Retorna: 0 (Em aberto), 1 (Confirmadas), ou 2 (Finalizadas)
  int _getTabIndexForStatus(ContractStatusEnum status, bool isArtist) {
    if (isArtist) {
      // Para artista
      switch (status) {
        case ContractStatusEnum.pending:
          return 0; // Em aberto
        case ContractStatusEnum.paid:
          return 1; // Confirmadas
        case ContractStatusEnum.completed:
        case ContractStatusEnum.rejected:
        case ContractStatusEnum.canceled:
        case ContractStatusEnum.rated:
          return 2; // Finalizadas
        default:
          // PAYMENT_PENDING, etc. não aparecem para artista
          return 0;
      }
    } else {
      // Para cliente
      switch (status) {
        case ContractStatusEnum.pending:
        case ContractStatusEnum.paymentPending:
        case ContractStatusEnum.paymentExpired:
        case ContractStatusEnum.paymentRefused:
        case ContractStatusEnum.paymentFailed:
          return 0; // Em aberto
        case ContractStatusEnum.paid:
          return 1; // Confirmadas
        case ContractStatusEnum.completed:
        case ContractStatusEnum.rejected:
        case ContractStatusEnum.canceled:
        case ContractStatusEnum.rated:
          return 2; // Finalizadas
      }
    }
  }
}
