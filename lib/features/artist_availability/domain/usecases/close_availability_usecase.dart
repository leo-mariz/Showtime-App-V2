import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// UseCase: Fechar disponibilidade do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do usuário
/// - Buscar disponibilidades existentes
/// - Aplicar lógica de fechamento cortando períodos sobrepostos
/// - Salvar novas disponibilidades atualizadas
class CloseAvailabilityUseCase {
  final IAvailabilityRepository availabilityRepository;

  CloseAvailabilityUseCase({
    required this.availabilityRepository,
  });

  Future<Either<Failure, List<AvailabilityEntity>>> call(String uid, Appointment closeAppointment) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      final allDaysOfWeek = AvailabilityEntityOptions.daysOfWeekList();

      // Close Appointment
      final closeStartTime = closeAppointment.startTime;
      final closeEndTime = closeAppointment.endTime;
      final closeRecurrenceRule = closeAppointment.recurrenceRule ?? '';
      final closeUntil = closeRecurrenceRule.split('UNTIL=')[1];

      // Close Dates
      final closeStartDate = DateTime(closeStartTime.year, closeStartTime.month, closeStartTime.day);
      final closeUntilDate = DateTime.parse(closeUntil.replaceAll('Z', ''));
      
      // Close Recurrence Days
      List<String> closeRecurrenceDays;
      if (closeRecurrenceRule.isNotEmpty && closeRecurrenceRule.contains('BYDAY')) {
        closeRecurrenceDays = closeRecurrenceRule.split('BYDAY=')[1].split(';')[0].split(',').toList();
      } else {
        closeRecurrenceDays = allDaysOfWeek;
      }

      // Close Hours
      final int closeStartHour = closeStartTime.hour;
      final int closeStartMinutes = closeStartTime.minute;
      final int closeUntilHour = closeEndTime.hour;
      final int closeUntilMinutes = closeEndTime.minute;

      List<Appointment> newAppointmentsList = [];
      
      // Buscar disponibilidades existentes
      final availabilityListResult = await availabilityRepository.getAvailabilities(uid);
      final availabilityList = availabilityListResult.fold(
        (failure) => <AvailabilityEntity>[],
        (availabilityList) => availabilityList,
      );
      
      List<dynamic> appointmentsDynamic = availabilityList.map((availability) => availability.toAppointment()).toList();
      List<Appointment> appointments = appointmentsDynamic.map((appointment) => appointment as Appointment).toList();
      
