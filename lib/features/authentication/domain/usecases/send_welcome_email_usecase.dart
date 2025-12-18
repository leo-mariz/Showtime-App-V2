import 'package:app/core/config/setup_locator.dart';
import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/templates/email_templates.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/mail_services.dart';
import 'package:dartz/dartz.dart';

class SendWelcomeEmailUsecase {

  SendWelcomeEmailUsecase();

  Future<Either<Failure, void>> call(UserEntity user) async {
    final userEmail = user.email;
    final isArtist = user.isArtist ?? false;
    final isCnpj = user.isCnpj ?? false;
    try {
      final toUser = [userEmail];
      final mailService = getIt<MailService>();
      final userWelcomeEmailSubject = 'Bem-vindo ao Showtime';
      final userWelcomeTo = toUser;
      String userName = isCnpj ? user.cnpjUser!.companyName! : user.cpfUser!.firstName!;
      final userWelcomeMessage = isArtist ? EmailTemplates.buildArtistWelcomeEmail(userName) : EmailTemplates.buildClientWelcomeEmail(userName);
      final userWelcomeEmailEntity = EmailEntity(
        to: userWelcomeTo,
        subject: userWelcomeEmailSubject,
        body: userWelcomeMessage,
        isHtml: true,
      );
      await mailService.sendEmail(userWelcomeEmailEntity);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

