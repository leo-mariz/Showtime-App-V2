import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/blocked_time_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
part 'availability_entity.mapper.dart';


@MappableClass()
class AvailabilityEntity with AvailabilityEntityMappable {
  String? id;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String horarioInicio;
  final String horarioFim;
  final List<String> diasDaSemana;
  final double valorShow;
  final AddressInfoEntity endereco;
  final double raioAtuacao;
  final bool repetir;
  final List<BlockedTimeSlot> blockedSlots;

  AvailabilityEntity({
    this.id,
    required this.dataInicio,
    required this.dataFim,
    required this.horarioInicio,
    required this.horarioFim,
    required this.diasDaSemana,
    required this.valorShow,
    required this.endereco,
    required this.raioAtuacao,
    required this.repetir,
    this.blockedSlots = const [],
  });

  // Factory para criar uma AvailabilityEntity a partir de um Appointment
  factory AvailabilityEntity.fromAppointment(Appointment appointment) {
    // Subject está no formato: "Disponível para Shows - {título} - Raio: {raio}km - R$ {valor}/hora"
    final subjectParts = appointment.subject.split(' - ');
    final raioAtuacao = double.tryParse(subjectParts[2].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final valorShowFromSubject = subjectParts.length > 3 
        ? double.tryParse(subjectParts[3].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0 
        : 0.0;
    final notesParts = appointment.notes?.split(' - ') ?? [];
    final addressPart = notesParts[1].split('Endereço: ')[1];

    final regex = RegExp(r'(\w+): ([^,]+)');
    final matches = regex.allMatches(addressPart);

    final Map<String, String> addressMap = {
      for (var match in matches) match.group(1)!: match.group(2)!
    };

    final endereco = AddressInfoEntity(title: addressMap['title'] ?? '',
      zipCode: addressMap['zipCode'] ?? '',
      street: addressMap['street'] ?? '',
      number: addressMap['number'] ?? '',
      district: addressMap['district'] ?? '',
      city: addressMap['city'] ?? '',
      state: addressMap['state'] ?? '',
      isPrimary: false,
      latitude: double.tryParse(addressMap['latitude'] ?? '0') ?? 0.0,
      longitude: double.tryParse(addressMap['longitude'] ?? '0') ?? 0.0,
      complement: addressMap['complement'] ?? '',
    );
    // Prioriza o valor do subject, mas usa notes como fallback para compatibilidade
    double valorShow = valorShowFromSubject;
    if (valorShow == 0.0) {
      final valorRegex = RegExp(r'Valor: R\$(\d+(?:\.\d+)?)');
      final valorMatch = valorRegex.firstMatch(appointment.notes ?? '');
      if (valorMatch != null) {
        valorShow = double.tryParse(valorMatch.group(1)!) ?? 0.0;
      }
    }
    final recurrenceRule = appointment.recurrenceRule ?? '';
    final repetir = recurrenceRule.isNotEmpty ? true : false;
    final diasDaSemana = recurrenceRule.contains('BYDAY=')
        ? recurrenceRule.split('BYDAY=')[1].split(';')[0].split(',')
        : <String>[];
    final dataUntil = recurrenceRule.split('UNTIL=')[1];
    final dataInicio = DateTime(appointment.startTime.year, appointment.startTime.month, appointment.startTime.day);
    final dataFim = DateTime.parse(dataUntil);
    final dataFimFormatada = DateTime(dataFim.year, dataFim.month, dataFim.day, dataFim.hour, dataFim.minute);
    DateFormat formatter = DateFormat('HH:mm');
    String horaInicio = formatter.format(appointment.startTime);
    String horaFim = formatter.format(appointment.endTime);
    return AvailabilityEntity(
      dataInicio: dataInicio,
      dataFim: dataFimFormatada,
      horarioInicio: horaInicio,
      horarioFim: horaFim,
      diasDaSemana: diasDaSemana,
      valorShow: valorShow,
      endereco: endereco,
      raioAtuacao: raioAtuacao,
      repetir: repetir,
      blockedSlots: const [],
    );
  }

  // Factory para criar um Appointment a partir de uma AvailabilityEntity
  Appointment toAppointment() {
    final partesHorarioInicio = horarioInicio.split(':');
    final partesHorarioFim = horarioFim.split(':');
    final horaInicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day, int.parse(partesHorarioInicio[0]), int.parse(partesHorarioInicio[1]));
    final horaFim = DateTime(dataFim.year, dataFim.month, dataFim.day, int.parse(partesHorarioFim[0]), int.parse(partesHorarioFim[1]));
    final horasFim = horaFim.hour;
    final minutosFim = horaFim.minute;
    DateTime dataUntil = DateTime(dataFim.year, dataFim.month, dataFim.day, horasFim, minutosFim);
    final recurrenceRule = repetir
        ? 'RRULE:FREQ=WEEKLY;BYDAY=${diasDaSemana.join(',')};UNTIL=${DateFormat("yyyyMMdd'T'HHmmss'Z'").format(dataUntil)}'
        : null;
    final addressToString = endereco.toString();
    final notes = 'Valor: R\$$valorShow/h - Endereço: $addressToString';
    
    return Appointment(
      startTime: DateTime(dataInicio.year, dataInicio.month, dataInicio.day, horaInicio.hour, horaInicio.minute),
      endTime: DateTime(dataInicio.year, dataInicio.month, dataInicio.day, horaFim.hour, horaFim.minute),
      subject: 'Disponível para Shows - ${endereco.title} - Raio: ${raioAtuacao}km - R\$ $valorShow/hora',
      notes: notes,
      recurrenceRule: recurrenceRule,
    );
  }
}

extension AvailabilityEntityKeys on AvailabilityEntity {
  static String cacheAndRemoteKeys (initialDate, initialTime) {
    return "$initialDate - $initialTime";
  }
}

extension ArtistAvailabilityEntityReference on AvailabilityEntity {

  static CollectionReference firestoreUidReference (FirebaseFirestore firestore, String groupUid) {
    final artistFirebaseUidReference = ArtistEntityReference.firebaseUidReference(firestore, groupUid);
    final artistAvailabilityReference = artistFirebaseUidReference.collection('Availability');
    return artistAvailabilityReference;
  }

  static String cachedKey() {
    return 'artist_availability_calendar';
  }
}

extension GroupAvailabilityEntityReference on AvailabilityEntity {
  static CollectionReference firestoreUidReference (FirebaseFirestore firestore, String groupUid) {
    final groupFirebaseUidReference = GroupEntityReference.firebaseUidReference(firestore, groupUid);
    final groupAvailabilityReference = groupFirebaseUidReference.collection('Availability');
    return groupAvailabilityReference;
  }

  static String cachedKey() {
    return 'group_availability_calendar';
  }
}

extension AvailabilityEntityOptions on AvailabilityEntity {
  static List<String> daysOfWeek() {
    return ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  }

  static Map<String, String> daysOfWeekMap() {
    return {
      'Domingo': 'SU',
      'Segunda': 'MO',
      'Terça': 'TU',
      'Quarta': 'WE',
      'Quinta': 'TH',
      'Sexta': 'FR',
      'Sábado': 'SA',
    };
  }

  static List<String> daysOfWeekList() {
    return ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
  }
}

