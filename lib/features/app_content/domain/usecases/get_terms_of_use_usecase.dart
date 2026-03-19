import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:app/features/app_content/domain/repositories/app_content_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar Termos de Uso do app.
class GetTermsOfUseUseCase {
  final IAppContentRepository repository;

  GetTermsOfUseUseCase({required this.repository});

  Future<Either<Failure, AppContentEntity>> call() async {
    try {
      return await repository.getContent(AppContentType.termsOfUse);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
