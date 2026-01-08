import 'dart:io';
import 'package:app/core/users/data/datasources/users_local_datasource.dart';
import 'package:app/core/users/data/datasources/users_remote_datasource.dart';
import 'package:app/core/users/data/repositories/users_repository_impl.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_local_datasource.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_remote_datasource.dart';
import 'package:app/features/profile/artist_availability/data/repositories/availability_repository_impl.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:app/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:app/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/is_availability_valid_for_date_usecase.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/contracts/data/datasources/contract_local_datasource.dart';
import 'package:app/features/contracts/data/datasources/contract_remote_datasource.dart';
import 'package:app/features/contracts/data/repositories/contract_repository_impl.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/features/contracts/domain/usecases/add_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/delete_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_group_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/add_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/check_availability_overlap_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/close_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/delete_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availabilities_usecase.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/update_availability_usecase.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_bank_account/data/datasources/bank_account_local_datasource.dart';
import 'package:app/features/profile/artist_bank_account/data/datasources/bank_account_remote_datasource.dart';
import 'package:app/features/profile/artist_bank_account/data/repositories/bank_account_repository_impl.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/profile/artist_bank_account/domain/usecases/delete_bank_account_usecase.dart';
import 'package:app/features/profile/artist_bank_account/domain/usecases/get_bank_account_usecase.dart';
import 'package:app/features/profile/artist_bank_account/domain/usecases/save_bank_account_usecase.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/bank_account_bloc.dart';
import 'package:app/features/profile/artist_documents/data/datasources/documents_local_datasource.dart';
import 'package:app/features/profile/artist_documents/data/datasources/documents_remote_datasource.dart';
import 'package:app/features/profile/artist_documents/data/repositories/documents_repository_impl.dart';
import 'package:app/features/profile/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/profile/artist_documents/domain/usecases/get_documents_usecase.dart';
import 'package:app/features/profile/artist_documents/domain/usecases/set_document_usecase.dart';
import 'package:app/features/profile/artist_documents/presentation/bloc/documents_bloc.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:app/features/authentication/domain/usecases/check_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_new_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/authentication/domain/usecases/reauthenticate_user_usecase.dart';
import 'package:app/features/authentication/domain/usecases/resend_email_verification_usecase.dart';
import 'package:app/features/profile/artists/data/datasources/artists_local_datasource.dart';
import 'package:app/features/profile/artists/data/datasources/artists_remote_datasource.dart';
import 'package:app/features/profile/artists/data/repositories/artists_repository_impl.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/profile/artists/domain/usecases/add_artist_usecase.dart';
import 'package:app/features/profile/artists/groups/data/datasources/groups_local_datasource.dart';
import 'package:app/features/profile/artists/groups/data/datasources/groups_remote_datasource.dart';
import 'package:app/features/profile/artists/groups/data/repositories/groups_repository_impl.dart';
import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
import 'package:app/features/profile/artists/groups/domain/usecases/add_group_usecase.dart';
import 'package:app/features/profile/artists/groups/domain/usecases/delete_group_usecase.dart';
import 'package:app/features/profile/artists/groups/domain/usecases/get_group_usecase.dart';
import 'package:app/features/profile/artists/groups/domain/usecases/get_groups_usecase.dart';
import 'package:app/features/profile/artists/groups/domain/usecases/update_group_usecase.dart';
import 'package:app/features/profile/artists/groups/presentation/bloc/groups_bloc.dart';
import 'package:app/features/profile/clients/data/datasources/clients_local_datasource.dart';
import 'package:app/features/profile/clients/data/datasources/clients_remote_datasource.dart';
import 'package:app/features/profile/clients/data/repositories/clients_repository_impl.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
import 'package:app/features/profile/clients/domain/usecases/add_client_usecase.dart';
import 'package:app/features/profile/shared/domain/usecases/switch_to_artist_usecase.dart';
import 'package:app/features/profile/shared/domain/usecases/switch_to_client_usecase.dart';
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

