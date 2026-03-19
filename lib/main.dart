import 'dart:io';
import 'package:app/core/composition/bloc_factories.dart';
import 'package:app/core/email_templates/contract_flow_templates.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:app/core/users/data/datasources/users_local_datasource.dart';
import 'package:app/core/users/data/datasources/users_remote_datasource.dart';
import 'package:app/core/users/data/repositories/users_repository_impl.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_local_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/data/repositories/ensemble_availability_repository_impl.dart';
import 'package:app/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:app/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:app/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_local_datasource.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble/data/repositories/ensemble_repository_impl.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_incomplete_sections_usecase.dart';
import 'package:app/features/favorites/data/datasources/favorite_local_datasource.dart';
import 'package:app/features/favorites/data/datasources/favorite_remote_datasource.dart';
import 'package:app/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:app/features/contracts/data/datasources/contracts_functions.dart';
import 'package:app/features/contracts/data/datasources/contract_local_datasource.dart';
import 'package:app/features/contracts/data/datasources/contract_remote_datasource.dart';
import 'package:app/features/contracts/data/repositories/contract_repository_impl.dart';
import 'package:app/core/services/mercado_pago_service.dart';
import 'package:app/features/contracts/presentation/bloc/contract_paying_cubit.dart';
import 'package:app/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:app/features/artists/artist_availability/data/datasources/availability_local_datasource.dart';
import 'package:app/features/artists/artist_availability/data/datasources/availability_remote_datasource.dart';
import 'package:app/features/artists/artist_availability/data/repositories/availability_repository_impl.dart';
import 'package:app/features/artists/artist_bank_account/data/datasources/bank_account_local_datasource.dart';
import 'package:app/features/artists/artist_bank_account/data/datasources/bank_account_remote_datasource.dart';
import 'package:app/features/artists/artist_bank_account/data/repositories/bank_account_repository_impl.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/save_bank_account_usecase.dart';
import 'package:app/features/artists/artist_documents/data/datasources/documents_local_datasource.dart';
import 'package:app/features/artists/artist_documents/data/datasources/documents_remote_datasource.dart';
import 'package:app/features/artists/artist_documents/data/repositories/documents_repository_impl.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/artists/artists/data/datasources/artists_local_datasource.dart';
import 'package:app/features/artists/artists/data/datasources/artists_remote_datasource.dart';
import 'package:app/features/artists/artists/data/repositories/artists_repository_impl.dart';
import 'package:app/features/artists/artists/domain/usecases/check_artist_completeness_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_completeness_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_incomplete_sections_usecase.dart';
import 'package:app/features/clients/data/datasources/clients_local_datasource.dart';
import 'package:app/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:app/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:app/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/core/config/setup_locator.dart';
import 'package:app/core/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:app/core/config/auto_router_config.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// Authentication imports
import 'package:app/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Artists imports
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';

// Users imports
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/core/services/storage_service.dart';

// AppLists imports
import 'package:app/features/app_lists/data/datasources/app_lists_local_datasource.dart';
import 'package:app/features/app_lists/data/datasources/app_lists_remote_datasource.dart';
import 'package:app/features/app_lists/data/repositories/app_lists_repository_impl.dart';

// AppContent imports
import 'package:app/features/app_content/data/datasources/app_content_local_datasource.dart';
import 'package:app/features/app_content/data/datasources/app_content_remote_datasource.dart';
import 'package:app/features/app_content/data/repositories/app_content_repository_impl.dart';

// Support (atendimento) imports
import 'package:app/features/support/data/datasources/support_remote_datasource.dart';
import 'package:app/features/support/data/repositories/support_repository_impl.dart';
import 'package:app/core/services/mail_services.dart';


