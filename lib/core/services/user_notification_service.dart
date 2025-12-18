import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

abstract class IUserNotificationService {
  Future<void> saveUserToken();
  Future<void> removeUserToken();
  Future<void> updateUserToken();
}

class UserNotificationService implements IUserNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final INotificationService _notificationService =
      GetIt.instance<INotificationService>();

  @override
  Future<void> saveUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Usuário não autenticado, não é possível salvar token');
        }
        throw const AuthException('Usuário não autenticado');
      }

      final token = await _notificationService.getToken();
      if (token == null) {
        if (kDebugMode) {
          print('⚠️ Token de notificação não disponível');
        }
        // Não interromper o processo - token pode não estar disponível e tudo bem
        return;
      }

      // Salvar token no Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc('fcm_token')
          .set({
        'token': token,
        'platform': 'ios',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Token salvo para usuário: ${user.uid}');
      }
    } on AppException {
      // Re-lança exceções já tipadas
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erro ao salvar token: $e');
      }
      throw ServerException(
        'Erro ao salvar token de notificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> removeUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Usuário não autenticado, não é possível remover token');
        }
        throw const AuthException('Usuário não autenticado');
      }

      // Remover token do Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc('fcm_token')
          .delete();

      if (kDebugMode) {
        print('✅ Token removido para usuário: ${user.uid}');
      }
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erro ao remover token: $e');
      }
      throw ServerException(
        'Erro ao remover token de notificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Usuário não autenticado, não é possível atualizar token');
        }
        throw const AuthException('Usuário não autenticado');
      }

      final token = await _notificationService.getToken();
      if (token == null) {
        if (kDebugMode) {
          print('⚠️ Token de notificação não disponível');
        }
        return;
      }

      // Atualizar token no Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc('fcm_token')
          .set({
        'token': token,
        'platform': 'ios',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Token atualizado para usuário: ${user.uid}');
      }
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erro ao atualizar token: $e');
      }
      throw ServerException(
        'Erro ao atualizar token de notificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Método para obter todos os tokens de um usuário
  Future<List<String>> getUserTokens(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['token'] as String)
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erro ao obter tokens do usuário: $e');
      }
      throw ServerException(
        'Erro ao obter tokens do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Método para obter tokens de múltiplos usuários
  Future<List<String>> getMultipleUserTokens(List<String> userIds) async {
    try {
      final allTokens = <String>[];

      for (final userId in userIds) {
        final tokens = await getUserTokens(userId);
        allTokens.addAll(tokens);
      }

      return allTokens;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erro ao obter tokens de múltiplos usuários: $e');
      }
      throw ServerException(
        'Erro ao obter tokens de múltiplos usuários',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
