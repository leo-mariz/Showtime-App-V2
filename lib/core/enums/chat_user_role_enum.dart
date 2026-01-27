import 'package:dart_mappable/dart_mappable.dart';

part 'chat_user_role_enum.mapper.dart';

@MappableEnum()
enum ChatUserRoleEnum {
  @MappableValue('CLIENT')
  client, // Cliente
  @MappableValue('ARTIST')
  artist; // Artista

  String get value {
    switch (this) {
      case ChatUserRoleEnum.client:
        return 'CLIENT';
      case ChatUserRoleEnum.artist:
        return 'ARTIST';
    }
  }
}
