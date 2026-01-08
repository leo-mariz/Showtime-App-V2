import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository para AppLists
/// 
/// RESPONSABILIDADES:
/// - Buscar listas estáticas do app (especialidades, talentos, assuntos de suporte, etc)
/// - Gerenciar cache das listas
abstract class IAppListsRepository {
  /// Busca lista de itens por tipo
  /// Retorna lista vazia se não existir
  /// Lança [Failure] em caso de erro
  Future<Either<Failure, List<AppListItemEntity>>> getListItems(
    AppListType listType,
  );
}

