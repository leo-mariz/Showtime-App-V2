import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:app/features/support/domain/repositories/support_repository.dart';
import 'package:dartz/dartz.dart';

/// DTO de entrada para enviar mensagem de suporte.
class SendSupportMessageInput {
  final String userId;
  final String name;
  final String? userEmail;
  final String subject;
  final String message;
  /// ID do contrato quando a solicitação está vinculada a um contrato.
  final String? contractId;

  const SendSupportMessageInput({
    required this.userId,
    required this.name,
    this.userEmail,
    required this.subject,
    required this.message,
    this.contractId,
  });
}

/// Use case: envia mensagem de atendimento (registra no banco e envia email).
class SendSupportMessageUseCase {
  final ISupportRepository repository;

  SendSupportMessageUseCase({required this.repository});

  Future<Either<Failure, SupportRequestEntity>> call(
    SendSupportMessageInput input,
  ) async {
    try {
      if (input.userId.isEmpty) {
        return const Left(ValidationFailure('userId é obrigatório'));
      }
      if (input.name.trim().isEmpty) {
        return const Left(ValidationFailure('Nome é obrigatório'));
      }
      if (input.subject.trim().isEmpty) {
        return const Left(ValidationFailure('Assunto é obrigatório'));
      }
      if (input.message.trim().isEmpty) {
        return const Left(ValidationFailure('Mensagem é obrigatória'));
      }
      final request = SupportRequestEntity(
        userId: input.userId,
        name: input.name.trim(),
        userEmail: input.userEmail?.trim(),
        subject: input.subject.trim(),
        message: input.message.trim(),
        status: 'pending',
        contractId: input.contractId,
      );
      return await repository.submitRequest(request);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
