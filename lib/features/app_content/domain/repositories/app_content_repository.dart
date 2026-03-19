import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:dartz/dartz.dart';

/// Interface do repositório para conteúdo editável do app (Termos de Uso, Política de Privacidade).
abstract class IAppContentRepository {
  /// Busca o conteúdo por tipo.
  /// Retorna entidade com content vazio se o documento não existir.
  Future<Either<Failure, AppContentEntity>> getContent(AppContentType type);
}
