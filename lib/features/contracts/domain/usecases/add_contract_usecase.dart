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

  Future<Either<Failure, String>> call(ContractEntity contract) async {
    try {
      // Validar referência do cliente
      if (contract.refClient == null || contract.refClient!.isEmpty) {
        return const Left(ValidationFailure('Referência do cliente não pode ser vazia'));
      }

      // Validar referência do contratado (artista ou grupo)
      if (contract.contractorType == ContractorTypeEnum.artist) {
        if (contract.refArtist == null || contract.refArtist!.isEmpty) {
          return const Left(ValidationFailure('Referência do artista não pode ser vazia'));
        }
      } else if (contract.contractorType == ContractorTypeEnum.group) {
        if (contract.refGroup == null || contract.refGroup!.isEmpty) {
          return const Left(ValidationFailure('Referência do grupo não pode ser vazia'));
        }
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

      // Adicionar contrato
      final result = await repository.addContract(contract);

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

