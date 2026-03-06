import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mail_services.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/features/support/data/templates/support_email_template.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:app/features/support/domain/repositories/support_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

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
/// Se [userEmail] não for informado no input, busca o email do usuário via [GetUserDataUseCase].
class SendSupportMessageUseCase {
  final ISupportRepository repository;
  final MailService mailService;
  final GetUserDataUseCase getUserDataUseCase;

  SendSupportMessageUseCase({
    required this.repository,
    required this.mailService,
    required this.getUserDataUseCase,
  });

  Future<Either<Failure, SupportRequestEntity>> call(
    SendSupportMessageInput input,
  ) async {
    if (kDebugMode) {
      debugPrint('SendSupportMessageUseCase: início (userId=${input.userId}, subject=${input.subject})');
    }
    try {
      if (input.userId.isEmpty) {
        if (kDebugMode) debugPrint('SendSupportMessageUseCase: validação falhou (userId vazio)');
        return const Left(ValidationFailure('userId é obrigatório'));
      }
      if (input.name.trim().isEmpty) {
        if (kDebugMode) debugPrint('SendSupportMessageUseCase: validação falhou (nome vazio)');
        return const Left(ValidationFailure('Nome é obrigatório'));
      }
      if (input.subject.trim().isEmpty) {
        if (kDebugMode) debugPrint('SendSupportMessageUseCase: validação falhou (assunto vazio)');
        return const Left(ValidationFailure('Assunto é obrigatório'));
      }
      if (input.message.trim().isEmpty) {
        if (kDebugMode) debugPrint('SendSupportMessageUseCase: validação falhou (mensagem vazia)');
        return const Left(ValidationFailure('Mensagem é obrigatória'));
      }
      // Resolver email: usar o do input ou buscar do usuário logado
      String? resolvedEmail = input.userEmail?.trim();
      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        final userResult = await getUserDataUseCase.call(input.userId);
        resolvedEmail = userResult.fold(
          (_) => null,
          (user) => user.email.trim().isNotEmpty ? user.email.trim() : null,
        );
        if (kDebugMode) {
          debugPrint('SendSupportMessageUseCase: email do usuário ${resolvedEmail != null ? "obtido (${resolvedEmail})" : "não encontrado"}');
        }
      }
      final request = SupportRequestEntity(
        userId: input.userId,
        name: input.name.trim(),
        userEmail: resolvedEmail,
        subject: input.subject.trim(),
        message: input.message.trim(),
        status: 'pending',
        contractId: input.contractId,
      );
      if (kDebugMode) debugPrint('SendSupportMessageUseCase: enviando solicitação ao repositório');
      final result = await repository.submitRequest(request);
      await result.fold(
        (failure) async {
          if (kDebugMode) debugPrint('SendSupportMessageUseCase: repositório falhou: ${failure.message}');
        },
        (created) async {
          if (kDebugMode) {
            debugPrint('SendSupportMessageUseCase: solicitação registrada (id=${created.id}, protocolo=${created.protocolNumber})');
          }
          final userEmail = created.userEmail?.trim();
          if (userEmail != null && userEmail.isNotEmpty) {
            if (kDebugMode) debugPrint('SendSupportMessageUseCase: enviando email de confirmação para $userEmail');
            try {
              await mailService.sendEmail(EmailEntity(
                to: [userEmail],
                subject: SupportEmailTemplate.subjectUserConfirmation(created),
                body: SupportEmailTemplate.bodyUserConfirmationHtml(
                  subject: created.subject,
                  name: created.name,
                  message: created.message,
                  protocol: created.protocolNumber ?? created.id,
                ),
                isHtml: true,
              ));
              if (kDebugMode) debugPrint('SendSupportMessageUseCase: email de confirmação enviado com sucesso');
            } catch (e, st) {
              if (kDebugMode) {
                debugPrint('SendSupportMessageUseCase: falha ao enviar email de confirmação: $e');
                debugPrint('SendSupportMessageUseCase: stackTrace: $st');
              }
              // Falha no email de confirmação não invalida o envio da solicitação
            }
          } else {
            if (kDebugMode) debugPrint('SendSupportMessageUseCase: usuário sem email, confirmação não enviada');
          }
        },
      );
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('SendSupportMessageUseCase: exceção: $e');
        debugPrint('SendSupportMessageUseCase: stackTrace: $st');
      }
      return Left(ErrorHandler.handle(e));
    }
  }
}