Future <void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // Carregar .env antes de qualquer serviço que use variáveis de ambiente (ex.: MailService SMTP).
  await dotenv.load(fileName: '.env');
  tz_data.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configurar Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // Em debug: usa debug provider para evitar 403 "App attestation failed" (simulador/debug).
    // Em release: usa App Attest. Registrar token de debug no Firebase Console > App Check quando em debug.
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );
  
  await AutoCacheInitializer.initialize(
    configuration: CacheConfiguration(
      sizeOptions: CacheSizeOptions(
      ),
      // cryptographyOptions: CacheCryptographyOptions(),
      dataCacheOptions: DataCacheOptions(
      )
    ),
  );
  setupLocator();

  // Logo dos e-mails (templates de contrato)
  await initShowtimeLogoFromAsset();
  
  //Services
  final authServices = getIt<IAuthServices>();
  final firestore = getIt<FirebaseFirestore>();
  final localCacheService = getIt<ILocalCacheService>();
  final biometricService = getIt<IBiometricAuthService>();
  final storageService = getIt<IStorageService>();
  final firebaseFunctionsService = getIt<IFirebaseFunctionsService>();
  final contractsFunctionsService = getIt<IContractsFunctionsService>();
  final mercadoPagoService = getIt<MercadoPagoService>();
  final mailService = getIt<MailService>();

  final appRouter = AppRouter();

  // Authentication
  final authLocalDataSource = AuthLocalDataSourceImpl(autoCacheService: localCacheService);
  final authRepository = AuthRepositoryImpl(localDataSource: authLocalDataSource);
  final getUserUidUseCase = GetUserUidUseCase(repository: authRepository, authServices: authServices);

  // Users
  final usersLocalDataSource = UsersLocalDataSourceImpl(autoCacheService: localCacheService);
  final usersRemoteDataSource = UsersRemoteDataSourceImpl(firestore: firestore);
  final usersRepository = UsersRepositoryImpl(localDataSource: usersLocalDataSource, remoteDataSource: usersRemoteDataSource);

  // GetUserDataUseCase
  final getUserDataUseCase = GetUserDataUseCase(usersRepository: usersRepository);

  // Artists
  final artistsLocalDataSource = ArtistsLocalDataSourceImpl(autoCacheService: localCacheService);
  final artistsRemoteDataSource = ArtistsRemoteDataSourceImpl(firestore: firestore);
  final artistsRepository = ArtistsRepositoryImpl(localDataSource: artistsLocalDataSource, remoteDataSource: artistsRemoteDataSource);

  // Clients
  final clientsLocalDataSource = ClientsLocalDataSourceImpl(autoCacheService: localCacheService);
  final clientsRemoteDataSource = ClientsRemoteDataSourceImpl(firestore: firestore);
  final clientsRepository = ClientsRepositoryImpl(localDataSource: clientsLocalDataSource, remoteDataSource: clientsRemoteDataSource);

  // Documents
  final documentsLocalDataSource = DocumentsLocalDataSourceImpl(autoCacheService: localCacheService);
  final documentsRemoteDataSource = DocumentsRemoteDataSourceImpl(firestore: firestore);
  final documentsRepository = DocumentsRepositoryImpl(localDataSource: documentsLocalDataSource, remoteDataSource: documentsRemoteDataSource);

  // Availability
  final availabilityLocalDataSource = AvailabilityLocalDataSourceImpl(localCacheService: localCacheService);
  final availabilityRemoteDataSource = AvailabilityRemoteDataSourceImpl(firestore: firestore);
  final availabilityRepository = AvailabilityRepositoryImpl(localDataSource: availabilityLocalDataSource, remoteDataSource: availabilityRemoteDataSource);

  // BankAccount
  final bankAccountLocalDataSource = BankAccountLocalDataSourceImpl(autoCacheService: localCacheService);
  final bankAccountRemoteDataSource = BankAccountRemoteDataSourceImpl(firestore: firestore);
  final bankAccountRepository = BankAccountRepositoryImpl(localDataSource: bankAccountLocalDataSource, remoteDataSource: bankAccountRemoteDataSource);
  final checkArtistCompletenessUseCase = CheckArtistCompletenessUseCase();

  // SyncArtistCompletenessIfChangedUseCase
  final syncArtistCompletenessIfChangedUseCase = SyncArtistCompletenessIfChangedUseCase(
    getArtistCompletenessUseCase: GetArtistCompletenessUseCase(
      getArtistUseCase: GetArtistUseCase(repository: artistsRepository),
      documentsRepository: documentsRepository,
      bankAccountRepository: bankAccountRepository,
      getUserUidUseCase: getUserUidUseCase,
      checkArtistCompletenessUseCase: checkArtistCompletenessUseCase,
    ),
    updateArtistIncompleteSectionsUseCase: UpdateArtistIncompleteSectionsUseCase(
      getArtistUseCase: GetArtistUseCase(repository: artistsRepository),
      repository: artistsRepository,
    ),
    getArtistUseCase: GetArtistUseCase(repository: artistsRepository),
    getUserUidUseCase: getUserUidUseCase,
  );

  // SaveBankAccountUseCase
  final saveBankAccountUseCase = SaveBankAccountUseCase(repository: bankAccountRepository, syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase);

  // Explore
  final exploreLocalDataSource = ExploreLocalDataSourceImpl(autoCacheService: localCacheService);
  final exploreRemoteDataSource = ExploreRemoteDataSourceImpl(firestore: firestore);
  final exploreRepository = ExploreRepositoryImpl(
    exploreRemoteDataSource: exploreRemoteDataSource,
    exploreLocalDataSource: exploreLocalDataSource,
  );

  // Ensemble (conjuntos)
  final ensembleLocalDataSource = EnsembleLocalDataSourceImpl(localCacheService: localCacheService);
  final ensembleRemoteDataSource = EnsembleRemoteDataSourceImpl(firestore: firestore);
  final ensembleRepository = EnsembleRepositoryImpl(
    remoteDataSource: ensembleRemoteDataSource,
    localDataSource: ensembleLocalDataSource,
  );

  // Ensemble Members (integrantes)
  // final membersLocalDataSource = MembersLocalDataSourceImpl(localCacheService: localCacheService);
  // final membersRemoteDataSource = MembersRemoteDataSourceImpl(firestore: firestore);
  // final membersRepository = MembersRepositoryImpl(
  //   remoteDataSource: membersRemoteDataSource,
  //   localDataSource: membersLocalDataSource,
  // );

  // Member Documents (documentos do integrante)
  // final memberDocumentsLocalDataSource = MemberDocumentsLocalDataSourceImpl(localCacheService: localCacheService);
  // final memberDocumentsRemoteDataSource = MemberDocumentsRemoteDataSourceImpl(firestore: firestore);
  // final memberDocumentsRepository = MemberDocumentsRepositoryImpl(
  //   localDataSource: memberDocumentsLocalDataSource,
  //   remoteDataSource: memberDocumentsRemoteDataSource,
  // );

  // Ensemble Availability
  final ensembleAvailabilityLocalDataSource = EnsembleAvailabilityLocalDataSourceImpl(localCacheService: localCacheService);
  final ensembleAvailabilityRemoteDataSource = EnsembleAvailabilityRemoteDataSourceImpl(firestore: firestore);
  final ensembleAvailabilityRepository = EnsembleAvailabilityRepositoryImpl(localDataSource: ensembleAvailabilityLocalDataSource, remoteDataSource: ensembleAvailabilityRemoteDataSource);

  // Sync Ensemble Completeness If Changed UseCase
  
  // final getAllMemberDocumentsUseCase = GetAllMemberDocumentsUseCase(repository: memberDocumentsRepository);
  final checkEnsembleCompletenessUseCase = CheckEnsembleCompletenessUseCase();
  final getEnsembleUseCase = GetEnsembleUseCase(repository: ensembleRepository);
  final updateEnsembleIncompleteSectionsUseCase = UpdateEnsembleIncompleteSectionsUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    repository: ensembleRepository,
  );
  final getEnsembleCompletenessUseCase = GetEnsembleCompletenessUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    documentsRepository: documentsRepository,
    bankAccountRepository: bankAccountRepository,
    checkEnsembleCompletenessUseCase: checkEnsembleCompletenessUseCase,
  );
  final syncEnsembleCompletenessIfChangedUseCase = SyncEnsembleCompletenessIfChangedUseCase(
    getEnsembleCompletenessUseCase: getEnsembleCompletenessUseCase,
    getEnsembleUseCase: getEnsembleUseCase,
    updateEnsembleIncompleteSectionsUseCase: updateEnsembleIncompleteSectionsUseCase,
  );

  // CalculateAddressGeohashUseCase (compartilhado entre Addresses e Explore)
  final calculateAddressGeohashUseCase = CalculateAddressGeohashUseCase();

  // Contracts
  final contractLocalDataSource = ContractLocalDataSourceImpl(autoCacheService: localCacheService);
  final contractRemoteDataSource = ContractRemoteDataSourceImpl(
    firestore: firestore,
    firebaseFunctionsService: firebaseFunctionsService,
  );
  final contractRepository = ContractRepositoryImpl(
    localDataSource: contractLocalDataSource,
    remoteDataSource: contractRemoteDataSource,
  );


  // Favorites
  final favoriteLocalDataSource = FavoriteLocalDataSourceImpl(autoCache: localCacheService);
  final favoriteRemoteDataSource = FavoriteRemoteDataSourceImpl(firestore: firestore);
  final favoriteRepository = FavoriteRepositoryImpl(localDataSource: favoriteLocalDataSource, remoteDataSource: favoriteRemoteDataSource);

  // AppLists
  final appListsLocalDataSource = AppListsLocalDataSourceImpl(autoCacheService: localCacheService);
  final appListsRemoteDataSource = AppListsRemoteDataSourceImpl(firestore: firestore);
  final appListsRepository = AppListsRepositoryImpl(
    localDataSource: appListsLocalDataSource,
    remoteDataSource: appListsRemoteDataSource,
  );

  // AppContent
  final appContentLocalDataSource = AppContentLocalDataSourceImpl(autoCacheService: localCacheService);
  final appContentRemoteDataSource = AppContentRemoteDataSourceImpl(firestore: firestore);
  final appContentRepository = AppContentRepositoryImpl(
    localDataSource: appContentLocalDataSource,
    remoteDataSource: appContentRemoteDataSource,
  );

  // Chat
  final chatLocalDataSource = ChatLocalDataSourceImpl(autoCache: localCacheService);
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(firestore: firestore);
  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
    localDataSource: chatLocalDataSource,
  );

  // Support (atendimento)
  final supportRemoteDataSource = SupportRemoteDataSourceImpl(firestore: firestore);
  final supportRepository = SupportRepositoryImpl(
    remoteDataSource: supportRemoteDataSource,
  );

  runApp(MultiBlocProvider(
        providers: [
          // BLoCs
          BlocProvider(
            create: (context) => createAuthBloc(
              authServices, 
              biometricService, 
              localCacheService, 
              firestore, 
              authRepository,
              usersRepository,
              artistsRepository,
              clientsRepository,
              saveBankAccountUseCase, 
              syncArtistCompletenessIfChangedUseCase,
              contractRepository,
            ),
          ),
          BlocProvider(
            create: (context) => createAddressesBloc(
              localCacheService, 
              firestore, 
              getUserUidUseCase,
              calculateAddressGeohashUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createClientsBloc(
              clientsRepository,
              getUserUidUseCase,
              storageService,
            ),
          ),
          BlocProvider(
            create: (context) => createArtistsBloc(
              artistsRepository,
              getUserUidUseCase,
              storageService,
              saveBankAccountUseCase,
              getUserDataUseCase,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createUsersBloc(
              usersRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createDocumentsBloc(
              documentsRepository,
              getUserUidUseCase,
              storageService,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createAvailabilityBloc(
              availabilityRepository, 
              getUserUidUseCase,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createBankAccountBloc(
              bankAccountRepository,
              getUserUidUseCase,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createExploreBloc(
              exploreRepository,
              calculateAddressGeohashUseCase,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createRequestAvailabilitiesBloc(
              exploreRepository,
              calculateAddressGeohashUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createContractsBloc(
              contractRepository,
              getUserUidUseCase,
              contractsFunctionsService,
              mercadoPagoService,
              ensembleRepository,
              getUserDataUseCase,
              mailService,
            ),
          ),
          BlocProvider(
            create: (context) => ContractPayingCubit(),
          ),
          BlocProvider(
            create: (context) => createPendingContractsCountBloc(
              contractRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createFavoritesBloc(
              favoriteRepository,
              exploreRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createEnsembleBloc(
              ensembleRepository,
              storageService,
              getUserUidUseCase,
              syncEnsembleCompletenessIfChangedUseCase,
            ),
          ),
          // BlocProvider(
          //   create: (context) => createMembersBloc(
          //     membersRepository,
          //     ensembleRepository,
          //     usersRepository,
          //     getUserUidUseCase,
          //     documentsRepository,
          //     bankAccountRepository,
          //     memberDocumentsRepository,
          //   ),
          // ),
          // BlocProvider(
          //   create: (context) => createMemberDocumentsBloc(
          //     memberDocumentsRepository,
          //     getUserUidUseCase,
          //     storageService,
          //     syncEnsembleCompletenessIfChangedUseCase,
          //   ),
          // ),
          BlocProvider(
            create: (context) => createEnsembleAvailabilityBloc(
              ensembleAvailabilityRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createAppListsBloc(
              appListsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => createAppContentBloc(
              appContentRepository,
            ),
          ),
          BlocProvider(
            create: (context) => createSupportBloc(
              supportRepository,
              getUserUidUseCase,
              getUserDataUseCase,
              mailService,
            ),
          ),
          BlocProvider(
            create: (context) => createChatsListBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createMessagesBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createUnreadCountBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => createArtistDashboardBloc(
              artistsRepository,
              contractRepository,
              getUserUidUseCase,
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
    );
  }
}
