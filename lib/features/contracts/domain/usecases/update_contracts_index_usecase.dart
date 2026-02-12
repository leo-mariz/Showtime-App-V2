import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar índice de contratos
///
/// REGRA: Sempre atualizar AMBOS os lados (artista e cliente) em toda mudança.
/// - No documento do artista (user_contracts_index/{refArtist}): apenas artistTab*.
/// - No documento do cliente (user_contracts_index/{refClient}): apenas clientTab*.
/// Nunca misturar artistTab e clientTab no mesmo usuário.
///
/// QUEM ATUALIZA O QUÊ:
/// - Cliente solicita → tab 0 (artista e cliente).
/// - Artista aceita → contrato segue na tab 0; atualizar lastUpdate em ambos para refletir mudança.
/// - Cliente paga → tab 1 (artista e cliente).
/// - Artista confirma show → tab 2 (artista e cliente).
/// - Contrato cancelado (artista ou cliente) → tab 2 (artista e cliente).
/// - Artista rejeita → tab 2 (artista e cliente).
///
/// LÓGICA DE TABS:
/// Para ARTISTA:
/// - Tab 0 (Em aberto): PENDING, PAYMENT_PENDING, etc.
/// - Tab 1 (Confirmadas): PAID
/// - Tab 2 (Finalizadas): COMPLETED, REJECTED, CANCELED, RATED
///
/// Para CLIENTE:
/// - Tab 0 (Em aberto): PENDING, PAYMENT_PENDING, PAYMENT_EXPIRED, PAYMENT_REFUSED, PAYMENT_FAILED
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

    final currentIndex = await repository.getContractsIndexStream(userId).first;
    final rolePrefix = isArtist ? 'artist' : 'client';
    final updates = <String, dynamic>{};

    // Contrato permanece na mesma tab (ex.: artista aceita = PENDING -> PAYMENT_PENDING, ambos tab 0)
    // Atualizar lastUpdate e incrementar unseen da tab para o outro lado ver o indicador (artista e cliente)
    if (!removed && oldTabIndex != null && oldTabIndex == newTabIndex) {
      updates['lastUpdate'] = DateTime.now();
      final tabUnseenKey = '${rolePrefix}Tab${newTabIndex}Unseen';
      final currentUnseen = currentIndex.getUnseenForTab(newTabIndex, isArtist);
      final currentTotal = currentIndex.getTotalForTab(newTabIndex, isArtist);
      final lastSeen = currentIndex.getLastSeenForTab(newTabIndex, isArtist);
      final contractChangedAt = contract.statusChangedAt ?? contract.createdAt ?? DateTime.now();
      final isUnseen = lastSeen == null || contractChangedAt.isAfter(lastSeen);
      final newUnseen = isUnseen ? (currentUnseen + 1).clamp(0, currentTotal) : currentUnseen;
      updates[tabUnseenKey] = newUnseen;
      await repository.updateContractsIndex(userId, updates);
      return;
    }

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
