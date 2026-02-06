import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar contratos do artista incluindo contratos dos conjuntos dos quais ele é dono.
///
/// Junta em uma única lista (ordenada por data, mais recentes primeiro):
/// - Contratos em que [artistUid] é o artista (refArtist).
/// - Contratos de cada conjunto em [ensembleIds] (refGroup).
/// Remove duplicatas por [contract.uid].
class GetContractsForArtistIncludingEnsemblesUseCase {
  final IContractRepository repository;

  GetContractsForArtistIncludingEnsemblesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ContractEntity>>> call(
    String artistUid, {
    required List<String> ensembleIds,
    bool forceRefresh = false,
  }) async {
    try {
      if (artistUid.isEmpty) {
        return const Left(
          ValidationFailure('UID do artista não pode ser vazio'),
        );
      }

      final artistResult = await repository.getContractsByArtist(
        artistUid,
        forceRefresh: forceRefresh,
      );

      final artistContracts = artistResult.fold(
        (failure) => <ContractEntity>[],
        (list) => list,
      );

      final allContracts = <String, ContractEntity>{};
      for (final c in artistContracts) {
        if (c.uid != null && c.uid!.isNotEmpty) {
          allContracts[c.uid!] = c;
        }
      }

      for (final ensembleId in ensembleIds) {
        if (ensembleId.isEmpty) continue;
        final groupResult = await repository.getContractsByGroup(
          ensembleId,
          forceRefresh: forceRefresh,
        );
        groupResult.fold(
          (_) {},
          (list) {
            for (final c in list) {
              if (c.uid != null && c.uid!.isNotEmpty) {
                allContracts[c.uid!] = c;
              }
            }
          },
        );
      }

      final merged = allContracts.values.toList();
      merged.sort((a, b) {
        final dateA = a.createdAt ?? a.date;
        final dateB = b.createdAt ?? b.date;
        return dateB.compareTo(dateA);
      });

      return Right(merged);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
