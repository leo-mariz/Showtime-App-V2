import 'package:app/core/errors/failure.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:dartz/dartz.dart';

/// Repositório de solicitações de atendimento (suporte).
/// Orquestra persistência no Firestore e envio de email.
abstract class ISupportRepository {
  /// Submete uma solicitação: registra no banco e envia email para o Showtime.
  /// Retorna a entidade criada (com id e protocolNumber).
  Future<Either<Failure, SupportRequestEntity>> submitRequest(
    SupportRequestEntity request,
  );
}
