import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailService {
  static final MailService _instance = MailService._internal();
  factory MailService() => _instance;
  MailService._internal();

  Future<void> sendEmail(EmailEntity email) async {
    try {
      // Validar configurações SMTP
      final portStr = dotenv.env['SMTP_PORT'];
      final user = dotenv.env['SMTP_USER'];
      final password = dotenv.env['SMTP_PASSWORD'];
      final host = dotenv.env['SMTP_HOST'];

      if (portStr == null || user == null || password == null || host == null) {
        throw const ServerException('Configurações SMTP não encontradas');
      }

      final port = int.tryParse(portStr);
      if (port == null) {
        throw const ServerException('Porta SMTP inválida');
      }

      // Validar destinatários
      final recipients = email.to ?? [];
      if (recipients.isEmpty) {
        throw const ValidationException('Nenhum destinatário fornecido');
      }

      // Configurar servidor SMTP
      final smtpServer = SmtpServer(
        host,
        port: port,
        username: user,
        password: password,
        ssl: true,
      );

      // Preparar mensagem
      final message = Message()
        ..from = Address(user, 'Showtime')
        ..recipients.addAll(recipients)
        ..subject = email.subject
        ..text = email.body;

      // Enviar email
      await send(message, smtpServer);
    } on AppException {
      // Re-lança exceções já tipadas
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao enviar email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 

// final getIt = GetIt.instance;
// void setupLocator() {
//   getIt.registerSingleton<MailService>(MailService());
// }



