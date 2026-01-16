import 'package:equatable/equatable.dart';

/// Entidade que representa o próximo show do artista
class NextShowEntity extends Equatable {
  final String contractUid;
  final String title; // Título do evento (eventType.name)
  final String clientName; // Nome do anfitrião
  final DateTime date; // Data do evento
  final String time; // Hora do evento
  final String location; // Bairro - Cidade
  final String? duration; // Duração do evento em minutos

  const NextShowEntity({
    required this.contractUid,
    required this.title,
    required this.clientName,
    required this.date,
    required this.time,
    required this.location,
    this.duration,
  });

  @override
  List<Object?> get props => [contractUid, title, clientName, date, time, location, duration];
}
