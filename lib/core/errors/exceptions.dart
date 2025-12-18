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
