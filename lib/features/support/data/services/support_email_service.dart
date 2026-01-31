import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';

/// Interface do serviço de envio de email para atendimento.
/// Envia a mensagem para o email do Showtime (contato@showtime.app.br).
abstract class ISupportEmailService {
  /// Envia a solicitação por email para a equipe Showtime.
  /// Lança [ServerException] ou [ValidationException] em caso de erro.
  Future<void> sendToShowtime(SupportRequestEntity request);
}
