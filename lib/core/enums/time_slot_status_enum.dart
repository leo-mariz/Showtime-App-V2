import 'package:dart_mappable/dart_mappable.dart';

part 'time_slot_status_enum.mapper.dart';

@MappableEnum()
enum TimeSlotStatusEnum {
  @MappableValue('AVAILABLE')
  available, // Slot disponível para reserva
  @MappableValue('BOOKED')
  booked; // Slot reservado

  String get value {
    switch (this) {
      case TimeSlotStatusEnum.available:
        return 'AVAILABLE';
      case TimeSlotStatusEnum.booked:
        return 'BOOKED';
    }
  }
}
