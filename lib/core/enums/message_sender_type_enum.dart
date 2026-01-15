import 'package:dart_mappable/dart_mappable.dart';

part 'message_sender_type_enum.mapper.dart';

@MappableEnum()
enum MessageSenderTypeEnum {
  @MappableValue('USER')
  user,      // Mensagem enviada por cliente ou artista
  
  @MappableValue('SYSTEM')
  system;    // Mensagem enviada pelo sistema

  String get value {
    switch (this) {
      case MessageSenderTypeEnum.user:
        return 'USER';
      case MessageSenderTypeEnum.system:
        return 'SYSTEM';
    }
  }
}