      for (var appointment in appointments) {
        final appointmentStartTime = appointment.startTime;
        final appointmentEndTime = appointment.endTime;
        final String appointmentRecurrenceRule = appointment.recurrenceRule ?? '';
        final String appointmentUntil = appointmentRecurrenceRule.split('UNTIL=')[1];
        final String appointmentSubject = appointment.subject;
        final String? appointmentNotes = appointment.notes;

        // Appointment Dates
        final DateTime appointmentStartDate = DateTime(appointmentStartTime.year, appointmentStartTime.month, appointmentStartTime.day);
        final DateTime appointmentUntilDate = DateTime.parse(appointmentUntil.replaceAll('Z', ''));
        
        // Appointment Recurrence Days  
        List<String> appointmentRecurrenceDays;
        if (appointmentRecurrenceRule.isNotEmpty && appointmentRecurrenceRule.contains('BYDAY')) {
          appointmentRecurrenceDays = appointmentRecurrenceRule.split('BYDAY=')[1].split(';')[0].split(',').toList();
        } else {
          appointmentRecurrenceDays = allDaysOfWeek;
        }

        // Appointment Hours
        final int appointmentStartHour = appointmentStartTime.hour;
        final int appointmentStartMinutes = appointmentStartTime.minute;
        final int appointmentUntilHour = appointmentEndTime.hour;
        final int appointmentUntilMinutes = appointmentEndTime.minute;

        // Datas
        DateTime? newStartDate;
        DateTime? newUntilDate;
        
        if (appointmentStartDate.isAfter(closeUntilDate) || appointmentUntilDate.isBefore(closeStartDate)) {
          newAppointmentsList.add(appointment);
          continue;
        } 
        
        if ((closeStartDate.isAtSameMomentAs(appointmentStartDate) || closeStartDate.isBefore(appointmentStartDate)) && ((closeUntilDate.isAtSameMomentAs(appointmentStartDate) || closeUntilDate.isAfter(appointmentStartDate)) && closeUntilDate.isBefore(appointmentUntilDate))) {
          DateTime newAppointmentStartDate = closeUntilDate.add(const Duration(days: 1));
          DateTime newStartTime = DateTime(newAppointmentStartDate.year, newAppointmentStartDate.month, newAppointmentStartDate.day, appointmentStartHour, appointmentStartMinutes);
          DateTime newEndTime = DateTime(newAppointmentStartDate.year, newAppointmentStartDate.month, newAppointmentStartDate.day, appointmentUntilHour, appointmentUntilMinutes);

          Appointment newAppointment = Appointment(
            startTime: newStartTime, 
            endTime: newEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: appointmentRecurrenceRule,
          );
          newAppointmentsList.add(newAppointment);
        
          newStartDate = appointmentStartDate;
          newUntilDate = closeUntilDate;
        }
        
        if ((closeUntilDate.isAtSameMomentAs(appointmentUntilDate) || closeUntilDate.isAfter(appointmentUntilDate)) && ((closeStartDate.isAtSameMomentAs(appointmentUntilDate) || closeStartDate.isBefore(appointmentUntilDate)) && closeStartDate.isAfter(appointmentStartDate))) {
          DateTime newAppointmentUntilDate = closeStartDate.subtract(const Duration(days: 1));
          String newRecurrenceRule = appointmentRecurrenceRule.replaceAll('UNTIL=$appointmentUntil', 'UNTIL=$newAppointmentUntilDate');
          Appointment newAppointment = Appointment(
            startTime: appointmentStartTime, 
            endTime: appointmentEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newRecurrenceRule,
          );
          newAppointmentsList.add(newAppointment);
        
          newStartDate = closeStartDate;
          newUntilDate = appointmentUntilDate;
        }
        
        if (closeStartDate.isAfter(appointmentStartDate) && closeUntilDate.isBefore(appointmentUntilDate)) {
          DateTime newAppointmentStartDate = closeUntilDate.add(const Duration(days: 1));
          DateTime newStartTime = DateTime(newAppointmentStartDate.year, newAppointmentStartDate.month, newAppointmentStartDate.day, appointmentStartHour, appointmentStartMinutes);
          DateTime newEndTime = DateTime(newAppointmentStartDate.year, newAppointmentStartDate.month, newAppointmentStartDate.day, appointmentUntilHour, appointmentUntilMinutes);

          Appointment newFirstAppointment = Appointment(
            startTime: newStartTime, 
            endTime: newEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: appointmentRecurrenceRule,
          );
        
          DateTime newAppointmentUntilDate = closeStartDate.subtract(const Duration(days: 1));
          String newRecurrenceRule = appointmentRecurrenceRule.replaceAll('UNTIL=$appointmentUntil', 'UNTIL=$newAppointmentUntilDate');
          Appointment newSecondAppointment = Appointment(
            startTime: appointmentStartTime, 
            endTime: appointmentEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newRecurrenceRule,
          );
          newAppointmentsList.add(newFirstAppointment);
          newAppointmentsList.add(newSecondAppointment);
          
          newStartDate = closeStartDate;
          newUntilDate = closeUntilDate;
        }
        
        if ((closeStartDate.isAtSameMomentAs(appointmentStartDate) || closeStartDate.isBefore(appointmentStartDate)) && (closeUntilDate.isAtSameMomentAs(appointmentUntilDate) || closeUntilDate.isAfter(appointmentUntilDate))) {
          newStartDate = appointmentStartDate;
          newUntilDate = appointmentUntilDate;
        }

        if (newStartDate == null && newUntilDate == null) {
          continue;
        }

        // Recorrencias
        //Verifica se os dias de fechamento estão contidos nos dias de recorrência do appointment
        final closeAppointmentDays = closeRecurrenceDays.where((day) => appointmentRecurrenceDays.contains(day)).toList();
        final updatedAppointmentDays = appointmentRecurrenceDays.where((day) => !closeRecurrenceDays.contains(day)).toList();
        String updatedByDay = updatedAppointmentDays.join(',');
        String closeByDay = closeAppointmentDays.join(',');
        
        if (updatedAppointmentDays.isNotEmpty) {
          String newByDaysRecurrenceRule = appointmentRecurrenceRule.replaceAll(RegExp(r'BYDAY=([^;]*)'), 'BYDAY=$updatedByDay');
          DateTime newStartTime = DateTime(newStartDate!.year, newStartDate.month, newStartDate.day, appointmentStartHour, appointmentStartMinutes);
          DateTime newEndTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, appointmentUntilHour, appointmentUntilMinutes);
          DateTime newUntilTime = DateTime(newUntilDate!.year, newUntilDate.month, newUntilDate.day, appointmentUntilHour, appointmentUntilMinutes);
          String newRecurrenceRule = newByDaysRecurrenceRule.replaceAll('UNTIL=$appointmentUntil', 'UNTIL=$newUntilTime');
          Appointment newAppointment = Appointment(
            startTime: newStartTime, 
            endTime: newEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newRecurrenceRule,
          );
          newAppointmentsList.add(newAppointment);
        }
        
