import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Interface do serviço para chamadas de Cloud Functions do Firebase
abstract class IFirebaseFunctionsService {
  /// Chama uma Cloud Function do Firebase
  /// 
  /// [functionName] - Nome da função a ser chamada
  /// [data] - Dados a serem enviados para a função
  /// 
  /// Retorna o resultado da função como 
  /// Lança [ServerException] em caso de erro
  Future<Map<String, dynamic>> callFunction(
    String functionName,
    Map<String, dynamic> data,
  );

  /// Cria um pagamento no Mercado Pago através da Cloud Function
  /// 
  /// [contractId] - ID do contrato relacionado ao pagamento
  /// [isTestingPayment] - Se true, cria pagamento de teste; se false, cria pagamento real
  /// 
  /// Retorna o link de pagamento gerado
  /// Lança [ServerException] em caso de erro
  Future<String> createMercadoPagoPayment(
    String contractId,
    bool isTestingPayment,
  );
}

/// Implementação do serviço para chamadas de Cloud Functions
/// 
/// Para configurar uma região específica (se necessário):
/// ```dart
/// FirebaseFunctionsService(
///   functions: FirebaseFunctions.instanceFor(region: 'us-central1'),
/// )
/// ```
class FirebaseFunctionsService implements IFirebaseFunctionsService {
  final FirebaseFunctions _functions;

  FirebaseFunctionsService({
    FirebaseFunctions? functions,
    // Se sua função estiver em uma região diferente, configure aqui:
    // Exemplo: String? region, // 'us-central1', 'southamerica-east1', etc.
  }) : _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<Map<String, dynamic>> callFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    try {
      if (functionName.isEmpty) {
        throw const ValidationException('Nome da função não pode ser vazio');
      }

      if (kDebugMode) {
        print('📞 [FirebaseFunctions] Chamando função: $functionName');
        print('📦 [FirebaseFunctions] Dados: $data');
      }

      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(data);

      if (kDebugMode) {
        print('✅ [FirebaseFunctions] Função $functionName executada com sucesso');
      }

      // Retornar os dados da resposta
      // result.data pode ser Map, List, String, etc.
      if (result.data is Map) {
        return result.data as Map<String, dynamic>;
      } else if (result.data is Map<String, dynamic>) {
        return result.data as Map<String, dynamic>;
      } else {
        // Se não for Map, envolver em um Map
        return {'data': result.data};
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [FirebaseFunctions] Erro ao chamar função $functionName:');
        print('   Código: ${e.code}');
        print('   Mensagem: ${e.message}');
        print('   Detalhes: ${e.details}');
        
        // Mensagem específica para erro "not-found"
        if (e.code == 'not-found') {
          print('');
          print('⚠️ [FirebaseFunctions] A função "$functionName" não foi encontrada.');
          print('   Possíveis causas:');
          print('   1. A função não foi implantada no Firebase');
          print('   2. O nome da função está incorreto');
          print('   3. A função está em uma região diferente');
          print('   4. Você está usando emulador local mas não está configurado');
          print('');
          print('   Para verificar:');
          print('   - Execute: firebase functions:list');
          print('   - Verifique se a função está implantada');
          print('   - Verifique a região da função no Firebase Console');
        }
      }

      // Mensagem mais específica para erro "not-found"
      String errorMessage;
      if (e.code == 'not-found') {
        errorMessage = 'Função "$functionName" não encontrada. Verifique se a função foi implantada no Firebase e se o nome está correto.';
      } else {
        errorMessage = 'Erro ao executar função $functionName: ${e.message ?? e.code}';
      }

      throw ServerException(
        errorMessage,
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [FirebaseFunctions] Erro inesperado ao chamar função $functionName: $e');
      }

      throw ServerException(
        'Erro inesperado ao executar função $functionName',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> createMercadoPagoPayment(
    String contractId,
    bool isTestingPayment,
  ) async {
    try {
      if (contractId.isEmpty) {
        throw const ValidationException('Contract ID não pode ser vazio');
      }

      final result = await callFunction(
        'createMercadoPagoPayment',
        {
          'contractId': contractId,
          'isTestingPayment': isTestingPayment,
        },
      );

      // Extrair o paymentLink do resultado
      if (result.containsKey('paymentLink')) {
        final paymentLink = result['paymentLink'];
        
        if (paymentLink is String && paymentLink.isNotEmpty) {
          return paymentLink;
        } else {
          throw const ServerException(
            'Link de pagamento inválido retornado pela função',
          );
        }
      } else {
        throw const ServerException(
          'Resposta da função não contém paymentLink',
        );
      }
    } on ValidationException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao criar pagamento do Mercado Pago',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

