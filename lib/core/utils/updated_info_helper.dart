import 'package:app/core/domain/updated_info_type.dart';

/// Retorna um novo mapa com [current] mais a entrada [type] → agora (ms).
/// Usado para atualizar [ArtistEntity.updatedInfos] e [EnsembleEntity.updatedInfos].
Map<String, int> mergeUpdatedInfo(
  Map<String, int>? current,
  UpdatedInfoType type,
) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return {...?current, type.name: now};
}