        if (closeAppointmentDays.isEmpty) {
          continue;
        }

        String newByDaysRecurrenceRule = appointmentRecurrenceRule.replaceAll(RegExp(r'BYDAY=([^;]*)'), 'BYDAY=$closeByDay');
        DateTime newUntilTime = DateTime(newUntilDate!.year, newUntilDate.month, newUntilDate.day, appointmentUntilHour, appointmentUntilMinutes);
        String newHorariosRecurrenceRule = newByDaysRecurrenceRule.replaceAll('UNTIL=$appointmentUntil', 'UNTIL=$newUntilTime');
      
        // Horarios
        if (
          ((closeUntilHour < appointmentStartHour) || (closeUntilHour == appointmentStartHour && closeUntilMinutes <= appointmentStartMinutes)) 
          || ((closeStartHour > appointmentUntilHour) || (closeStartHour == appointmentUntilHour && closeStartMinutes >= appointmentUntilMinutes))
        ) {
          continue;
        }

        if (
          (closeStartHour < appointmentStartHour || (closeStartHour == appointmentStartHour && closeStartMinutes <= appointmentStartMinutes)) 
          && (((closeUntilHour < appointmentUntilHour) || ((closeUntilHour == appointmentUntilHour) && (closeUntilMinutes < appointmentUntilMinutes))) && ((closeUntilHour > appointmentStartHour) || ((closeUntilHour == appointmentStartHour) && (closeUntilMinutes > appointmentStartMinutes))))
        ) {
          DateTime newStartTime = DateTime(newStartDate!.year, newStartDate.month, newStartDate.day, closeUntilHour, closeUntilMinutes);
          DateTime newEndTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, appointmentUntilHour, appointmentUntilMinutes);
          Appointment newAppointment = Appointment(
            startTime: newStartTime,
            endTime: newEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newHorariosRecurrenceRule,
          );
          newAppointmentsList.add(newAppointment);
        }

        if (
          (closeUntilHour > appointmentUntilHour || (closeUntilHour == appointmentUntilHour && closeUntilMinutes >= appointmentUntilMinutes)) 
          && (((closeStartHour < appointmentUntilHour) || ((closeStartHour == appointmentUntilHour) && (closeStartMinutes < appointmentUntilMinutes))) && ((closeStartHour > appointmentStartHour) || ((closeStartHour == appointmentStartHour) && (closeStartMinutes > appointmentStartMinutes))))
        ) {
          DateTime newStartTime = DateTime(newStartDate!.year, newStartDate.month, newStartDate.day, appointmentStartHour, appointmentStartMinutes);
          DateTime newEndTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, closeStartHour, closeStartMinutes);
          Appointment newAppointment = Appointment(
            startTime: newStartTime,
            endTime: newEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newHorariosRecurrenceRule,
          );
          newAppointmentsList.add(newAppointment);
        }

        if (
          (closeStartHour > appointmentStartHour || (closeStartHour == appointmentStartHour && closeStartMinutes > appointmentStartMinutes)) 
          && (closeUntilHour < appointmentUntilHour || (closeUntilHour == appointmentUntilHour && closeUntilMinutes < appointmentUntilMinutes)) 
        ) {
          DateTime newFirstStartTime = DateTime(newStartDate!.year, newStartDate.month, newStartDate.day, closeUntilHour, closeUntilMinutes);
          DateTime newFirstEndTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, appointmentUntilHour, appointmentUntilMinutes);
          Appointment newFirstAppointment = Appointment(
            startTime: newFirstStartTime,
            endTime: newFirstEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newHorariosRecurrenceRule,
          );
          DateTime newSecondStartTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, appointmentStartHour, appointmentStartMinutes);
          DateTime newSecondEndTime = DateTime(newStartDate.year, newStartDate.month, newStartDate.day, closeStartHour, closeStartMinutes);
          Appointment newSecondAppointment = Appointment(
            startTime: newSecondStartTime,
            endTime: newSecondEndTime,
            subject: appointmentSubject,
            notes: appointmentNotes,
            recurrenceRule: newHorariosRecurrenceRule,
          );
          newAppointmentsList.add(newFirstAppointment);
          newAppointmentsList.add(newSecondAppointment);
        }
      }
      
      // Converter appointments para AvailabilityEntity
      List<AvailabilityEntity> newAvailabilityList = newAppointmentsList.map((appointment) => AvailabilityEntity.fromAppointment(appointment)).toList();
      
      // Substituir todas as disponibilidades usando batch operations (atomicidade e eficiência)
      final replaceResult = await availabilityRepository.replaceAvailabilities(uid, newAvailabilityList);
      
      return replaceResult.fold(
        (failure) => Left(failure),
        (_) => Right(newAvailabilityList),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

