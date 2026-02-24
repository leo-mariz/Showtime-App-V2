import 'package:dart_mappable/dart_mappable.dart';

part 'contested_by_enum.mapper.dart';

/// Quem abriu a contestação no contrato (espelhado do Admin / Firestore).
@MappableEnum()
enum ContestedBy {
  @MappableValue('CLIENT')
  client,

  @MappableValue('ARTIST')
  artist,

  @MappableValue('PLATFORM')
  platform,
}

extension ContestedByDisplay on ContestedBy {
  /// Label em português para exibição na UI.
  String get displayName {
    switch (this) {
      case ContestedBy.client:
        return 'Anfitrião';
      case ContestedBy.artist:
        return 'Artista';
      case ContestedBy.platform:
        return 'Plataforma';
    }
  }
}

/// Converte string (ex. do Firestore) para enum; retorna null se inválido.
ContestedBy? tryParseContestedBy(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return ContestedByMapper.fromValue(value);
  } catch (_) {
    return null;
  }
}
