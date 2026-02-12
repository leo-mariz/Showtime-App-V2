import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
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
  final IContractsFunctionsService contractsFunctions;
  final UpdateContractsIndexUseCase? updateContractsIndexUseCase;

  AddContractUseCase({
    required this.repository,
    required this.contractsFunctions,
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
  // bool _isEventSameOrNextDayInSp(DateTime eventDate, tz.TZDateTime nowSp) {
  //   final tomorrowSp = nowSp.add(const Duration(days: 1));
  //   final sameDay = eventDate.year == nowSp.year && eventDate.month == nowSp.month && eventDate.day == nowSp.day;
  //   final nextDay = eventDate.year == tomorrowSp.year && eventDate.month == tomorrowSp.month && eventDate.day == tomorrowSp.day;
  //   return sameDay || nextDay;
  // }

  /// Monta o payload para a Cloud Function addContract.
  Map<String, dynamic> _buildAddContractPayload(ContractEntity contract) {
    final payload = <String, dynamic>{
      'refClient': contract.refClient,
      'contractorType': contract.contractorType.value,
      'date': contract.date.toUtc().toIso8601String(),
      'time': contract.time,
      'duration': contract.duration,
      'preparationTime': contract.preparationTime,
      'value': contract.value,
      'address': contract.address.toMap(),
    };
    if (contract.contractorType == ContractorTypeEnum.artist && contract.refArtist != null) {
      payload['refArtist'] = contract.refArtist;
    }
    if (contract.contractorType == ContractorTypeEnum.group) {
      if (contract.refGroup != null) payload['refGroup'] = contract.refGroup;
      if (contract.refArtistOwner != null) payload['refArtistOwner'] = contract.refArtistOwner;
    }
    if (contract.eventType != null) payload['eventType'] = contract.eventType!.toMap();
    if (contract.nameArtist != null) payload['nameArtist'] = contract.nameArtist;
    if (contract.nameGroup != null) payload['nameGroup'] = contract.nameGroup;
    if (contract.nameClient != null) payload['nameClient'] = contract.nameClient;
    if (contract.clientRating != null) payload['clientRating'] = contract.clientRating;
    if (contract.clientRatingCount != null) payload['clientRatingCount'] = contract.clientRatingCount;
    if (contract.clientPhotoUrl != null) payload['clientPhotoUrl'] = contract.clientPhotoUrl;
    if (contract.contractorPhotoUrl != null) payload['contractorPhotoUrl'] = contract.contractorPhotoUrl;
    return payload;
  }

  // /// Calcula o acceptDeadline em fuso America/Sao_Paulo e retorna em UTC.
  // /// Regra: evento no mesmo dia ou no dia seguinte → prazo 1h; caso contrário → 24h.
  // DateTime _calculateAcceptDeadlineUtc(DateTime createdAtUtc, DateTime eventDateTimeUtc, DateTime eventDate) {
  //   final nowSp = tz.TZDateTime.now(_saoPaulo);
  //   final shortDeadline = _isEventSameOrNextDayInSp(eventDate, nowSp);
  //   final duration = shortDeadline
  //       ? const Duration(hours: 1)
  //       : const Duration(hours: 24);
  //   final deadlineSp = nowSp.add(duration);
  //   return DateTime.fromMillisecondsSinceEpoch(deadlineSp.millisecondsSinceEpoch, isUtc: true);
  // }

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

      // Montar payload para a Cloud Function (addContract)
      final payload = _buildAddContractPayload(contract);

      // Criar contrato via Cloud Function
      final contractUid = await contractsFunctions.addContract(payload);
      

      // Atualizar índice no client (sempre, mesmo se getContract falhar).
      // Garantir status PENDING para que o índice incremente tab 0 (Em aberto) do artista, não tab 1.
      if (updateContractsIndexUseCase != null) {
        final getResult = await repository.getContract(contractUid);
        final toIndex = getResult.fold(
          (_) => contract.copyWith(uid: contractUid, statusChangedAt: DateTime.now()),
          (createdContract) => createdContract.copyWith(statusChangedAt: DateTime.now()),
        ).copyWith(status: ContractStatusEnum.pending);
        await updateContractsIndexUseCase!.call(contract: toIndex);
      }
      return Right(contractUid);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

