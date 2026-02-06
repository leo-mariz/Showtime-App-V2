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
  /// [contract] - Contrato que foi criado/atualizado
  /// [oldStatus] - Status anterior (opcional, para decrementar contador antigo)
  Future<Either<Failure, void>> call({
    required ContractEntity contract,
    ContractStatusEnum? oldStatus,
  }) async {
    try {
      // Atualizar índice do artista (contrato individual)
      if (contract.refArtist != null) {
        await _updateIndexForUser(
          userId: contract.refArtist!,
          contract: contract,
          oldStatus: oldStatus,
          isArtist: true,
        );
      }

      // Atualizar índice do dono do conjunto (contrato de grupo) — usar refArtistOwner, não refGroup
      if (contract.refGroup != null && contract.refArtistOwner != null) {
        await _updateIndexForUser(
          userId: contract.refArtistOwner!,
          contract: contract,
          oldStatus: oldStatus,
          isArtist: true,
        );
      }

      // Atualizar índice do cliente (se houver)
      if (contract.refClient != null) {
        await _updateIndexForUser(
          userId: contract.refClient!,
          contract: contract,
          oldStatus: oldStatus,
          isArtist: false,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Atualiza o índice para um usuário específico
  Future<void> _updateIndexForUser({
    required String userId,
    required ContractEntity contract,
    ContractStatusEnum? oldStatus,
    required bool isArtist,
  }) async {
    // Determinar qual tab o contrato pertence (novo status)
    final newTabIndex = _getTabIndexForStatus(contract.status, isArtist);
    
    // Determinar qual tab o contrato pertencia (status antigo)
    int? oldTabIndex;
    if (oldStatus != null) {
      oldTabIndex = _getTabIndexForStatus(oldStatus, isArtist);
    }

    // Se o status não mudou de tab, não precisa atualizar
    if (oldTabIndex != null && oldTabIndex == newTabIndex) {
      return;
    }

    // Buscar índice atual do usuário
    final currentIndex = await repository.getContractsIndexStream(userId).first;
    
    // Preparar atualizações com prefixo do role
    final rolePrefix = isArtist ? 'artist' : 'client';
    final updates = <String, dynamic>{};

    // Decrementar contadores antigos (se houver)
    if (oldTabIndex != null) {
      final oldTabTotal = '${rolePrefix}Tab${oldTabIndex}Total';
      final oldTabUnseen = '${rolePrefix}Tab${oldTabIndex}Unseen';
      
      final currentTotal = currentIndex.getTotalForTab(oldTabIndex, isArtist);
      final currentUnseen = currentIndex.getUnseenForTab(oldTabIndex, isArtist);
      
      updates[oldTabTotal] = (currentTotal > 0) ? currentTotal - 1 : 0;
      updates[oldTabUnseen] = (currentUnseen > 0) ? currentUnseen - 1 : 0;
    }

    // Incrementar contadores novos
    final newTabTotal = '${rolePrefix}Tab${newTabIndex}Total';
    final newTabUnseen = '${rolePrefix}Tab${newTabIndex}Unseen';
    
    final currentNewTotal = currentIndex.getTotalForTab(newTabIndex, isArtist);
    final currentNewUnseen = currentIndex.getUnseenForTab(newTabIndex, isArtist);
    
    updates[newTabTotal] = currentNewTotal + 1;
    
    // Verificar se o contrato é "não visto" (criado/atualizado após lastSeenTabX)
    final lastSeen = currentIndex.getLastSeenForTab(newTabIndex, isArtist);
    final contractChangedAt = contract.statusChangedAt ?? contract.createdAt ?? DateTime.now();
    
    bool isUnseen = true;
    if (lastSeen != null && contractChangedAt.isBefore(lastSeen)) {
      isUnseen = false;
    }
    
    updates[newTabUnseen] = isUnseen ? currentNewUnseen + 1 : currentNewUnseen;

    // Atualizar índice no Firestore
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
