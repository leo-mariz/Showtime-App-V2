import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:timezone/timezone.dart' as tz;

/// UseCase: Adicionar novo contrato
/// 
/// RESPONSABILIDADES:
/// - Validar dados do contrato
/// - Validar referências (cliente, artista/grupo)
/// - Adicionar contrato no repositório
/// - Retornar UID do contrato criado
class AddContractUseCase {
  final IContractRepository repository;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  AddContractUseCase({
    required this.repository,
    this.updateContractsIndexUseCase,
  });

  static tz.Location get _saoPaulo => tz.getLocation('America/Sao_Paulo');

  /// Converte data + horário (interpretados como São Paulo) para DateTime UTC.
  DateTime _eventDateTimeUtc(DateTime date, String time) {
    final timeParts = time.split(':');
    if (timeParts.length != 2) return DateTime.utc(date.year, date.month, date.day);
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final eventSp = tz.TZDateTime(_saoPaulo, date.year, date.month, date.day, hour, minute);
    return DateTime.fromMillisecondsSinceEpoch(eventSp.millisecondsSinceEpoch, isUtc: true);
  }

  /// True se a data do evento é hoje ou amanhã no fuso America/Sao_Paulo.
  bool _isEventSameOrNextDayInSp(DateTime eventDate, tz.TZDateTime nowSp) {
    final tomorrowSp = nowSp.add(const Duration(days: 1));
    final sameDay = eventDate.year == nowSp.year && eventDate.month == nowSp.month && eventDate.day == nowSp.day;
    final nextDay = eventDate.year == tomorrowSp.year && eventDate.month == tomorrowSp.month && eventDate.day == tomorrowSp.day;
    return sameDay || nextDay;
  }

  /// Calcula o acceptDeadline em fuso America/Sao_Paulo e retorna em UTC.
  /// Regra: evento no mesmo dia ou no dia seguinte → prazo 1h; caso contrário → 24h.
  DateTime _calculateAcceptDeadlineUtc(DateTime createdAtUtc, DateTime eventDateTimeUtc, DateTime eventDate) {
    final nowSp = tz.TZDateTime.now(_saoPaulo);
    final shortDeadline = _isEventSameOrNextDayInSp(eventDate, nowSp);
    final duration = shortDeadline
        ? const Duration(hours: 1)
        : const Duration(hours: 24);
    final deadlineSp = nowSp.add(duration);
    return DateTime.fromMillisecondsSinceEpoch(deadlineSp.millisecondsSinceEpoch, isUtc: true);
  }

  Future<Either<Failure, String>> call(ContractEntity contract) async {
    try {
      // Validar referência do cliente
      if (contract.refClient == null || contract.refClient!.isEmpty) {
        return const Left(ValidationFailure('Referência do cliente não pode ser vazia'));
      }

      // Validar referência do contratado (artista ou grupo)
      // ignore: unused_local_variable
      String? artistId;
      if (contract.contractorType == ContractorTypeEnum.artist) {
        if (contract.refArtist == null || contract.refArtist!.isEmpty) {
          return const Left(ValidationFailure('Referência do artista não pode ser vazia'));
        }
        artistId = contract.refArtist;
      } else if (contract.contractorType == ContractorTypeEnum.group) {
        if (contract.refGroup == null || contract.refGroup!.isEmpty) {
          return const Left(ValidationFailure('Referência do grupo não pode ser vazia'));
        }
        // Para grupos, não verificamos disponibilidade (por enquanto)
        artistId = null;
      }

      // Validar data e horário do evento (deve ser no futuro), interpretados em SP
      final eventDateTimeUtc = _eventDateTimeUtc(contract.date, contract.time);
      if (eventDateTimeUtc.isBefore(DateTime.now().toUtc())) {
        return const Left(ValidationFailure('Data e horário do evento não podem ser no passado'));
      }

      // Validar duração
      if (contract.duration <= 0) {
        return const Left(ValidationFailure('Duração deve ser maior que zero'));
      }

      // Validar valor
      if (contract.value < 0) {
        return const Left(ValidationFailure('Valor não pode ser negativo'));
      }

      // Verificar disponibilidade do artista antes de criar o contrato
      // if (artistId != null) {
      //   final dateString = '${contract.date.year}-${contract.date.month.toString().padLeft(2, '0')}-${contract.date.day.toString().padLeft(2, '0')}';
        
      //   // Converter availabilitySnapshot para Map se existir
      //   Map<String, dynamic>? availabilitySnapshotMap;
      //   if (contract.availabilitySnapshot != null) {
      //     availabilitySnapshotMap = contract.availabilitySnapshot!.toMap();
      //   }

      //   final verifyResult = await repository.verifyContractAvailability(
      //     contractId: contract.uid ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      //     artistId: artistId,
      //     date: dateString,
      //     time: contract.time,
      //     duration: contract.duration,
      //     address: contract.address.toMap(),
      //     value: contract.value,
      //     availabilitySnapshot: availabilitySnapshotMap,
      //   );

      //   final verification = verifyResult.fold(
      //     (failure) => null,
      //     (result) => result,
      //   );

      //   if (verification == null) {
      //     return const Left(ServerFailure('Erro ao verificar disponibilidade do artista'));
      //   }

      //   if (verification['isValid'] != true) {
      //     final reason = verification['reason'] as String? ?? 'Disponibilidade não é mais válida';
      //     return Left(ValidationFailure(reason));
      //   }
      // }

      // Calcular deadline em America/Sao_Paulo e armazenar em UTC
      final createdAtUtc = contract.createdAt ?? DateTime.now().toUtc();
      final acceptDeadlineUtc = _calculateAcceptDeadlineUtc(createdAtUtc, eventDateTimeUtc, contract.date);

      // Criar contrato com deadline calculado (sempre UTC)
      final contractWithDeadline = contract.copyWith(
        acceptDeadline: acceptDeadlineUtc,
        createdAt: createdAtUtc,
      );

      // Adicionar contrato
      final result = await repository.addContract(contractWithDeadline);

      return result.fold(
        (failure) => Left(failure),
        (contractUid) async {
          // Buscar contrato criado para atualizar índice
          final getResult = await repository.getContract(contractUid);
          await getResult.fold(
            (_) async {},
            (createdContract) async {
              // Atualizar índice de contratos (não bloqueia se falhar)
              if (updateContractsIndexUseCase != null) {
                await updateContractsIndexUseCase!.call(
                  contract: createdContract.copyWith(
                    statusChangedAt: DateTime.now(),
                  ),
                );
              }
            },
          );
          return Right(contractUid);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

