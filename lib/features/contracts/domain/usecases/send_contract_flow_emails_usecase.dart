import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/domain/email/email_entity.dart';
import 'package:app/core/email_templates/contract_flow_templates.dart';
import 'package:app/core/services/mail_services.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Eventos do fluxo de contratação que disparam envio de e-mail para cliente e artista.
enum ContractFlowEmailEvent {
  requestSent,
  artistAccepted,
  artistRejected,
  paymentMade,
  showConfirmed,
  showCanceled,
}

/// Use case unificado: envia os e-mails de notificação (cliente + artista) para cada etapa do fluxo de contratação.
///
/// Busca os e-mails via [GetUserDataUseCase] a partir dos UIDs do contrato ([refClient], artista/grupo).
/// Monta o corpo com os templates de [contract_flow_templates] e envia via [MailService].
/// Falhas no envio são logadas e não falham o fluxo principal.
class SendContractFlowEmailsUseCase {
  final GetUserDataUseCase getUserDataUseCase;
  final MailService mailService;

  SendContractFlowEmailsUseCase({
    required this.getUserDataUseCase,
    required this.mailService,
  });

  /// Envia os dois e-mails (cliente e artista) para o evento indicado.
  /// [contract] deve ser o contrato já atualizado após a ação do fluxo.
  Future<void> call({
    required ContractEntity contract,
    required ContractFlowEmailEvent event,
  }) async {
    try {
      final clientUid = contract.refClient;
      final artistUid = contract.contractorUid ?? contract.refArtistOwner;
      if (clientUid == null || clientUid.isEmpty) return;
      if (artistUid == null || artistUid.isEmpty) return;

      final clientResult = await getUserDataUseCase.call(clientUid);
      final artistResult = await getUserDataUseCase.call(artistUid);
      final clientUser = clientResult.fold((_) => null, (u) => u);
      final artistUser = artistResult.fold((_) => null, (u) => u);

      final clientEmail = clientUser?.email;
      final artistEmail = artistUser?.email;
      if (clientEmail == null || clientEmail.isEmpty) {
        debugPrint('SendContractFlowEmails: e-mail do cliente não encontrado (uid: $clientUid)');
      }
      if (artistEmail == null || artistEmail.isEmpty) {
        debugPrint('SendContractFlowEmails: e-mail do artista não encontrado (uid: $artistUid)');
      }

      final clientName = contract.nameClient ?? 'Anfitrião';
      final artistName = contract.contractorName ?? 'Artista';
      final eventDate = _formatEventDate(contract.date);
      final eventTime = contract.time;
      final eventName = contract.eventType?.name;
      final prepMinutes = contract.preparationTime ?? 0;
      final valueFormatted = contract.value > 0
          ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(contract.value)
          : null;
      final eventAddress = _formatAddressShort(contract.address);
      final cancelReason = contract.cancelReason;

      switch (event) {
        case ContractFlowEmailEvent.requestSent:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'Seu pedido foi enviado — Showtime',
              body: requestSentToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Novo pedido recebido — Showtime',
              body: requestSentToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          break;
        case ContractFlowEmailEvent.artistAccepted:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'O artista aceitou seu pedido — Showtime',
              body: artistAcceptedToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Pedido aceito — Showtime',
              body: artistAcceptedToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          break;
        case ContractFlowEmailEvent.artistRejected:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'Pedido recusado — Showtime',
              body: artistRejectedToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Pedido recusado — Showtime',
              body: artistRejectedToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          break;
        case ContractFlowEmailEvent.paymentMade:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'Pagamento confirmado — Showtime',
              body: paymentMadeToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
                valueFormatted: valueFormatted,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Pagamento do anfitrião confirmado — Showtime',
              body: paymentMadeToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                preparationTimeMinutes: prepMinutes,
                eventName: eventName,
                eventAddress: eventAddress,
              ),
            );
          }
          break;
        case ContractFlowEmailEvent.showConfirmed:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'Show realizado — avalie o artista — Showtime',
              body: showConfirmedToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Show confirmado — avalie o anfitrião — Showtime',
              body: showConfirmedToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
              ),
            );
          }
          break;
        case ContractFlowEmailEvent.showCanceled:
          if (clientEmail != null && clientEmail.isNotEmpty) {
            await _send(
              to: clientEmail,
              subject: 'Apresentação cancelada — Showtime',
              body: showCanceledToClientTemplate(
                clientName: clientName,
                artistName: artistName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
                cancelReason: cancelReason,
              ),
            );
          }
          if (artistEmail != null && artistEmail.isNotEmpty) {
            await _send(
              to: artistEmail,
              subject: 'Apresentação cancelada — Showtime',
              body: showCanceledToArtistTemplate(
                artistName: artistName,
                clientName: clientName,
                eventDate: eventDate,
                eventTime: eventTime,
                eventName: eventName,
                cancelReason: cancelReason,
              ),
            );
          }
          break;
      }
    } catch (e, st) {
      debugPrint('SendContractFlowEmails: erro ao enviar e-mails (evento: $event)');
      debugPrint('  exceção: $e');
      debugPrint('  tipo: ${e.runtimeType}');
      debugPrint('  stackTrace: $st');
      if (e is ServerException && (e.originalError != null || e.stackTrace != null)) {
        debugPrint('  originalError: ${e.originalError}');
        debugPrint('  originalStackTrace: ${e.stackTrace}');
      }
    }
  }

  Future<void> _send({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      await mailService.sendEmail(EmailEntity(
        to: [to],
        subject: subject,
        body: body,
        isHtml: true,
      ));
    } catch (e, st) {
      debugPrint('SendContractFlowEmails._send: falha ao enviar para $to');
      debugPrint('  exceção: $e');
      debugPrint('  tipo: ${e.runtimeType}');
      debugPrint('  stackTrace: $st');
      if (e is ServerException) {
        debugPrint('  ServerException.originalError: ${e.originalError}');
        debugPrint('  ServerException.stackTrace: ${e.stackTrace}');
      }
    }
  }

  static String _formatEventDate(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' yyyy', 'pt_BR').format(date);
  }

  static String _formatAddressShort(AddressInfoEntity address) {
    final district = address.district?.trim();
    final city = address.city?.trim();
    if ((district != null && district.isNotEmpty) && (city != null && city.isNotEmpty)) {
      return '$district, $city';
    }
    if (city != null && city.isNotEmpty) return city;
    if (district != null && district.isNotEmpty) return district;
    return address.title;
  }
}
