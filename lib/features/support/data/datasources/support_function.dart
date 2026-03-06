import 'package:cloud_functions/cloud_functions.dart';

/// Chama a callable **contestContract** no Firebase para abrir uma contestação no contrato.
///
/// O backend atualiza os campos de contestação e define `financialStatus` para `CONTESTED`.
/// O chamador deve ser o **cliente** do contrato (`contestedBy: 'CLIENT'`), o **artista**
/// (`'ARTIST'`) ou um **admin** (`'PLATFORM'`). O backend valida permissões.
///
/// Payload:
/// - [contractUid] – UID do contrato (documento na coleção Contracts).
/// - [contestedBy] – `'CLIENT'`, `'ARTIST'` ou `'PLATFORM'`.
/// - [contestedReason] – motivo da contestação (opcional).
///
/// Em sucesso: retorno é `{ "success": true }`.
/// Em erro: lança [FirebaseFunctionsException] (ex.: 404 contrato não encontrado,
/// 400 já contestado, 403 sem permissão). Use [ContestedBy] (core/enums) para valores tipados.
Future<void> contestContract({
  required String contractUid,
  required String contestedBy,
  String? contestedReason,
}) async {
  final callable = FirebaseFunctions.instance.httpsCallable('contestContract');

  final result = await callable.call({
    'contractUid': contractUid,
    'contestedBy': contestedBy,
    if (contestedReason != null && contestedReason.isNotEmpty) 'contestedReason': contestedReason,
  });

  final data = result.data is Map ? result.data as Map<String, dynamic> : null;
  final success = data?['success'] == true;
  if (!success) {
    throw Exception('Resposta inesperada da contestação');
  }
}
