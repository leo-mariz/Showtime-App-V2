// import 'package:flutter/material.dart';

// /// DTO para validação de sobreposição de horários
// class ValidateTimeSlotOverlapDto {
//   /// Data do dia no formato YYYY-MM-DD
//   final String dayId;

//   /// ID da entry dentro do dia
//   final String entryId;

//   /// Horário de início do novo slot
//   final TimeOfDay startTime;

//   /// Horário de fim do novo slot
//   final TimeOfDay endTime;

//   /// ID do slot a ser ignorado na validação (usado ao editar)
//   /// Se estiver editando um slot existente, passe o ID dele aqui
//   /// para que ele não seja considerado um conflito consigo mesmo
//   final String? excludeSlotId;

//   const ValidateTimeSlotOverlapDto({
//     required this.dayId,
//     required this.entryId,
//     required this.startTime,
//     required this.endTime,
//     this.excludeSlotId,
//   });

//   /// Valida se o horário é válido (fim depois do início)
//   bool get isValidTimeRange {
//     final startMinutes = startTime.hour * 60 + startTime.minute;
//     final endMinutes = endTime.hour * 60 + endTime.minute;
//     return endMinutes > startMinutes;
//   }

//   /// Calcula duração em minutos
//   int get durationInMinutes {
//     final startMinutes = startTime.hour * 60 + startTime.minute;
//     final endMinutes = endTime.hour * 60 + endTime.minute;
//     return endMinutes - startMinutes;
//   }

//   /// Calcula duração em horas
//   double get durationInHours => durationInMinutes / 60.0;

//   @override
//   String toString() {
//     return 'ValidateTimeSlotOverlapDto('
//         'dayId: $dayId, '
//         'entryId: $entryId, '
//         'startTime: ${startTime.hour}:${startTime.minute}, '
//         'endTime: ${endTime.hour}:${endTime.minute}, '
//         'excludeSlotId: $excludeSlotId)';
//   }
// }