// Clients imports
import 'package:app/features/profile/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/profile/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_preferences_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_profile_picture_usecase.dart';
import 'package:app/features/profile/clients/domain/usecases/update_client_agreement_usecase.dart';

// Artists imports
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_profile_picture_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_name_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_professional_info_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_agreement_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_presentation_medias_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/check_artist_name_exists_usecase.dart';

// Users imports
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/domain/usecases/get_user_data_usecase.dart';
import 'package:app/core/services/storage_service.dart';

// AppLists imports
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/data/datasources/app_lists_local_datasource.dart';
import 'package:app/features/app_lists/data/datasources/app_lists_remote_datasource.dart';
import 'package:app/features/app_lists/data/repositories/app_lists_repository_impl.dart';
import 'package:app/features/app_lists/domain/repositories/app_lists_repository.dart';
import 'package:app/features/app_lists/domain/usecases/get_specialties_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_talents_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_event_types_usecase.dart';
import 'package:app/features/app_lists/domain/usecases/get_support_subjects_usecase.dart';


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

  final checkShouldShowBiometricsPromptUseCase = CheckShouldShowBiometricsPromptUseCase(
    biometricService: biometricService,
  );

  final checkBiometricsEnabledUseCase = CheckBiometricsEnabledUseCase(
    biometricService: biometricService,
  );

  final checkEmailVerifiedUseCase = CheckEmailVerifiedUseCase(
    authServices: authServices,
  );

  final resendEmailVerificationUseCase = ResendEmailVerificationUseCase(
    authServices: authServices,
  );

  final checkNewEmailVerifiedUseCase = CheckNewEmailVerifiedUseCase(
    authServices: authServices,
  );

  final getUserUidUseCase = GetUserUidUseCase(
    repository: authRepository,
    authServices: authServices,
  );

  final getUserDataUseCase = GetUserDataUseCase(
    usersRepository: usersRepository,
  );

  final reauthenticateUserUseCase = ReauthenticateUserUseCase(
    authServices: authServices,
    biometricService: biometricService,
    getUserUidUseCase: getUserUidUseCase,
    getUserDataUseCase: getUserDataUseCase,
  );

  final getArtistUseCase = GetArtistUseCase(repository: artistsRepository);
  final getClientUseCase = GetClientUseCase(repository: clientsRepository);

  final switchToArtistUseCase = SwitchToArtistUseCase(
    getUserUidUseCase: getUserUidUseCase,
    getArtistUseCase: getArtistUseCase,
  );
  final switchToClientUseCase = SwitchToClientUseCase(
    getUserUidUseCase: getUserUidUseCase,
    getClientUseCase: getClientUseCase,
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
    checkShouldShowBiometricsPromptUseCase: checkShouldShowBiometricsPromptUseCase,
    checkBiometricsEnabledUseCase: checkBiometricsEnabledUseCase,
    checkEmailVerifiedUseCase: checkEmailVerifiedUseCase,
    resendEmailVerificationUseCase: resendEmailVerificationUseCase,
    checkNewEmailVerifiedUseCase: checkNewEmailVerifiedUseCase,
    reauthenticateUserUseCase: reauthenticateUserUseCase,
    switchToArtistUseCase: switchToArtistUseCase,
    switchToClientUseCase: switchToClientUseCase,
  );
}

