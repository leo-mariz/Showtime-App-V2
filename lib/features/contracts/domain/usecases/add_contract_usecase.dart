import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contractor_type_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:dartz/dartz.dart';

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

  /// Combina data (DateTime) e horário (String "HH:mm") em um DateTime completo
  DateTime _combineDateAndTime(DateTime date, String time) {
    final timeParts = time.split(':');
    if (timeParts.length != 2) {
      // Se formato inválido, retorna a data original
      return date;
    }
    
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  /// Calcula o deadline para aceitar a solicitação baseado na regra:
  /// - Se evento é nas próximas 36h: prazo de 1h30min
  /// - Caso contrário: prazo de 24h
  DateTime _calculateAcceptDeadline(DateTime createdAt, DateTime eventDateTime) {
    // Calcular diferença entre criação e evento
    final timeUntilEvent = eventDateTime.difference(createdAt);
    
    // Se evento é nas próximas 36 horas (ou menos)
    if (timeUntilEvent.inHours <= 36) {
      // Prazo de 1h30min
      return createdAt.add(const Duration(hours: 1, minutes: 30));
    } else {
      // Prazo de 24h
      return createdAt.add(const Duration(hours: 24));
    }
  }

  Future<Either<Failure, String>> call(ContractEntity contract) async {
    try {
      // Validar referência do cliente
      if (contract.refClient == null || contract.refClient!.isEmpty) {
        return const Left(ValidationFailure('Referência do cliente não pode ser vazia'));
      }

      // Validar referência do contratado (artista ou grupo)
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

      // Validar data e horário do evento (deve ser no futuro)
      // Combinar data + horário para validação correta
      final eventDateTime = _combineDateAndTime(contract.date, contract.time);
      if (eventDateTime.isBefore(DateTime.now())) {
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
      if (artistId != null) {
        final dateString = '${contract.date.year}-${contract.date.month.toString().padLeft(2, '0')}-${contract.date.day.toString().padLeft(2, '0')}';
        
        // Converter availabilitySnapshot para Map se existir
        Map<String, dynamic>? availabilitySnapshotMap;
        if (contract.availabilitySnapshot != null) {
          availabilitySnapshotMap = contract.availabilitySnapshot!.toMap();
        }

        final verifyResult = await repository.verifyContractAvailability(
          contractId: contract.uid ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
          artistId: artistId,
          date: dateString,
          time: contract.time,
          duration: contract.duration,
          address: contract.address.toMap(),
          value: contract.value,
          availabilitySnapshot: availabilitySnapshotMap,
        );

        final verification = verifyResult.fold(
          (failure) => null,
          (result) => result,
        );

        if (verification == null) {
          return const Left(ServerFailure('Erro ao verificar disponibilidade do artista'));
        }

        if (verification['isValid'] != true) {
          final reason = verification['reason'] as String? ?? 'Disponibilidade não é mais válida';
          return Left(ValidationFailure(reason));
        }
      }

      // Calcular deadline para aceitar a solicitação
      final createdAt = contract.createdAt ?? DateTime.now();
      final acceptDeadline = _calculateAcceptDeadline(createdAt, eventDateTime);
      
      // Criar contrato com deadline calculado
      final contractWithDeadline = contract.copyWith(
        acceptDeadline: acceptDeadline,
        createdAt: createdAt,
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

