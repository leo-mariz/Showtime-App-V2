import 'package:app/core/errors/failure.dart' as domain;
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/features/authentication/domain/usecases/check_user_logged_in_usecase.dart';
import 'package:app/features/authentication/domain/usecases/disable_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:app/features/authentication/domain/usecases/login_with_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:app/features/authentication/domain/usecases/register_email_password_usecase.dart';
import 'package:app/features/authentication/domain/usecases/register_onboarding_usecase.dart';
import 'package:app/features/authentication/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:app/features/authentication/domain/usecases/enable_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_should_show_biometrics_prompt_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_biometrics_enabled_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/resend_email_verification_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_new_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/reauthenticate_user_usecase.dart';
import 'package:app/features/profile/shared/domain/usecases/switch_to_artist_usecase.dart';
import 'package:app/features/profile/shared/domain/usecases/switch_to_client_usecase.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckUserLoggedInUseCase checkUserLoggedInUseCase;
  final RegisterEmailPasswordUseCase registerEmailPasswordUseCase;
  final RegisterOnboardingUseCase registerOnboardingUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final EnableBiometricsUseCase enableBiometricsUseCase;
  final LoginWithBiometricsUseCase loginWithBiometricsUseCase;
  final DisableBiometricsUseCase disableBiometricsUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckShouldShowBiometricsPromptUseCase checkShouldShowBiometricsPromptUseCase;
  final CheckBiometricsEnabledUseCase checkBiometricsEnabledUseCase;
  final CheckEmailVerifiedUseCase checkEmailVerifiedUseCase;
  final ResendEmailVerificationUseCase resendEmailVerificationUseCase;
  final CheckNewEmailVerifiedUseCase checkNewEmailVerifiedUseCase;
  final ReauthenticateUserUseCase reauthenticateUserUseCase;
  final SwitchToArtistUseCase switchToArtistUseCase;
  final SwitchToClientUseCase switchToClientUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkUserLoggedInUseCase,
    required this.registerEmailPasswordUseCase,
    required this.registerOnboardingUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.enableBiometricsUseCase,
    required this.loginWithBiometricsUseCase,
    required this.disableBiometricsUseCase,
    required this.logoutUseCase,
    required this.checkShouldShowBiometricsPromptUseCase,
    required this.checkBiometricsEnabledUseCase,
    required this.checkEmailVerifiedUseCase,
    required this.resendEmailVerificationUseCase,
    required this.checkNewEmailVerifiedUseCase,
    required this.reauthenticateUserUseCase,
    required this.switchToArtistUseCase,
    required this.switchToClientUseCase,
  }) : super(AuthInitial()) {
    on<RegisterUserEmailAndPasswordEvent>(_onRegisterUserEmailAndPasswordEvent);
    on<LoginUserEvent>(_onLoginUserEvent);
    on<RegisterUserOnboardingEvent>(_onRegisterUserOnboardingEvent);
    on<SendForgotPasswordEmailEvent>(_onSendForgotPasswordEmailEvent);
    
    on<CheckUserLoggedInEvent>(_onCheckUserLoggedInEvent);

    on<EnableBiometricsEvent>(_onEnableBiometricsEvent);
    on<LoginWithBiometricsEvent>(_onLoginWithBiometricsEvent);

    on<DisableBiometricsEvent>(_onDisableBiometricsEvent);
    on<UserLogoutEvent>(_onLogoutEvent);
    
    on<CheckShouldShowBiometricsPromptEvent>(_onCheckShouldShowBiometricsPromptEvent);
    on<CheckBiometricsEnabledEvent>(_onCheckBiometricsEnabledEvent);
    on<CheckEmailVerifiedEvent>(_onCheckEmailVerifiedEvent);
    on<ResendEmailVerificationEvent>(_onResendEmailVerificationEvent);
    on<CheckNewEmailVerifiedEvent>(_onCheckNewEmailVerifiedEvent);
    on<ReauthenticateUserEvent>(_onReauthenticateUserEvent);
    on<SwitchUserTypeEvent>(_onSwitchUserTypeEvent);
    on<ResetAuthEvent>(_onResetAuthEvent);
  }

  Future<void> _onRegisterUserEmailAndPasswordEvent(
    RegisterUserEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RegisterLoading());
    
    final result = await registerEmailPasswordUseCase.call(event.user);
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        if (failure is domain.NetworkFailure) {
          emit(AuthConnectionFailure(message: failure.message));
        } else {
          emit(AuthFailure(error: failure.message));
        }
        emit(AuthInitial());
      },
      (uid) {
        emit(AuthSuccess(
          message: 'Usuário registrado com sucesso',
        ));
        emit(AuthInitial());
      },
    );
  }
 
  Future<void> _onLoginUserEvent(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    
    final result = await loginUseCase.call(event.user);
    
    // Extrair failure ou sucesso
    final failure = result.fold(
      (l) => l,
      (r) => null,
    );
    
    if (failure != null) {
      // Verificar se é erro de perfil incompatível
      final isProfileMismatch = failure.message.contains('não possui perfil de') ||
          failure.message.contains('selecione o tipo de conta correto');
      
      if (isProfileMismatch) {
        // Fazer logout imediato para não deixar sessão aberta
        await logoutUseCase.call();
        emit(AuthProfileMismatch(error: failure.message));
      } else if (failure is domain.NetworkFailure) {
        emit(AuthConnectionFailure(message: failure.message));
      } else if (failure is domain.IncompleteDataFailure) {
        // Verificar se é especificamente email não verificado
        final isEmailNotVerified = failure.missingFields?.contains('emailVerification') ?? false;
        
        if (isEmailNotVerified) {
          // Emitir estado específico para email não verificado
          emit(EmailNotVerified(email: event.user.email));
        } else {
          // Outros dados incompletos (ex: CPF/CNPJ)
          emit(AuthDataIncomplete(message: failure.message));
        }
      } else {
        emit(AuthFailure(error: failure.message));
      }
      emit(AuthInitial());
    } else {
      // Login bem-sucedido
      emit(LoginSuccess(user: event.user));
      await _checkAndShowBiometricsPrompt(event.user, emit);
      emit(AuthInitial());
    }
  }

  Future<void> _checkAndShowBiometricsPrompt(
    UserEntity user,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    final result = await checkShouldShowBiometricsPromptUseCase.call();
    
    result.fold(
      (failure) {
        // Em caso de erro, não mostrar prompt
        emit(CheckShouldShowBiometricsPromptSuccess(
          shouldShow: false,
          user: null,
        ));
      },
      (shouldShow) {
        emit(CheckShouldShowBiometricsPromptSuccess(
          shouldShow: shouldShow,
          user: shouldShow ? user : null,
        ));
      },
    );
  }

  Future<void> _onRegisterUserOnboardingEvent(
    RegisterUserOnboardingEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RegisterOnboardingLoading());
    
    final result = await registerOnboardingUseCase.call(event.register);
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        emit(AuthFailure(error: failure.message));
        emit(AuthInitial());
      },
      (_) {
        emit(AuthSuccess(message: 'Usuário registrado com sucesso'));
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onSendForgotPasswordEmailEvent(
    SendForgotPasswordEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    
    final result = await sendPasswordResetEmailUseCase.call(event.email);

    result.fold(
      // Mensagem user-friendly já vem do failure
      (failure) => emit(ForgotPasswordFailure(error: failure.message)),
      (_) {
        emit(ForgotPasswordSuccess(message: "Email enviado com sucesso"));
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onCheckUserLoggedInEvent(
    CheckUserLoggedInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckUserLoggedInLoading());
    
    final result = await checkUserLoggedInUseCase.call();
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        emit(AuthFailure(error: failure.message));
        emit(AuthInitial());
      },
      (response) {
        emit(CheckUserLoggedInSuccess(
          isLoggedIn: response.isLoggedIn,
          isArtist: response.isArtist,
        ));
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onEnableBiometricsEvent(
    EnableBiometricsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(EnableBiometricsLoading());
    
    final result = await enableBiometricsUseCase.call(event.user);
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        emit(AuthFailure(error: failure.message));
        emit(AuthInitial());
      },
      (biometricsResult) {
        final user = event.user;
        
        // Mensagens user-friendly para cada resultado
        if (biometricsResult == BiometricsResult.enableFailed) {
          emit(AuthFailure(error: 'Biometria incorreta'));
        } else if (biometricsResult == BiometricsResult.disabledSuccessfully) {
          emit(AuthSuccess(user: user, message: 'Biometria desabilitada pelo usuário'));
        } else if (biometricsResult == BiometricsResult.enabledSuccessfully) {
          emit(AuthSuccess(user: user, message: 'Biometria habilitada com sucesso'));
        } else if (biometricsResult == BiometricsResult.alreadyEnabled) {
          emit(AuthSuccess(user: user, message: 'Biometria já habilitada'));
        } else if (biometricsResult == BiometricsResult.notAvailable) {
          emit(AuthSuccess(user: user, message: 'Biometria não disponível'));
        }
        
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onLoginWithBiometricsEvent(
    LoginWithBiometricsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    
    try {
    final result = await loginWithBiometricsUseCase.call();
    
    result.fold(
      (failure) {
          // Qualquer falha no fluxo de biometria deve redirecionar para LoginScreen
        // Mensagem user-friendly já vem do failure, com fallback
        final message = failure is domain.AuthFailure 
            ? failure.message 
            : 'Erro ao autenticar com biometria. Por favor, faça login com email e senha.';
        
        emit(BiometricFailure(message));
        emit(AuthInitial());
      },
      (isArtist) {
          // APENAS se tudo der certo, emitir sucesso
        emit(LoginWithBiometricsSuccess(isArtist: isArtist));
        emit(AuthInitial());
      },
    );
    } catch (e) {
      // Em caso de exceção inesperada, também redirecionar para LoginScreen
      emit(BiometricFailure('Erro ao autenticar com biometria. Por favor, faça login com email e senha.'));
      emit(AuthInitial());
    }
  }

  Future<void> _onDisableBiometricsEvent(
    DisableBiometricsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LogoutLoading());
    
    final result = await disableBiometricsUseCase.call();
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        emit(AuthFailure(error: failure.message));
        emit(AuthInitial());
      },
      (_) {
        emit(AuthSuccess(message: 'Biometria desabilitada com sucesso'));
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onLogoutEvent(
    UserLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LogoutLoading());
    
    final result = await logoutUseCase.call(
      resetBiometrics: event.resetBiometrics ?? false,
    );
    
    result.fold(
      (failure) {
        // Mensagem user-friendly já vem do failure
        emit(AuthFailure(error: failure.message));
        emit(AuthInitial());
      },
      (_) {
        emit(AuthLoggedOut());
      },
    );
  }

  Future<void> _onCheckShouldShowBiometricsPromptEvent(
    CheckShouldShowBiometricsPromptEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(InitialLoading());
    final result = await checkShouldShowBiometricsPromptUseCase.call();
    
    result.fold(
      (failure) {
        // Em caso de erro, não mostrar prompt
        emit(CheckShouldShowBiometricsPromptSuccess(
          shouldShow: false,
          user: null,
        ));
        emit(AuthInitial());
      },
      (shouldShow) {
        // Este evento não tem user, então não podemos mostrar o prompt
        // Este handler é mantido para compatibilidade, mas o fluxo principal
        // é através do _checkAndShowBiometricsPrompt após login
        emit(CheckShouldShowBiometricsPromptSuccess(
          shouldShow: shouldShow,
          user: null,
        ));
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onCheckBiometricsEnabledEvent(
    CheckBiometricsEnabledEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(InitialLoading());

    final result = await checkBiometricsEnabledUseCase.call();
    result.fold(
      (failure) {
        // Em caso de erro, considerar como não habilitada
        emit(CheckBiometricsEnabledSuccess(isEnabled: false));
        emit(AuthInitial());
      },
      (isEnabled) {
        emit(CheckBiometricsEnabledSuccess(isEnabled: isEnabled));
        emit(AuthInitial());
      },
    );
  }

  // ==================== CHECK EMAIL VERIFIED ====================

  Future<void> _onCheckEmailVerifiedEvent(
    CheckEmailVerifiedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckEmailVerifiedLoading());

    final result = await checkEmailVerifiedUseCase.call();

    result.fold(
      (failure) {
        emit(CheckEmailVerifiedFailure(error: failure.message));
        emit(AuthInitial());
      },
      (isVerified) {
        emit(CheckEmailVerifiedSuccess(isVerified: isVerified));
        emit(AuthInitial());
      },
    );
  }

  // ==================== RESEND EMAIL VERIFICATION ====================

  Future<void> _onResendEmailVerificationEvent(
    ResendEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResendEmailVerificationLoading());

    final result = await resendEmailVerificationUseCase.call();

    result.fold(
      (failure) {
        emit(ResendEmailVerificationFailure(error: failure.message));
        emit(AuthInitial());
      },
      (_) {
        emit(ResendEmailVerificationSuccess(
          message: 'E-mail de verificação reenviado!',
        ));
        emit(AuthInitial());
      },
    );
  }

  // ==================== CHECK NEW EMAIL VERIFIED ====================

  Future<void> _onCheckNewEmailVerifiedEvent(
    CheckNewEmailVerifiedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckNewEmailVerifiedLoading());

    final result = await checkNewEmailVerifiedUseCase.call(event.newEmail);

    result.fold(
      (failure) {
        emit(CheckNewEmailVerifiedFailure(error: failure.message));
        emit(AuthInitial());
      },
      (isVerified) {
        emit(CheckNewEmailVerifiedSuccess(isVerified: isVerified));
        emit(AuthInitial());
      },
    );
  }

  // ==================== REAUTHENTICATE USER ====================

  Future<void> _onReauthenticateUserEvent(
    ReauthenticateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ReauthenticateUserLoading());

    // Se password é null, tenta biometria primeiro
    final tryBiometrics = event.password == null;
    
    final result = await reauthenticateUserUseCase.call(
      tryBiometrics: tryBiometrics,
      password: event.password,
    );

    result.fold(
      (failure) {
        // Se é ValidationFailure, significa que biometria falhou e precisa de senha
        if (failure is domain.ValidationFailure) {
          emit(ReauthenticateUserBiometricFailure(error: failure.message));
        } else {
          // Outros erros (AuthFailure, etc) são falhas de senha
          emit(ReauthenticateUserPasswordFailure(error: failure.message));
        }
        emit(AuthInitial());
      },
      (_) {
        emit(ReauthenticateUserSuccess());
        emit(AuthInitial());
      },
    );
  }

  // ==================== SWITCH USER TYPE ====================

  Future<void> _onSwitchUserTypeEvent(
    SwitchUserTypeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(SwitchUserTypeLoading());

    // Chamar o UseCase apropriado baseado no bool
    final result = event.switchToArtist
        ? await switchToArtistUseCase.call()
        : await switchToClientUseCase.call();

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🔴 [AuthBloc] SwitchUserType failure: ${failure.runtimeType} - ${failure.message}');
        }
        emit(SwitchUserTypeFailure(error: failure.message));
        emit(AuthInitial());
      },
      (profileExists) {
        if (kDebugMode) {
          debugPrint('🟢 [AuthBloc] SwitchUserType success, profileExists=$profileExists, switchToArtist=${event.switchToArtist}');
        }
        if (profileExists) {
          emit(SwitchUserTypeSuccess(isArtist: event.switchToArtist));
        } else {
          emit(SwitchUserTypeNeedsCreation(switchToArtist: event.switchToArtist));
        }
        emit(AuthInitial());
      },
    );
  }

  // ==================== RESET ====================

  /// Reseta o AuthBloc ao estado inicial
  void _onResetAuthEvent(
    ResetAuthEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
