import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/cancel_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:timezone/timezone.dart' as tz;

/// UseCase: Aceitar uma solicitação de contrato
/// 
/// RESPONSABILIDADES:
/// - Validar UID do contrato
/// - Buscar contrato existente
/// - Validar que o contrato está pendente
/// - Alterar status para accepted
/// - Adicionar timestamp de aceitação
/// - Atualizar contrato no repositório
class AcceptContractUseCase {
  final IContractRepository repository;
  final IFirebaseFunctionsService firebaseFunctionsService;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;
  final CancelContractUseCase cancelContractUseCase;

  AcceptContractUseCase({
    required this.repository,
    required this.firebaseFunctionsService,
    this.updateContractsIndexUseCase,
    required this.cancelContractUseCase,
  });

  static tz.Location get _saoPaulo => tz.getLocation('America/Sao_Paulo');

  /// True se a data do evento é hoje ou amanhã no fuso America/Sao_Paulo.
  bool _isEventSameOrNextDayInSp(DateTime eventDate, tz.TZDateTime nowSp) {
    final tomorrowSp = nowSp.add(const Duration(days: 1));
    final sameDay = eventDate.year == nowSp.year && eventDate.month == nowSp.month && eventDate.day == nowSp.day;
    final nextDay = eventDate.year == tomorrowSp.year && eventDate.month == tomorrowSp.month && eventDate.day == tomorrowSp.day;
    return sameDay || nextDay;
  }

  /// Calcula o prazo para o anfitrião pagar (America/Sao_Paulo), retorna em UTC.
  /// Regra: evento no mesmo dia ou no dia seguinte → 1h; caso contrário → 24h.
  DateTime _calculatePaymentDeadlineUtc(DateTime eventDate) {
    final nowSp = tz.TZDateTime.now(_saoPaulo);
    final duration = _isEventSameOrNextDayInSp(eventDate, nowSp)
        ? const Duration(hours: 1)
        : const Duration(hours: 24);
    final deadlineSp = nowSp.add(duration);
    return DateTime.fromMillisecondsSinceEpoch(deadlineSp.millisecondsSinceEpoch, isUtc: true);
  }

  Future<Either<Failure, void>> call({
    required String contractUid,
    List<String>? acceptedTimes,
  }) async {
    try {
      // Validar UID do contrato
      if (contractUid.isEmpty) {
        return const Left(ValidationFailure('UID do contrato não pode ser vazio'));
      }

      // Buscar contrato
      final getResult = await repository.getContract(contractUid);
      
      final contract = getResult.fold(
        (failure) => null,
        (contract) => contract,
      );

      if (contract == null) {
        return const Left(NotFoundFailure('Contrato não encontrado'));
      }

      // Validar que o contrato está pendente
      if (!contract.isPending) {
        return Left(ValidationFailure(
          'Apenas contratos pendentes podem ser aceitos. Status atual: ${contract.status.value}'
        ));
      }

      // Verificar se não existe slot BOOKED no horário (evitar criar links e chamadas desnecessárias)
      // final overlapResult = await repository.checkContractOverlapWithBooked(contractUid);
      // final hasOverlap = overlapResult.fold(
      //   (failure) => throw failure,
      //   (overlap) => overlap,
      // );
      // if (hasOverlap) {
      //   await cancelContractUseCase.call(contractUid: contractUid, canceledBy: 'ARTIST', cancelReason: 'Horário já está reservado por outro show.');
      //   return Left(ValidationFailure(
      //     'Este horário já está reservado por outro show.',
      //   ));
      // }

      // Criar pagamento no Mercado Pago
      final paymentLink = await firebaseFunctionsService.createMercadoPagoPayment(
        contract.uid!,
        false,
      );

      // Prazo para o anfitrião pagar (mesmo dia/dia seguinte = 1h; depois = 24h), em UTC
      final paymentDueDateUtc = _calculatePaymentDeadlineUtc(contract.date);
      final acceptedAtUtc = DateTime.now().toUtc();

      // Criar cópia do contrato com status aceito
      final updatedContract = contract.copyWith(
        status: ContractStatusEnum.paymentPending,
        acceptedAt: acceptedAtUtc,
        linkPayment: paymentLink,
        paymentDueDate: paymentDueDateUtc,
        statusChangedAt: acceptedAtUtc,
      );

      // Atualizar contrato
      final updateResult = await repository.updateContract(updatedContract);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) async {
          // Atualizar índice de contratos (não bloqueia se falhar)
          if (updateContractsIndexUseCase != null) {
            await updateContractsIndexUseCase!.call(
              contract: updatedContract,
              oldStatus: contract.status,
            );
          }
          return const Right(null);
        },
      );
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ErrorHandler.handle(e));
    }
  }
}

