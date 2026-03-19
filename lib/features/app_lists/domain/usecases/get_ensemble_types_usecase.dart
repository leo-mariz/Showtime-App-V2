import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';
import 'package:app/features/app_lists/domain/repositories/app_lists_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar lista de tipos de conjunto
///
/// RESPONSABILIDADES:
/// - Buscar tipos de conjunto do repositório (cache primeiro, depois remoto)
/// - Retornar apenas itens ativos, ordenados
class GetEnsembleTypesUseCase {
  final IAppListsRepository repository;

  GetEnsembleTypesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<AppListItemEntity>>> call() async {
    try {
      final result = await repository.getListItems(AppListType.ensembleTypes);

      return result.fold(
        (failure) => Left(failure),
        (items) {
          final activeItems = items.where((item) => item.isActive).toList();
          activeItems.sort((a, b) {
            if (a.order != null && b.order != null) {
              return a.order!.compareTo(b.order!);
            }
            if (a.order != null) return -1;
            if (b.order != null) return 1;
            return a.name.compareTo(b.name);
          });
          return Right(activeItems);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
