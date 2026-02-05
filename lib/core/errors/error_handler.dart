import 'dart:async';
import 'dart:io';

import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Utilitário centralizado para conversão de exceções para failures
/// 
/// USO:
/// - Repositories devem usar este handler em blocos try-catch
/// - Converte exceções da data layer em failures da domain layer
/// 
/// EXEMPLO:
/// ```dart
/// try {
///   await dataSource.getData();
/// } catch (e) {
///   return Left(ErrorHandler.handle(e));
/// }
/// ```
class ErrorHandler {
  /// Converte qualquer erro para Failure correspondente
  /// 
  /// Ordem de verificação:
  /// 1. AppException (custom exceptions)
  /// 2. FirebaseAuthException (Firebase específico)
  /// 3. Exceções de rede (SocketException, TimeoutException, etc.)
  /// 4. Exception genérica
  /// 5. Objeto desconhecido
  static Failure handle(dynamic error) {
    // 1. Nossas exceções customizadas
    if (error is AppException) {
      return _handleAppException(error);
    }
    
    // 2. Exceções do Firebase Auth
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }
    
    // 3. Exceções de rede (sem conexão, timeout, falha de conexão)
    if (error is SocketException ||
        error is TimeoutException ||
        error is HandshakeException ||
        error is http.ClientException) {
      return NetworkFailure(
        'Sem conexão. Verifique sua internet e tente novamente.',
        originalError: error,
      );
    }
    if (error is FirebaseException &&
        (error.code == 'unavailable' || error.code == 'deadline-exceeded')) {
      return NetworkFailure(
        'Sem conexão. Verifique sua internet e tente novamente.',
        originalError: error,
      );
    }
    
    // 4. Exceções genéricas
    if (error is Exception) {
      return UnknownFailure(
        'Erro inesperado: ${error.toString()}',
        originalError: error,
      );
    }
    
    // 5. Objetos desconhecidos
    return UnknownFailure(
      'Erro desconhecido: ${error.toString()}',
      originalError: error,
    );
  }

  /// Converte AppException em Failure correspondente
  static Failure _handleAppException(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(
          exception.message,
          originalError: exception.originalError,
        ),
      CacheException() => CacheFailure(
          exception.message,
          originalError: exception.originalError,
        ),
      NotFoundException() => NotFoundFailure(
          exception.message,
          originalError: exception.originalError,
        ),
      ServerException(statusCode: final code) => ServerFailure(
          exception.message,
          statusCode: code,
          originalError: exception.originalError,
        ),
      AuthException() => AuthFailure(
          exception.message,
          originalError: exception.originalError,
        ),
      ValidationException(fieldErrors: final errors) => ValidationFailure(
          exception.message,
          fieldErrors: errors,
          originalError: exception.originalError,
        ),
      IncompleteDataException(missingFields: final fields) =>
        IncompleteDataFailure(
          exception.message,
          missingFields: fields,
          originalError: exception.originalError,
        ),
      PermissionException() => PermissionFailure(
          exception.message,
          originalError: exception.originalError,
        ),
      _ => UnknownFailure(
          exception.message,
          originalError: exception.originalError,
        ),
    };
  }

  /// Converte FirebaseAuthException em AuthFailure com mensagem amigável
  static AuthFailure _handleFirebaseAuthException(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-credential' => 'Credenciais inválidas',
      'user-not-found' => 'Usuário não encontrado',
      'wrong-password' => 'Senha incorreta',
      'invalid-email' => 'Email inválido',
      'user-disabled' => 'Usuário desabilitado',
      'email-already-in-use' => 'Email já cadastrado',
      'weak-password' => 'Senha muito fraca',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde',
      'network-request-failed' => 'Erro de conexão. Verifique sua internet',
      'requires-recent-login' => 'Sessão expirada. Faça login novamente',
      _ => 'Erro de autenticação: ${e.message ?? e.code}',
    };

    return AuthFailure(message, originalError: e);
  }

  /// Extrai status code de FirebaseException quando disponível
  /// 
  /// Mapeia códigos de erro do Firestore para códigos HTTP equivalentes
  /// para facilitar tratamento de erros nos datasources
  static int? getStatusCode(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => 403,
      'not-found' => 404,
      'already-exists' => 409,
      'unavailable' => 503,
      'deadline-exceeded' => 504,
      'resource-exhausted' => 429,
      'failed-precondition' => 412,
      'aborted' => 409,
      'out-of-range' => 400,
      'unimplemented' => 501,
      'internal' => 500,
      'unauthenticated' => 401,
      _ => null,
    };
  }
}

