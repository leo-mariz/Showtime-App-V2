// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'chat_user_role_enum.dart';

class ChatUserRoleEnumMapper extends EnumMapper<ChatUserRoleEnum> {
  ChatUserRoleEnumMapper._();

  static ChatUserRoleEnumMapper? _instance;
  static ChatUserRoleEnumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChatUserRoleEnumMapper._());
    }
    return _instance!;
  }

  static ChatUserRoleEnum fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ChatUserRoleEnum decode(dynamic value) {
    switch (value) {
      case 'CLIENT':
        return ChatUserRoleEnum.client;
      case 'ARTIST':
        return ChatUserRoleEnum.artist;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ChatUserRoleEnum self) {
    switch (self) {
      case ChatUserRoleEnum.client:
        return 'CLIENT';
      case ChatUserRoleEnum.artist:
        return 'ARTIST';
    }
  }
}

extension ChatUserRoleEnumMapperExtension on ChatUserRoleEnum {
  dynamic toValue() {
    ChatUserRoleEnumMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ChatUserRoleEnum>(this);
  }
}

