import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';


abstract class IBiometricAuthService {
  Future<bool> isDeviceSupported();
  Future<bool> canCheckBiometrics();
  Future<bool> isBiometricsAvailable();
  Future<bool> isBiometricsEnabled();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticateWithBiometrics();
  Future<void> enableBiometrics(String email, String password, bool isArtist);
  Future<Map<String, String>?> getCredentials();
  Future<void> disableBiometrics();
}


class BiometricAuthServiceImpl implements IBiometricAuthService{
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;
  
  BiometricAuthServiceImpl({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Verifica se o dispositivo suporta biometria
  @override
  Future<bool> isDeviceSupported() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isDeviceSupported;
    } catch (e) {
      // Em caso de erro (ex: emulador sem biometria), retornar false
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      // Em caso de erro (ex: emulador sem biometria), retornar false
      return false;
    }
  }

  @override
  Future<bool> isBiometricsAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      // Biometria está disponível se o dispositivo suporta E pode verificar biometria
      final bool canAuthenticate = canAuthenticateWithBiometrics && isDeviceSupported;
      return canAuthenticate;
    } catch (e) {
      // Em caso de erro (ex: emulador sem biometria configurada), retornar false
      return false;
    }
  }

  // Verifica se o usuário já habilitou biometria
  @override
  Future<bool> isBiometricsEnabled() async {
    try {
      final storedCredentials = await _secureStorage.read(key: SecureStorageKeys.credentials);
      final isEnabled = storedCredentials != null;
      return isEnabled;
    } catch (e) {
      // Em caso de erro ao ler storage, considerar como não habilitado
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }

  // Autentica com biometria e retorna as credenciais salvas
  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Adicione sua biometria para fazer login.',
            cancelButton: 'Cancelar',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
          ),
        ],
      );
      return didAuthenticate;
    } catch (e) {
      // Em caso de exceção, considerar como falha
      return false;
    }
  }

  // Salva as credenciais de forma segura
  @override
  Future<void> enableBiometrics(String email, String password, bool isArtist) async {
    final credentials = {
      SecureStorageKeys.email: email,
      SecureStorageKeys.password: password,
      SecureStorageKeys.isArtist: isArtist.toString(),
    };
    
    await _secureStorage.write(
      key: SecureStorageKeys.credentials,
      value: json.encode(credentials),
    );
  }
  
  @override
  Future<Map<String, String>?> getCredentials() async {
    final storedCredentials = await _secureStorage.read(key: SecureStorageKeys.credentials);
    if (storedCredentials != null) {
      return Map<String, String>.from(json.decode(storedCredentials));
    }
    return null;
  }

  // Desabilita a biometria
  @override
  Future<void> disableBiometrics() async {
    await _secureStorage.delete(key: SecureStorageKeys.credentials);
  }
}

enum BiometricsResult {
  notAvailable,
  alreadyEnabled,
  enabledSuccessfully,
  disabledSuccessfully,
  enableFailed,
  notEnabled,
  incorrectBiometrics,
  verifiedSuccessfully,
}

class SecureStorageKeys {
  static const String credentials = 'credentials';
  static const String email = 'email';
  static const String password = 'password';
  static const String isArtist = 'isArtist';
}
