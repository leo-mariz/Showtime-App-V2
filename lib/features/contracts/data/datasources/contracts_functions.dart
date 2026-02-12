import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/firebase_functions_service.dart';

/// Interface para chamadas às Cloud Functions de contratos.
/// Todas as escritas/atualizações de contrato devem passar por essas funções;
/// o índice (user_contracts_index) continua sendo atualizado no client.
abstract class IContractsFunctionsService {
  /// Cria contrato. Retorna [contractId].
  /// Cliente: auth.uid deve ser refClient.
  Future<String> addContract(Map<String, dynamic> payload);

  /// Apenas verifica se o contrato é aceitável (disponibilidade/overlap).
  /// Não cria nem altera contrato. Usar em [MakePaymentUseCase] antes de abrir pagamento.
  Future<bool> verifyContract(Map<String, dynamic> contractMap);

  /// Artista aceita a solicitação. Contrato deve estar PENDING.
  Future<void> acceptContract(String contractUid);

  /// Artista rejeita a solicitação.
  Future<void> rejectContract(String contractUid);

  /// Cliente ou artista cancela. [canceledBy]: 'CLIENT' ou 'ARTIST'.
  Future<void> cancelContract(String contractUid, String canceledBy, {String? cancelReason});

  /// Artista confirma show com código. Contrato deve estar PAID.
  Future<void> confirmShow(String contractUid, String confirmationCode);

  /// Cliente avalia o artista.
  Future<void> rateArtist(String contractUid, double rating, {String? comment, bool skippedRating = false});

  /// Cliente avalia o grupo (espelho de rateArtist).
  Future<void> rateGroup(String contractUid, double rating, {String? comment, bool skippedRating = false});

  /// Artista avalia o cliente.
  Future<void> rateClient(String contractUid, double rating, {String? comment, bool skippedRating = false});

  /// Cliente pula a avaliação do artista ("Avaliar depois").
  Future<void> skipRatingArtist(String contractUid);

  /// Artista pula a avaliação do cliente ("Avaliar depois").
  Future<void> skipRatingClient(String contractUid);
}

/// Implementação que delega às callable functions.
class ContractsFunctionsService implements IContractsFunctionsService {
  final IFirebaseFunctionsService _functions;

  ContractsFunctionsService({required IFirebaseFunctionsService functions}) : _functions = functions;

  static const String _addContract = 'addContract';
  static const String _verifyContract = 'verifyContract';
  static const String _acceptContract = 'acceptContract';
  static const String _rejectContract = 'rejectContract';
  static const String _cancelContract = 'cancelContract';
  static const String _confirmShow = 'confirmShow';
  static const String _rateArtist = 'rateArtist';
  static const String _rateGroup = 'rateGroup';
  static const String _rateClient = 'rateClient';
  static const String _skipRatingArtist = 'skipRatingArtist';
  static const String _skipRatingClient = 'skipRatingClient';

  @override
  Future<String> addContract(Map<String, dynamic> payload) async {
    final result = await _functions.callFunction(_addContract, payload);
    // Backend pode retornar 200 com { error: { code, message } } em vez de lançar
    final callableError = CallableFunctionException.fromResponseMap(result);
    if (callableError != null) throw callableError;
    final contractId = result['contractId'] as String?;
    if (contractId == null || contractId.isEmpty) {
      throw const ServerException('Resposta da função addContract não contém contractId');
    }
    return contractId;
  }

  @override
  Future<bool> verifyContract(Map<String, dynamic> contractMap) async {
    final result = await _functions.callFunction(_verifyContract, contractMap);
    final callableError = CallableFunctionException.fromResponseMap(result);
    if (callableError != null) throw callableError;
    return result['acceptable'] as bool? ?? false;
  }

  @override
  Future<void> acceptContract(String contractUid) async {
    await _functions.callFunction(_acceptContract, {'contractUid': contractUid});
  }

  @override
  Future<void> rejectContract(String contractUid) async {
    await _functions.callFunction(_rejectContract, {'contractUid': contractUid});
  }

  @override
  Future<void> cancelContract(String contractUid, String canceledBy, {String? cancelReason}) async {
    final payload = <String, dynamic>{
      'contractUid': contractUid,
      'canceledBy': canceledBy,
    };
    if (cancelReason != null && cancelReason.isNotEmpty) {
      payload['cancelReason'] = cancelReason;
    }
    await _functions.callFunction(_cancelContract, payload);
  }

  @override
  Future<void> confirmShow(String contractUid, String confirmationCode) async {
    await _functions.callFunction(_confirmShow, {
      'contractUid': contractUid,
      'confirmationCode': confirmationCode,
    });
  }

  @override
  Future<void> rateArtist(String contractUid, double rating, {String? comment, bool skippedRating = false}) async {
    final payload = <String, dynamic>{
      'contractUid': contractUid,
      'rating': rating,
      'skippedRating': skippedRating,
    };
    if (comment != null && comment.isNotEmpty) payload['comment'] = comment;
    await _functions.callFunction(_rateArtist, payload);
  }

  @override
  Future<void> rateGroup(String contractUid, double rating, {String? comment, bool skippedRating = false}) async {
    final payload = <String, dynamic>{
      'contractUid': contractUid,
      'rating': rating,
      'skippedRating': skippedRating,
    };
    if (comment != null && comment.isNotEmpty) payload['comment'] = comment;
    await _functions.callFunction(_rateGroup, payload);
  }

  @override
  Future<void> rateClient(String contractUid, double rating, {String? comment, bool skippedRating = false}) async {
    final payload = <String, dynamic>{
      'contractUid': contractUid,
      'rating': rating,
      'skippedRating': skippedRating,
    };
    if (comment != null && comment.isNotEmpty) payload['comment'] = comment;
    await _functions.callFunction(_rateClient, payload);
  }

  @override
  Future<void> skipRatingArtist(String contractUid) async {
    await _functions.callFunction(_skipRatingArtist, {'contractUid': contractUid});
  }

  @override
  Future<void> skipRatingClient(String contractUid) async {
    await _functions.callFunction(_skipRatingClient, {'contractUid': contractUid});
  }
}
