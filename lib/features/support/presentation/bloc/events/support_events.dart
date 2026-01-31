import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendSupportMessageEvent extends SupportEvent {
  final String name;
  final String? userEmail;
  final String subject;
  final String message;
  /// ID do contrato quando a solicitação está vinculada a um contrato.
  final String? contractId;

  SendSupportMessageEvent({
    required this.name,
    this.userEmail,
    required this.subject,
    required this.message,
    this.contractId,
  });

  @override
  List<Object?> get props => [name, userEmail, subject, message, contractId];
}