/// Factory function para criar o AddressesBloc com todas as dependências
AddressesBloc _createAddressesBloc(
  ILocalCacheService localCacheService,
  FirebaseFirestore firestore,
  GetUserUidUseCase getUserUidUseCase,
  CalculateAddressGeohashUseCase calculateAddressGeohashUseCase,
) {
  // 1. Criar DataSources
  final remoteDataSource = AddressesRemoteDataSourceImpl(firestore: firestore);
  final localDataSource = AddressesLocalDataSourceImpl(autoCacheService: localCacheService);

  // 2. Criar Repository
  final repository = AddressesRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  // 3. Criar UseCases
  // Nota: calculateAddressGeohashUseCase é criado no escopo principal e passado como parâmetro
  final getAddressesUseCase = GetAddressesUseCase(repository: repository);
  final getAddressUseCase = GetAddressUseCase(repository: repository);
  final addAddressUseCase = AddAddressUseCase(repository: repository, calculateAddressGeohashUseCase: calculateAddressGeohashUseCase);
  final updateAddressUseCase = UpdateAddressUseCase(repository: repository, calculateAddressGeohashUseCase: calculateAddressGeohashUseCase);
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

/// Factory function para criar o ClientsBloc com todas as dependências
ClientsBloc _createClientsBloc(
  IClientsRepository clientsRepository,
  GetUserUidUseCase getUserUidUseCase,
  IStorageService storageService,
) {
  // Criar UseCases
  final getClientUseCase = GetClientUseCase(repository: clientsRepository);
  final updateClientUseCase = UpdateClientUseCase(repository: clientsRepository);
  final updateClientPreferencesUseCase = UpdateClientPreferencesUseCase(
    getClientUseCase: getClientUseCase,
    updateClientUseCase: updateClientUseCase,
  );
  final updateClientProfilePictureUseCase = UpdateClientProfilePictureUseCase(
    getClientUseCase: getClientUseCase,
    updateClientUseCase: updateClientUseCase,
    storageService: storageService,
  );
  final updateClientAgreementUseCase = UpdateClientAgreementUseCase(
    getClientUseCase: getClientUseCase,
    updateClientUseCase: updateClientUseCase,
  );
  final addClientUseCase = AddClientUseCase(repository: clientsRepository);

  // Criar e retornar ClientsBloc
  return ClientsBloc(
    getClientUseCase: getClientUseCase,
    addClientUseCase: addClientUseCase,
    updateClientUseCase: updateClientUseCase,
    updateClientPreferencesUseCase: updateClientPreferencesUseCase,
    updateClientProfilePictureUseCase: updateClientProfilePictureUseCase,
    updateClientAgreementUseCase: updateClientAgreementUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o UsersBloc com todas as dependências
UsersBloc _createUsersBloc(
  IUsersRepository usersRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final getUserDataUseCase = GetUserDataUseCase(usersRepository: usersRepository);
  final checkCpfExistsUseCase = CheckCpfExistsUseCase(usersRepository: usersRepository);
  final checkCnpjExistsUseCase = CheckCnpjExistsUseCase(usersRepository: usersRepository);

  // Criar e retornar UsersBloc
  return UsersBloc(
    getUserDataUseCase: getUserDataUseCase,
    getUserUidUseCase: getUserUidUseCase,
    checkCpfExistsUseCase: checkCpfExistsUseCase,
    checkCnpjExistsUseCase: checkCnpjExistsUseCase,
  );
}

/// Factory function para criar o ArtistsBloc com todas as dependências
ArtistsBloc _createArtistsBloc(
  IArtistsRepository artistsRepository,
  GetUserUidUseCase getUserUidUseCase,
  IStorageService storageService,
) {
  // Criar UseCases
  final getArtistUseCase = GetArtistUseCase(repository: artistsRepository);
  final updateArtistUseCase = UpdateArtistUseCase(repository: artistsRepository);
  final updateArtistProfilePictureUseCase = UpdateArtistProfilePictureUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    storageService: storageService,
  );
  final checkArtistNameExistsUseCase = CheckArtistNameExistsUseCase(
    repository: artistsRepository,
  );
  final updateArtistNameUseCase = UpdateArtistNameUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    checkArtistNameExistsUseCase: checkArtistNameExistsUseCase,
  );
  final updateArtistProfessionalInfoUseCase = UpdateArtistProfessionalInfoUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
  );
  final updateArtistAgreementUseCase = UpdateArtistAgreementUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
  );
  final updateArtistPresentationMediasUseCase = UpdateArtistPresentationMediasUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    storageService: storageService,
  );
  final addArtistUseCase = AddArtistUseCase(repository: artistsRepository); 

  // Criar e retornar ArtistsBloc
  return ArtistsBloc(
    getArtistUseCase: getArtistUseCase,
    addArtistUseCase: addArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    updateArtistProfilePictureUseCase: updateArtistProfilePictureUseCase,
    updateArtistNameUseCase: updateArtistNameUseCase,
    updateArtistProfessionalInfoUseCase: updateArtistProfessionalInfoUseCase,
    updateArtistAgreementUseCase: updateArtistAgreementUseCase,
    updateArtistPresentationMediasUseCase: updateArtistPresentationMediasUseCase,
    checkArtistNameExistsUseCase: checkArtistNameExistsUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o DocumentsBloc com todas as dependências
DocumentsBloc _createDocumentsBloc(
  IDocumentsRepository documentsRepository,
  GetUserUidUseCase getUserUidUseCase,
  IStorageService storageService,
) {
  // 1. Criar DataSources

  // 3. Criar UseCases
  final getDocumentsUseCase = GetDocumentsUseCase(
    documentsRepository: documentsRepository,
    getUserUidUseCase: getUserUidUseCase,
  );
  final setDocumentUseCase = SetDocumentUseCase(
    documentsRepository: documentsRepository,
    storageService: storageService,
    getUserUidUseCase: getUserUidUseCase,
  );

  // 4. Criar e retornar DocumentsBloc
  return DocumentsBloc(
    getDocumentsUseCase: getDocumentsUseCase,
    setDocumentUseCase: setDocumentUseCase,
  );
}

/// Factory function para criar o GroupsBloc com todas as dependências
GroupsBloc _createGroupsBloc(
  IGroupsRepository groupsRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final getGroupsUseCase = GetGroupsUseCase(repository: groupsRepository);
  final getGroupUseCase = GetGroupUseCase(repository: groupsRepository);
  final addGroupUseCase = AddGroupUseCase(repository: groupsRepository);
  final updateGroupUseCase = UpdateGroupUseCase(repository: groupsRepository);
  final deleteGroupUseCase = DeleteGroupUseCase(repository: groupsRepository);

  // Criar e retornar GroupsBloc
  return GroupsBloc(
    getGroupsUseCase: getGroupsUseCase,
    getGroupUseCase: getGroupUseCase,
    addGroupUseCase: addGroupUseCase,
    updateGroupUseCase: updateGroupUseCase,
    deleteGroupUseCase: deleteGroupUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o AvailabilityBloc com todas as dependências
AvailabilityBloc _createAvailabilityBloc(
  IAvailabilityRepository availabilityRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCase para calcular Geohash
  
  // Criar UseCases
  final getAvailabilityUseCase = GetAvailabilitiesUseCase(availabilityRepository: availabilityRepository);
  final addAvailabilityUseCase = AddAvailabilityUseCase(
    availabilityRepository: availabilityRepository,
  );
  final updateAvailabilityUseCase = UpdateAvailabilityUseCase(
    repository: availabilityRepository,
  );
  final deleteAvailabilityUseCase = DeleteAvailabilityUseCase(availabilityRepository);
  final closeAvailabilityUseCase = CloseAvailabilityUseCase(availabilityRepository: availabilityRepository);
  final checkAvailabilityOverlapUseCase = CheckAvailabilityOverlapUseCase(availabilityRepository: availabilityRepository);

  // Criar e retornar AvailabilityBloc
  return AvailabilityBloc(
    getAvailabilitiesUseCase: getAvailabilityUseCase,
    addAvailabilityUseCase: addAvailabilityUseCase,
    updateAvailabilityUseCase: updateAvailabilityUseCase,
    deleteAvailabilityUseCase: deleteAvailabilityUseCase,
    closeAvailabilityUseCase: closeAvailabilityUseCase,
    checkAvailabilityOverlapUseCase: checkAvailabilityOverlapUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o BankAccountBloc com todas as dependências
BankAccountBloc _createBankAccountBloc(
  IBankAccountRepository bankAccountRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final getBankAccountUseCase = GetBankAccountUseCase(repository: bankAccountRepository);
  final saveBankAccountUseCase = SaveBankAccountUseCase(repository: bankAccountRepository);
  final deleteBankAccountUseCase = DeleteBankAccountUseCase(repository: bankAccountRepository);
  
  return BankAccountBloc(
    getBankAccountUseCase: getBankAccountUseCase,
    saveBankAccountUseCase: saveBankAccountUseCase,
    deleteBankAccountUseCase: deleteBankAccountUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o ExploreBloc com todas as dependências
ExploreBloc _createExploreBloc(
  IExploreRepository exploreRepository,
  CalculateAddressGeohashUseCase calculateAddressGeohashUseCase,
) {
  // Criar UseCase orquestrador de validações (usa helpers internamente)
  final isAvailabilityValidForDateUseCase = IsAvailabilityValidForDateUseCase();
  
  // Criar UseCases principais
  final getArtistsWithAvailabilitiesUseCase = GetArtistsWithAvailabilitiesUseCase(
    repository: exploreRepository,
  );
  
  final getArtistsWithAvailabilitiesFilteredUseCase =
      GetArtistsWithAvailabilitiesFilteredUseCase(
    getArtistsWithAvailabilitiesUseCase: getArtistsWithAvailabilitiesUseCase,
    calculateAddressGeohashUseCase: calculateAddressGeohashUseCase,
    isAvailabilityValidForDateUseCase: isAvailabilityValidForDateUseCase,
  );

  // Criar e retornar ExploreBloc
  return ExploreBloc(
    getArtistsWithAvailabilitiesUseCase: getArtistsWithAvailabilitiesUseCase,
    getArtistsWithAvailabilitiesFilteredUseCase:
        getArtistsWithAvailabilitiesFilteredUseCase,
  );
}

/// Factory function para criar o ContractsBloc com todas as dependências
ContractsBloc _createContractsBloc(
  IContractRepository contractRepository,
) {
  // Criar UseCases
  final getContractUseCase = GetContractUseCase(repository: contractRepository);
  final getContractsByClientUseCase = GetContractsByClientUseCase(repository: contractRepository);
  final getContractsByArtistUseCase = GetContractsByArtistUseCase(repository: contractRepository);
  final getContractsByGroupUseCase = GetContractsByGroupUseCase(repository: contractRepository);
  final addContractUseCase = AddContractUseCase(repository: contractRepository);
  final updateContractUseCase = UpdateContractUseCase(repository: contractRepository);
  final deleteContractUseCase = DeleteContractUseCase(repository: contractRepository);

  // Criar e retornar ContractsBloc
  return ContractsBloc(
    getContractUseCase: getContractUseCase,
    getContractsByClientUseCase: getContractsByClientUseCase,
    getContractsByArtistUseCase: getContractsByArtistUseCase,
    getContractsByGroupUseCase: getContractsByGroupUseCase,
    addContractUseCase: addContractUseCase,
    updateContractUseCase: updateContractUseCase,
    deleteContractUseCase: deleteContractUseCase,
  );
}

AppListsBloc _createAppListsBloc(
  IAppListsRepository appListsRepository,
) {
  // Criar UseCases
  final getSpecialtiesUseCase = GetSpecialtiesUseCase(repository: appListsRepository);
  final getTalentsUseCase = GetTalentsUseCase(repository: appListsRepository);
  final getEventTypesUseCase = GetEventTypesUseCase(repository: appListsRepository);
  final getSupportSubjectsUseCase = GetSupportSubjectsUseCase(repository: appListsRepository);

  // Criar e retornar AppListsBloc
  return AppListsBloc(
    getSpecialtiesUseCase: getSpecialtiesUseCase,
    getTalentsUseCase: getTalentsUseCase,
    getEventTypesUseCase: getEventTypesUseCase,
    getSupportSubjectsUseCase: getSupportSubjectsUseCase,
  );
}


Future <void> main() async {

  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configurar Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
        // your preferred provider. Choose from:
        // 1. Debug provider
        // 2. Device Check provider
        // 3. App Attest provider
         // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
     appleProvider: AppleProvider.debug, // Use debug para obter token de debug no Xcode
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
  
  //Services
  final authServices = getIt<IAuthServices>();
  final firestore = getIt<FirebaseFirestore>();
  final localCacheService = getIt<ILocalCacheService>();
  final biometricService = getIt<IBiometricAuthService>();
  final storageService = getIt<IStorageService>();

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


  // Documents
  final documentsLocalDataSource = DocumentsLocalDataSourceImpl(autoCacheService: localCacheService);
  final documentsRemoteDataSource = DocumentsRemoteDataSourceImpl(firestore: firestore);
  final documentsRepository = DocumentsRepositoryImpl(localDataSource: documentsLocalDataSource, remoteDataSource: documentsRemoteDataSource);

  // Groups
  final groupsLocalDataSource = GroupsLocalDataSourceImpl(autoCacheService: localCacheService);
  final groupsRemoteDataSource = GroupsRemoteDataSourceImpl(firestore: firestore);
  final groupsRepository = GroupsRepositoryImpl(localDataSource: groupsLocalDataSource, remoteDataSource: groupsRemoteDataSource);

  // Availability
  final availabilityLocalDataSource = AvailabilityLocalDataSourceImpl(autoCacheService: localCacheService);
  final availabilityRemoteDataSource = AvailabilityRemoteDataSourceImpl(firestore: firestore);
  final availabilityRepository = AvailabilityRepositoryImpl(localDataSource: availabilityLocalDataSource, remoteDataSource: availabilityRemoteDataSource);

  // BankAccount
  final bankAccountLocalDataSource = BankAccountLocalDataSourceImpl(autoCacheService: localCacheService);
  final bankAccountRemoteDataSource = BankAccountRemoteDataSourceImpl(firestore: firestore);
  final bankAccountRepository = BankAccountRepositoryImpl(localDataSource: bankAccountLocalDataSource, remoteDataSource: bankAccountRemoteDataSource);

  // Explore
  final exploreLocalDataSource = ExploreLocalDataSourceImpl(autoCacheService: localCacheService);
  final exploreRemoteDataSource = ExploreRemoteDataSourceImpl(firestore: firestore);
  final exploreRepository = ExploreRepositoryImpl(
    exploreRemoteDataSource: exploreRemoteDataSource,
    exploreLocalDataSource: exploreLocalDataSource,
  );

  // CalculateAddressGeohashUseCase (compartilhado entre Addresses e Explore)
  final calculateAddressGeohashUseCase = CalculateAddressGeohashUseCase();

  // Contracts
  final contractLocalDataSource = ContractLocalDataSourceImpl(autoCacheService: localCacheService);
  final contractRemoteDataSource = ContractRemoteDataSourceImpl(firestore: firestore);
  final contractRepository = ContractRepositoryImpl(
    localDataSource: contractLocalDataSource,
    remoteDataSource: contractRemoteDataSource,
  );

  // AppLists
  final appListsLocalDataSource = AppListsLocalDataSourceImpl(autoCacheService: localCacheService);
  final appListsRemoteDataSource = AppListsRemoteDataSourceImpl(firestore: firestore);
  final appListsRepository = AppListsRepositoryImpl(
    localDataSource: appListsLocalDataSource,
    remoteDataSource: appListsRemoteDataSource,
  );

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
              getUserUidUseCase,
              calculateAddressGeohashUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createClientsBloc(
              clientsRepository,
              getUserUidUseCase,
              storageService,
            ),
          ),
          BlocProvider(
            create: (context) => _createArtistsBloc(
              artistsRepository,
              getUserUidUseCase,
              storageService,
            ),
          ),
          BlocProvider(
            create: (context) => _createUsersBloc(
              usersRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createDocumentsBloc(
              documentsRepository,
              getUserUidUseCase,
              storageService,
            ),
          ),
          BlocProvider(
            create: (context) => _createGroupsBloc(
              groupsRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createAvailabilityBloc(
              availabilityRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createBankAccountBloc(
              bankAccountRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createExploreBloc(
              exploreRepository,
              calculateAddressGeohashUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createContractsBloc(
              contractRepository,
            ),
          ),
          BlocProvider(
            create: (context) => _createAppListsBloc(
              appListsRepository,
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
