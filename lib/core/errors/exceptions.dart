import 'package:cloud_functions/cloud_functions.dart';

/// Exceções customizadas para DataSources e Services
/// 
/// DataSources devem lançar apenas essas exceções específicas.
/// Repositories convertem essas exceções em Failures usando ErrorHandler.
/// 
/// Regra: NUNCA lance Exception genérica, sempre use uma das exceções tipadas abaixo.

/// Classe base para todas as exceções do app
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Exceção de rede (sem conexão, timeout, etc)
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exceção de cache local (falha ao ler/escrever)
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exceção quando recurso não é encontrado (404, documento não existe)
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exceção de servidor (500, erros de backend)
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException${statusCode != null ? " ($statusCode)" : ""}: $message';
}

/// Exceção de autenticação (credenciais inválidas, token expirado)
class AuthException extends AppException {
  final String? code;

  const AuthException(
    super.message, {
    this.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'AuthException${code != null ? " ($code)" : ""}: $message';
}

/// Exceção de validação (dados inválidos)
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exceção quando dados estão incompletos
class IncompleteDataException extends AppException {
  final List<String>? missingFields;

  const IncompleteDataException(
    super.message, {
    this.missingFields,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'IncompleteDataException: $message${missingFields != null ? " - Campos faltantes: ${missingFields!.join(', ')}" : ""}';
}

/// Exceção de permissão (acesso negado)
class PermissionException extends AppException {
  const PermissionException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'PermissionException: $message';
}

/// Exceção de localização (erros relacionados a GPS/geolocalização)
class LocationException extends AppException {
  const LocationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'LocationException: $message';
}

/// Códigos de erro retornados pelas Callable Functions (backend).
/// Ver manual de tratamento de erros – Callable Functions.
enum CallableErrorCode {
  unauthorized,
  forbidden,
  validation,
  notFound,
  server,
}

/// Exceção lançada quando uma Callable Function retorna erro estruturado
/// ({ error: { code, message } }). Permite que use cases/repositórios exibam
/// a [message] ao usuário e tratem [code] (ex.: UNAUTHORIZED → login).
class CallableFunctionException extends AppException {
  /// Código do backend: UNAUTHORIZED, FORBIDDEN, VALIDATION, NOT_FOUND, SERVER
  final CallableErrorCode code;

  const CallableFunctionException(
    super.message, {
    required this.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'CallableFunctionException($code): $message';

  /// Converte mapa de resposta (quando o backend retorna 200 com body
  /// { "error": { "code": string, "message": string } }) em [CallableFunctionException].
  /// Use em addContract/verifyContract etc. quando a callable não lança, mas retorna erro.
  static CallableFunctionException? fromResponseMap(Map<String, dynamic>? result) {
    if (result == null) return null;
    final error = result['error'];
    if (error == null || error is! Map) return null;
    final codeStr = (error['code'] as String?)?.toUpperCase();
    final message = error['message'] as String?;
    if (codeStr == null || codeStr.isEmpty) return null;
    final code = _parseCode(codeStr);
    final msg = (message != null && message.isNotEmpty)
        ? message
        : _defaultMessageForCode(code);
    return CallableFunctionException(msg, code: code, originalError: result);
  }

  /// Converte [FirebaseFunctionsException] em [CallableFunctionException] quando
  /// [e.details] contém o formato do backend: { "error": { "code": string, "message": string } }.
  /// Retorna null se os detalhes não tiverem esse formato.
  static CallableFunctionException? tryParse(FirebaseFunctionsException? e) {
    if (e == null) return null;
    final details = e.details;
    if (details == null || details is! Map) return null;
    final error = details['error'];
    if (error == null || error is! Map) return null;
    final codeStr = (error['code'] as String?)?.toUpperCase();
    final message = error['message'] as String?;
    if (codeStr == null || codeStr.isEmpty) return null;
    final code = _parseCode(codeStr);
    final msg = (message != null && message.isNotEmpty)
        ? message
        : _defaultMessageForCode(code);
    return CallableFunctionException(
      msg,
      code: code,
      originalError: e,
    );
  }

  static CallableErrorCode _parseCode(String codeStr) {
    return switch (codeStr) {
      'UNAUTHORIZED' => CallableErrorCode.unauthorized,
      'FORBIDDEN' => CallableErrorCode.forbidden,
      'VALIDATION' => CallableErrorCode.validation,
      'VALIDAÇÃO' => CallableErrorCode.validation,
      'NOT_FOUND' => CallableErrorCode.notFound,
      'SERVER' => CallableErrorCode.server,
      _ => CallableErrorCode.server,
    };
  }

  static String _defaultMessageForCode(CallableErrorCode code) {
    return switch (code) {
      CallableErrorCode.unauthorized => 'É necessário estar autenticado.',
      CallableErrorCode.forbidden => 'Você não tem permissão para esta ação.',
      CallableErrorCode.validation => 'Dados inválidos.',
      CallableErrorCode.notFound => 'Não encontrado.',
      CallableErrorCode.server => 'Algo deu errado. Tente novamente.',
    };
  }
}
