import 'dart:io';
import 'package:app/core/users/data/datasources/users_local_datasource.dart';
import 'package:app/core/users/data/datasources/users_remote_datasource.dart';
import 'package:app/core/users/data/repositories/users_repository_impl.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/data/datasources/artists_local_datasource.dart';
import 'package:app/features/profile/artists/data/datasources/artists_remote_datasource.dart';
import 'package:app/features/profile/artists/data/repositories/artists_repository_impl.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/profile/clients/data/datasources/clients_local_datasource.dart';
import 'package:app/features/profile/clients/data/datasources/clients_remote_datasource.dart';
import 'package:app/features/profile/clients/data/repositories/clients_repository_impl.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
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
import 'package:app/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:app/features/authentication/data/repositories/auth_repository_impl.dart';
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
import 'package:app/core/users/domain/usecases/check_cpf_exists_usecase.dart';
import 'package:app/core/users/domain/usecases/check_cnpj_exists_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_should_show_biometrics_prompt_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_biometrics_enabled_usecase.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Addresses imports
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/data/datasources/addresses_remote_datasource.dart';
import 'package:app/features/addresses/data/datasources/addresses_local_datasource.dart';
import 'package:app/features/addresses/data/repositories/addresses_repository_impl.dart';
import 'package:app/features/addresses/domain/usecases/get_addresses_usecase.dart';
import 'package:app/features/addresses/domain/usecases/get_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/add_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/update_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/delete_address_usecase.dart';
import 'package:app/features/addresses/domain/usecases/set_primary_address_usecase.dart';

/// Factory function para criar o AuthBloc com todas as dependências
AuthBloc _createAuthBloc(IAuthServices authServices, 
                          IBiometricAuthService biometricService, 
                          ILocalCacheService localCacheService, 
                          FirebaseFirestore firestore, 
                          IAuthRepository authRepository, 
                          IUsersRepository usersRepository, 
                          IArtistsRepository artistsRepository, 
                          IClientsRepository clientsRepository) {

  // 5. Criar UseCases
  final loginUseCase = LoginUseCase(
    usersRepository: usersRepository,
    artistsRepository: artistsRepository,
    clientsRepository: clientsRepository,
    authRepository: authRepository,
    authServices: authServices,
  );
  final checkUserLoggedInUseCase = CheckUserLoggedInUseCase(
    authRepository: authRepository,
    clientsRepository: clientsRepository,
    artistsRepository: artistsRepository,
    authServices: authServices,
  );
  final registerEmailPasswordUseCase = RegisterEmailPasswordUseCase(
    usersRepository: usersRepository,
    authServices: authServices,
  );
  final sendWelcomeEmailUsecase = SendWelcomeEmailUsecase();
  final registerOnboardingUseCase = RegisterOnboardingUseCase(
    authRepository: authRepository,
    usersRepository: usersRepository,
    artistsRepository: artistsRepository,
    clientsRepository: clientsRepository,
    authServices: authServices,
    sendWelcomeEmailUsecase: sendWelcomeEmailUsecase,
  );
  final sendPasswordResetEmailUseCase = SendPasswordResetEmailUseCase(
    authServices: authServices,
  );
  final enableBiometricsUseCase = EnableBiometricsUseCase(
    authRepository: authRepository,
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
    authRepository: authRepository,
    authServices: authServices,
    biometricService: biometricService,
  );

  final checkCpfExistsUseCase = CheckCpfExistsUseCase(
    usersRepository: usersRepository,
  );

  final checkCnpjExistsUseCase = CheckCnpjExistsUseCase(
    usersRepository: usersRepository,
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

/// Factory function para criar o AddressesBloc com todas as dependências
AddressesBloc _createAddressesBloc(ILocalCacheService localCacheService, FirebaseFirestore firestore, GetUserUidUseCase getUserUidUseCase) {
  // 1. Criar DataSources
  final remoteDataSource = AddressesRemoteDataSourceImpl(firestore: firestore);
  final localDataSource = AddressesLocalDataSourceImpl(autoCacheService: localCacheService);

  // 2. Criar Repository
  final repository = AddressesRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  // 3. Criar UseCases
  final getAddressesUseCase = GetAddressesUseCase(repository: repository);
  final getAddressUseCase = GetAddressUseCase(repository: repository);
  final addAddressUseCase = AddAddressUseCase(repository: repository);
  final updateAddressUseCase = UpdateAddressUseCase(repository: repository);
  final deleteAddressUseCase = DeleteAddressUseCase(repository: repository);
  final setPrimaryAddressUseCase = SetPrimaryAddressUseCase(repository: repository);

  // 4. Criar e retornar AddressesBloc
  return AddressesBloc(
    getAddressesUseCase: getAddressesUseCase,
    getAddressUseCase: getAddressUseCase,
    addAddressUseCase: addAddressUseCase,
    updateAddressUseCase: updateAddressUseCase,
    deleteAddressUseCase: deleteAddressUseCase,
    setPrimaryAddressUseCase: setPrimaryAddressUseCase,
    getUserUidUseCase: getUserUidUseCase,
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

  // Authentication
  final authLocalDataSource = AuthLocalDataSourceImpl(autoCacheService: localCacheService);
  final authRepository = AuthRepositoryImpl(localDataSource: authLocalDataSource);
  final getUserUidUseCase = GetUserUidUseCase(repository: authRepository, authServices: authServices);

  // Users
  final usersLocalDataSource = UsersLocalDataSourceImpl(autoCacheService: localCacheService);
  final usersRemoteDataSource = UsersRemoteDataSourceImpl(firestore: firestore);
  final usersRepository = UsersRepositoryImpl(localDataSource: usersLocalDataSource, remoteDataSource: usersRemoteDataSource);

  // Artists
  final artistsLocalDataSource = ArtistsLocalDataSourceImpl(autoCacheService: localCacheService);
  final artistsRemoteDataSource = ArtistsRemoteDataSourceImpl(firestore: firestore);
  final artistsRepository = ArtistsRepositoryImpl(localDataSource: artistsLocalDataSource, remoteDataSource: artistsRemoteDataSource);

  // Clients
  final clientsLocalDataSource = ClientsLocalDataSourceImpl(autoCacheService: localCacheService);
  final clientsRemoteDataSource = ClientsRemoteDataSourceImpl(firestore: firestore);
  final clientsRepository = ClientsRepositoryImpl(localDataSource: clientsLocalDataSource, remoteDataSource: clientsRemoteDataSource);

  runApp(MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => _createAuthBloc(
              authServices, 
              biometricService, 
              localCacheService, 
              firestore, 
              authRepository,
              usersRepository,
              artistsRepository,
              clientsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => _createAddressesBloc(
              localCacheService, 
              firestore, 
              getUserUidUseCase
          ),
        ),
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
