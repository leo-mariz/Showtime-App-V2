/// Failures para Either<Failure, T>
/// 
/// Repositories devem retornar essas failures na camada Left do Either.
/// Use Cases também podem retornar failures adicionais específicas.
/// 
/// Regra: Repositories convertem Exceptions em Failures usando ErrorHandler.

/// Classe base abstrata para todas as failures
abstract class Failure {
  final String message;
  final dynamic originalError;

  const Failure(this.message, {this.originalError});

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Falha de rede (sem conexão, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.originalError});
}

/// Falha de cache local
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.originalError});
}

/// Falha quando recurso não é encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.originalError});
}

/// Falha de servidor (500, erros de backend)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode, super.originalError});

  @override
  String toString() => statusCode != null 
      ? 'ServerFailure ($statusCode): $message' 
      : 'ServerFailure: $message';
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.originalError});
}

/// Falha de validação
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors,
    super.originalError,
  });
}

/// Falha quando dados estão incompletos
class IncompleteDataFailure extends Failure {
  final List<String>? missingFields;

  const IncompleteDataFailure(
    super.message, {
    this.missingFields,
    super.originalError,
  });
}

/// Falha de permissão
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.originalError});
}

/// Falha desconhecida (catch-all)
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.originalError});
}
