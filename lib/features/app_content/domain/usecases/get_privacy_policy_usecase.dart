import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:app/features/app_content/domain/repositories/app_content_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar Política de Privacidade do app.
class GetPrivacyPolicyUseCase {
  final IAppContentRepository repository;

  GetPrivacyPolicyUseCase({required this.repository});

  Future<Either<Failure, AppContentEntity>> call() async {
    try {
      return await repository.getContent(AppContentType.privacyPolicy);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
