import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mail_services.dart';
import 'package:app/features/support/data/templates/support_email_template.dart';
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
  final MailService mailService;

  SendSupportMessageUseCase({
    required this.repository,
    required this.mailService,
  });

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
      final result = await repository.submitRequest(request);
      await result.fold(
        (_) async {},
        (created) async {
          final userEmail = created.userEmail?.trim();
          if (userEmail != null && userEmail.isNotEmpty) {
            try {
              await mailService.sendEmail(EmailEntity(
                to: [userEmail],
                subject: SupportEmailTemplate.subjectUserConfirmation(created),
                body: SupportEmailTemplate.bodyUserConfirmation(created),
                isHtml: false,
              ));
            } catch (_) {
              // Falha no email de confirmação não invalida o envio da solicitação
            }
          }
        },
      );
      return result;
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
