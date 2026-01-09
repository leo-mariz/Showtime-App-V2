import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:app/core/services/user_notification_service.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/core/services/image_cache_service.dart';
import 'package:app/core/services/cep_service.dart';
import 'package:app/core/services/biometric_auth_service.dart';
import 'package:app/core/services/app_notification_service.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Services
  getIt.registerLazySingleton<IAuthServices>(
    () => FirebaseAuthServicesImpl(firebaseAuth: FirebaseAuth.instance),
  );

  getIt.registerLazySingleton<ILocalCacheService>(
    () => AutoCacheServiceImplementation(),
  );
  
  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(),
  );  
  
  getIt.registerLazySingleton<IUserNotificationService>(
    () => UserNotificationService(),
  );
  
  getIt.registerLazySingleton<IImageCacheService>(
    () => ImageCacheService(),
  );
  
  getIt.registerLazySingleton<ICepService>(
    () => CepServiceImpl(),
  );
  
  getIt.registerLazySingleton<IBiometricAuthService>(
    () => BiometricAuthServiceImpl(),
  );
  
  getIt.registerLazySingleton<IAppNotificationService>(
    () => AppNotificationServiceImpl(),
  );
  
  getIt.registerLazySingleton<IStorageService>(
    () => StorageService(),
  );
  
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  
  getIt.registerLazySingleton<IFirebaseFunctionsService>(
    () => FirebaseFunctionsService(),
  );
}