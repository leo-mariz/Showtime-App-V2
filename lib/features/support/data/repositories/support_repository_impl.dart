import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/support/data/datasources/support_remote_datasource.dart';
import 'package:app/features/support/data/services/support_email_service.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:app/features/support/domain/repositories/support_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de suporte.
/// 1. Persiste a solicitação no Firestore.
/// 2. Envia email para o Showtime (contato@showtime.app.br).
class SupportRepositoryImpl implements ISupportRepository {
  final ISupportRemoteDataSource remoteDataSource;
  final ISupportEmailService emailService;

  SupportRepositoryImpl({
    required this.remoteDataSource,
    required this.emailService,
  });

  @override
  Future<Either<Failure, SupportRequestEntity>> submitRequest(
    SupportRequestEntity request,
  ) async {
    try {
      final created = await remoteDataSource.save(request);
      try {
        await emailService.sendToShowtime(created);
      } catch (e) {
        // Solicitação já registrada; falha no email não invalida o protocolo
        return Right(created);
      }
      return Right(created);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
