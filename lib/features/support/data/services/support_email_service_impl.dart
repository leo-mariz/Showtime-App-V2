import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/services/mail_services.dart';
import 'package:app/features/support/data/templates/support_email_template.dart';
import 'package:app/features/support/domain/entities/support_request_entity.dart';
import 'package:app/features/support/data/services/support_email_service.dart';

/// Implementação do envio de email de atendimento usando [MailService].
/// Envia para contato@showtime.app.br usando o template de suporte.
class SupportEmailServiceImpl implements ISupportEmailService {
  final MailService mailService;

  SupportEmailServiceImpl({required this.mailService});

  @override
  Future<void> sendToShowtime(SupportRequestEntity request) async {
    final email = EmailEntity(
      to: [SupportEmailTemplate.showtimeEmail],
      subject: SupportEmailTemplate.subject(request),
      body: SupportEmailTemplate.body(request),
      isHtml: false,
    );
    await mailService.sendEmail(email);
  }
}
