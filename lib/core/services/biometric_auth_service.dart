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
    try {
    return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      // Em caso de erro, retornar lista vazia
      return [];
    }
  }

  // Autentica com biometria e retorna as credenciais salvas
  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      // Verificar se há biometria disponível no dispositivo
      final availableBiometrics = await getAvailableBiometrics();
      final hasBiometrics = availableBiometrics.isNotEmpty;
      
      // Se houver biometria disponível, tentar primeiro apenas com biometria
      // Isso força o Face ID/Touch ID no iOS e evita mostrar PIN primeiro
      if (hasBiometrics) {
        try {
          final bool didAuthenticate = await _localAuth.authenticate(
            localizedReason: 'Autentique-se para entrar',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true, // Forçar apenas biometria quando disponível
              useErrorDialogs: true,
            ),
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'Autentique-se com biometria',
                cancelButton: 'Cancelar',
                biometricHint: '',
                biometricNotRecognized: 'Biometria não reconhecida',
                biometricSuccess: 'Biometria reconhecida',
                deviceCredentialsRequiredTitle: 'Credenciais do dispositivo necessárias',
                deviceCredentialsSetupDescription: 'Configure credenciais do dispositivo',
              ),
              IOSAuthMessages(
                cancelButton: 'Cancelar',
                goToSettingsButton: 'Ir para Configurações',
                goToSettingsDescription: 'Por favor, configure biometria',
                lockOut: 'Biometria bloqueada. Use senha do dispositivo.',
              ),
            ],
          );
          return didAuthenticate;
        } catch (e) {
          // Se falhar com biometricOnly: true, pode ser porque o usuário cancelou
          // ou porque após várias tentativas falhas, o sistema bloqueou
          // Neste caso, retornar false (o sistema já mostrou o erro apropriado)
          return false;
        }
      } else {
        // Se não houver biometria disponível, permitir PIN/senha como fallback
    final bool didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Autentique-se para entrar',
      options: const AuthenticationOptions(
        stickyAuth: true,
            biometricOnly: false, // Permitir PIN/senha quando não há biometria
        useErrorDialogs: true,
      ),
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
              signInTitle: 'Autentique-se',
          cancelButton: 'Cancelar',
        ),
        IOSAuthMessages(
          cancelButton: 'Cancelar',
        ),
      ],
    );
    return didAuthenticate;
      }
    } catch (e) {
      // Em caso de exceção, considerar como falha
      return false;
    }
  }

  // Salva as credenciais de forma segura
  @override
  Future<void> enableBiometrics(String email, String password, bool isArtist) async {
    try {
    final credentials = {
      SecureStorageKeys.email: email,
      SecureStorageKeys.password: password,
      SecureStorageKeys.isArtist: isArtist.toString(),
    };
    
    await _secureStorage.write(
      key: SecureStorageKeys.credentials,
      value: json.encode(credentials),
    );
    } catch (e) {
      // Re-lançar exceção para que o use case possa tratar adequadamente
      rethrow;
    }
  }
  
  @override
  Future<Map<String, String>?> getCredentials() async {
    try {
    final storedCredentials = await _secureStorage.read(key: SecureStorageKeys.credentials);
    if (storedCredentials != null) {
        try {
      return Map<String, String>.from(json.decode(storedCredentials));
        } catch (e) {
          // Erro ao decodificar JSON - credenciais corrompidas
          // Limpar credenciais inválidas
          try {
            await _secureStorage.delete(key: SecureStorageKeys.credentials);
          } catch (_) {
            // Ignora erro ao deletar
    }
    return null;
        }
      }
      return null;
    } catch (e) {
      // Erro ao ler do secure storage
      return null;
    }
  }

  // Desabilita a biometria
  @override
  Future<void> disableBiometrics() async {
    try {
    await _secureStorage.delete(key: SecureStorageKeys.credentials);
    } catch (e) {
      // Ignora erro ao deletar (pode não existir)
      // Não re-lança para não quebrar o fluxo
    }
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
