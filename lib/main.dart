import 'dart:io';
import 'package:app/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/core/config/setup_locator.dart';
import 'package:app/core/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:app/core/config/auto_router_config.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// Authentication imports
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/data/datasources/users_remote_datasource.dart';
import 'package:app/features/authentication/data/datasources/users_local_datasource.dart';
import 'package:app/features/authentication/data/repositories/users_repository_impl.dart';
import 'package:app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_user_logged_in_usecase.dart';
import 'package:app/features/authentication/domain/usecases/register_email_password_usecase.dart';
import 'package:app/features/authentication/domain/usecases/register_onboarding_usecase.dart';
import 'package:app/features/authentication/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:app/features/authentication/domain/usecases/enable_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/login_with_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/disable_biometrics_usecase.dart';
import 'package:app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:app/features/authentication/domain/usecases/send_welcome_email_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_cpf_exists_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_cnpj_exists_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_should_show_biometrics_prompt_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_biometrics_enabled_usecase.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Factory function para criar o AuthBloc com todas as dependências
AuthBloc _createAuthBloc(IAuthServices authServices, IBiometricAuthService biometricService, ILocalCacheService localCacheService, FirebaseFirestore firestore) {

  // 3. Criar DataSources
  final remoteDataSource = AuthRemoteDataSourceImpl(firestore: firestore);
  final localDataSource = AuthLocalDataSourceImpl(autoCacheService: localCacheService);

  // 4. Criar Repository
  final repository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  // 5. Criar UseCases
  final loginUseCase = LoginUseCase(
    repository: repository,
    authServices: authServices,
  );
  final checkUserLoggedInUseCase = CheckUserLoggedInUseCase(
    repository: repository,
    authServices: authServices,
  );
  final registerEmailPasswordUseCase = RegisterEmailPasswordUseCase(
    repository: repository,
    authServices: authServices,
  );
  final sendWelcomeEmailUsecase = SendWelcomeEmailUsecase();
  final registerOnboardingUseCase = RegisterOnboardingUseCase(
    repository: repository,
    authServices: authServices,
    sendWelcomeEmailUsecase: sendWelcomeEmailUsecase,
  );
  final sendPasswordResetEmailUseCase = SendPasswordResetEmailUseCase(
    authServices: authServices,
  );
  final enableBiometricsUseCase = EnableBiometricsUseCase(
    repository: repository,
    authServices: authServices,
    biometricService: biometricService,
  );
  final loginWithBiometricsUseCase = LoginWithBiometricsUseCase(
    biometricService: biometricService,
    loginUseCase: loginUseCase,
  );
  final disableBiometricsUseCase = DisableBiometricsUseCase(
    biometricService: biometricService,
  );

  final logoutUseCase = LogoutUseCase(
    repository: repository,
    authServices: authServices,
    biometricService: biometricService,
  );

  final checkCpfExistsUseCase = CheckCpfExistsUseCase(
    repository: repository,
  );

  final checkCnpjExistsUseCase = CheckCnpjExistsUseCase(
    repository: repository,
  );

  final checkShouldShowBiometricsPromptUseCase = CheckShouldShowBiometricsPromptUseCase(
    biometricService: biometricService,
  );

  final checkBiometricsEnabledUseCase = CheckBiometricsEnabledUseCase(
    biometricService: biometricService,
  );

  // 6. Criar e retornar AuthBloc
  return AuthBloc(
    loginUseCase: loginUseCase,
    checkUserLoggedInUseCase: checkUserLoggedInUseCase,
    registerEmailPasswordUseCase: registerEmailPasswordUseCase,
    registerOnboardingUseCase: registerOnboardingUseCase,
    sendPasswordResetEmailUseCase: sendPasswordResetEmailUseCase,
    enableBiometricsUseCase: enableBiometricsUseCase,
    loginWithBiometricsUseCase: loginWithBiometricsUseCase,
    disableBiometricsUseCase: disableBiometricsUseCase,
    logoutUseCase: logoutUseCase,
    checkCpfExistsUseCase: checkCpfExistsUseCase,
    checkCnpjExistsUseCase: checkCnpjExistsUseCase,
    checkShouldShowBiometricsPromptUseCase: checkShouldShowBiometricsPromptUseCase,
    checkBiometricsEnabledUseCase: checkBiometricsEnabledUseCase,
  );
}

Future <void> main() async {

  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AutoCacheInitializer.initialize();
  setupLocator();

  //Services
  final authServices = getIt<IAuthServices>();
  final firestore = getIt<FirebaseFirestore>();
  final localCacheService = getIt<ILocalCacheService>();
  final biometricService = getIt<IBiometricAuthService>();

  final appRouter = AppRouter();

  // Criar AuthBloc
  final authBloc = _createAuthBloc(authServices, biometricService, localCacheService, firestore);

  runApp(MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: MyApp(appRouter: appRouter),
      ),
    );
}


class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {

    final platformTheme = Platform.isIOS ? AppThemes.iosDarkTheme : AppThemes.androidDarkTheme;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Showtime',
      theme: platformTheme,
      themeMode: ThemeMode.dark,
      darkTheme: platformTheme,
      routerConfig: appRouter.config(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // builder: (context, child) {
      //   return NotificationOverlay(
      //     child: child ?? const SizedBox.shrink(),
      //   );
      // },
    );
  }
}
