import 'package:app/core/errors/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class IAuthServices {
  Future<UserCredential> registerEmailAndPassword(String email, String password);
  Future<UserCredential> loginUser(String email, String password);
  Future<void> reauthenticateUser(String email, String password);
  Future<void> verifyBeforeUpdateUserEmail(String email);
  Future<void> updateUserPassword(String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent);
  Future<UserCredential> signInWithSmsCode(String verificationId, String smsCode);
  Future<void> sendSignInLinkToEmail(String email);
  Future<UserCredential> signInWithEmailLink(String email, String link);
  Future<bool> isUserLoggedIn();
  Future<String?> getUserUid();
  Future<bool> isEmailVerified();
  Future<void> deleteAccount();
  Future<void> logout();
}

class FirebaseAuthServicesImpl implements IAuthServices {
  final FirebaseAuth firebaseAuth;
  final _auth = FirebaseAuth.instance;

  FirebaseAuthServicesImpl({required this.firebaseAuth});

  @override
  Future<UserCredential> registerEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao registrar usuário: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao registrar usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserCredential> loginUser(String email, String password) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // FirebaseAuthException é tratada pelo ErrorHandler
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao fazer login',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }


  @override
  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw const AuthException('Usuário não autenticado');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await currentUser.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao reautenticar: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao reautenticar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> verifyBeforeUpdateUserEmail(String email) async {
    try {
      await firebaseAuth.currentUser?.verifyBeforeUpdateEmail(email);
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        e.code == 'email-already-in-use' 
            ? 'O novo e-mail já está em uso. Por favor, tente outro e-mail'
            : 'Erro ao atualizar email: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateUserPassword(String password) async {
    try {
      await firebaseAuth.currentUser?.updatePassword(password);
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao atualizar senha: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar senha',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao enviar email de redefinição de senha: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao enviar email de redefinição',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao enviar email de verificação: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao enviar email de verificação',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent) async {
    try {
      if (kDebugMode) {
        print('📱 AuthService: Iniciando verificação de telefone: $phoneNumber');
      }
      
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('📱 AuthService: Verificação automática completada');
          }
          await firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('❌ AuthService: Verificação falhou: ${e.code} - ${e.message}');
            print('❌ AuthService: Stack trace: ${StackTrace.current}');
          }
          throw AuthException(
            'Erro na verificação de telefone: ${e.message}',
            code: e.code,
            originalError: e,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('✅ AuthService: Código enviado com sucesso');
            print('✅ AuthService: VerificationId: $verificationId');
            print('✅ AuthService: ResendToken: $resendToken');
          }
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('⏰ AuthService: Timeout do código automático: $verificationId');
          }
        },
        // Configurações para evitar redirecionamento
        forceResendingToken: null,
        timeout: Duration(seconds: 60),
      );
      
      if (kDebugMode) {
        print('📱 AuthService: verifyPhoneNumber executado com sucesso');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ AuthService: Erro ao enviar SMS: $e');
        print('❌ AuthService: Stack trace: $stackTrace');
      }
      throw ServerException(
        'Erro ao enviar SMS',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserCredential> signInWithSmsCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      if (kDebugMode) {
        print('📱 AuthService: Verificando código SMS: $smsCode');
      }
      
      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ AuthService: Erro ao verificar código SMS: $e');
      }
      throw AuthException(
        'Erro ao verificar código SMS: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao verificar código SMS',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://yourapp.page.link/verify',
        handleCodeInApp: true,
        iOSBundleId: 'com.yourapp.ios',
        androidPackageName: 'com.yourapp.android',
        androidInstallApp: true,
      );
      
      await firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao enviar link: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao enviar link',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserCredential> signInWithEmailLink(String email, String link) async {
    try {
      return await firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao fazer login com link: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao fazer login com link',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final user = firebaseAuth.currentUser;
    return user != null;
  }

  @override
  Future<String?> getUserUid() async {
    try {
      final user = firebaseAuth.currentUser;
      return user?.uid;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao obter UID do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      return user?.emailVerified ?? false;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar se email está verificado',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao deletar conta: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao deletar conta',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        'Erro ao fazer logout: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao fazer logout',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}