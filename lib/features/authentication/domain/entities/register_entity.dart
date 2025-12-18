import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'register_entity.mapper.dart';

@MappableClass()
class RegisterEntity with RegisterEntityMappable{
  final UserEntity user;
  final ArtistEntity artist;
  final ClientEntity client;

  RegisterEntity({
    required this.user,
    required this.artist,
    required this.client,
  });
}

