import 'dart:io';
import 'package:app/core/services/firebase_functions_service.dart';
import 'package:app/core/users/data/datasources/users_local_datasource.dart';
import 'package:app/core/users/data/datasources/users_remote_datasource.dart';
import 'package:app/core/users/data/repositories/users_repository_impl.dart';
import 'package:app/core/users/domain/repositories/users_repository.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/artists/artist_dashboard/presentation/bloc/artist_dashboard_bloc.dart';
import 'package:app/features/contracts/domain/usecases/confirm_show_usecase.dart';
import 'package:app/features/contracts/domain/usecases/verify_payment_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_member_talents_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_members_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_presentation_video_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_professional_info_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_profile_photo_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_local_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/data/repositories/ensemble_availability_repository_impl.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/repositories/ensemble_availability_repository.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/create_availability_day_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/period/close_period_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/period/open_period_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/validation/get_organized_availabilities_after_verification_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/ensemble_availability_bloc.dart';
import 'package:app/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:app/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:app/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/explore/domain/usecases/get_artist_active_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_filtered_usecase.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_local_datasource.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble/data/repositories/ensemble_repository_impl.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_empty_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/create_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/delete_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_all_ensembles_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/check_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_completeness_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_active_status_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_incomplete_sections_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/members/data/datasources/members_local_datasource.dart';
import 'package:app/features/ensemble/members/data/datasources/members_remote_datasource.dart';
import 'package:app/features/ensemble/members/data/repositories/members_repository_impl.dart';
import 'package:app/features/ensemble/members/domain/repositories/members_repository.dart';
import 'package:app/features/ensemble/members/domain/usecases/create_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/delete_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/update_member_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_all_members_usecase.dart';
import 'package:app/features/ensemble/members/domain/usecases/get_member_usecase.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/member_documents/data/datasources/member_documents_local_datasource.dart';
import 'package:app/features/ensemble/member_documents/data/datasources/member_documents_remote_datasource.dart';
import 'package:app/features/ensemble/member_documents/data/repositories/member_documents_repository_impl.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/get_all_member_documents_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/get_member_document_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/usecases/save_member_document_usecase.dart';
import 'package:app/features/ensemble/member_documents/presentation/bloc/member_documents_bloc.dart';
import 'package:app/features/favorites/data/datasources/favorite_local_datasource.dart';
import 'package:app/features/favorites/data/datasources/favorite_remote_datasource.dart';
import 'package:app/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:app/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:app/features/favorites/domain/usecases/get_favorite_artists_usecase.dart';
import 'package:app/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/contracts/data/datasources/contract_local_datasource.dart';
import 'package:app/features/contracts/data/datasources/contract_remote_datasource.dart';
import 'package:app/features/contracts/data/repositories/contract_repository_impl.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:app/core/services/mercado_pago_service.dart';
import 'package:app/features/contracts/domain/usecases/accept_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/add_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/cancel_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/delete_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/get_contracts_by_group_usecase.dart';
import 'package:app/features/contracts/domain/usecases/make_payment_usecase.dart';
import 'package:app/features/contracts/domain/usecases/rate_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/rate_client_usecase.dart';
import 'package:app/features/contracts/domain/usecases/reject_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/skip_rating_artist_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:app/features/contracts/domain/usecases/update_contracts_index_usecase.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/pending_contracts_count_bloc.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_acceptance_rate_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_completed_events_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_monthly_earnings_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_monthly_stats_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_next_show_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_pending_requests_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/calculate_upcoming_events_usecase.dart';
import 'package:app/features/artists/artist_dashboard/domain/usecases/get_artist_dashboard_stats_usecase.dart';
import 'package:app/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:app/features/chat/domain/usecases/create_chat_usecase.dart';
import 'package:app/features/chat/domain/usecases/get_messages_paginated_usecase.dart';
import 'package:app/features/chat/domain/usecases/get_unread_count_usecase.dart';
import 'package:app/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:app/features/chat/domain/usecases/update_typing_status_usecase.dart';
import 'package:app/features/chat/presentation/bloc/chats_list/chats_list_bloc.dart';
import 'package:app/features/chat/presentation/bloc/messages/messages_bloc.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/unread_count_bloc.dart';
import 'package:app/features/artists/artist_availability/data/datasources/availability_local_datasource.dart';
import 'package:app/features/artists/artist_availability/data/datasources/availability_remote_datasource.dart';
import 'package:app/features/artists/artist_availability/data/repositories/availability_repository_impl.dart';
import 'package:app/features/artists/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/get_all_availabilities_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/create_availability_day_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/validation/get_organized_availabilities_after_verification_usecase.dart.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/period/open_period_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/period/close_period_usecase.dart';
import 'package:app/features/artists/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/artists/artist_bank_account/data/datasources/bank_account_local_datasource.dart';
import 'package:app/features/artists/artist_bank_account/data/datasources/bank_account_remote_datasource.dart';
import 'package:app/features/artists/artist_bank_account/data/repositories/bank_account_repository_impl.dart';
import 'package:app/features/artists/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/delete_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/get_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/domain/usecases/save_bank_account_usecase.dart';
import 'package:app/features/artists/artist_bank_account/presentation/bloc/bank_account_bloc.dart';
import 'package:app/features/artists/artist_documents/data/datasources/documents_local_datasource.dart';
import 'package:app/features/artists/artist_documents/data/datasources/documents_remote_datasource.dart';
import 'package:app/features/artists/artist_documents/data/repositories/documents_repository_impl.dart';
import 'package:app/features/artists/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/artists/artist_documents/domain/usecases/get_documents_usecase.dart';
import 'package:app/features/artists/artist_documents/domain/usecases/set_document_usecase.dart';
import 'package:app/features/artists/artist_documents/presentation/bloc/documents_bloc.dart';
import 'package:app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:app/features/authentication/domain/usecases/check_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/check_new_email_verified_usecase.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/authentication/domain/usecases/reauthenticate_user_usecase.dart';
import 'package:app/features/authentication/domain/usecases/resend_email_verification_usecase.dart';
import 'package:app/features/artists/artists/data/datasources/artists_local_datasource.dart';
import 'package:app/features/artists/artists/data/datasources/artists_remote_datasource.dart';
import 'package:app/features/artists/artists/data/repositories/artists_repository_impl.dart';
import 'package:app/features/artists/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/artists/artists/domain/usecases/add_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/check_artist_completeness_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_completeness_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_incomplete_sections_usecase.dart';
import 'package:app/features/clients/data/datasources/clients_local_datasource.dart';
import 'package:app/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:app/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:app/features/clients/domain/repositories/clients_repository.dart';
import 'package:app/features/clients/domain/usecases/add_client_usecase.dart';
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
import 'package:app/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:app/features/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_preferences_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_profile_picture_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_agreement_usecase.dart';

// Artists imports
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_profile_picture_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_name_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_professional_info_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_agreement_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_active_status_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_presentation_medias_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/check_artist_name_exists_usecase.dart';

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

// Support (atendimento) imports
import 'package:app/features/support/presentation/bloc/support_bloc.dart';
import 'package:app/features/support/data/datasources/support_remote_datasource.dart';
import 'package:app/features/support/data/repositories/support_repository_impl.dart';
import 'package:app/features/support/data/services/support_email_service_impl.dart';
import 'package:app/features/support/domain/repositories/support_repository.dart';
import 'package:app/features/support/domain/usecases/send_support_message_usecase.dart';
import 'package:app/core/services/mail_services.dart';


/// Factory function para criar o AuthBloc com todas as dependências
AuthBloc _createAuthBloc(IAuthServices authServices, 
                          IBiometricAuthService biometricService, 
                          ILocalCacheService localCacheService, 
                          FirebaseFirestore firestore, 
                          IAuthRepository authRepository, 
                          IUsersRepository usersRepository, 
                          IArtistsRepository artistsRepository, 
                          IClientsRepository clientsRepository,
                          SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase) {

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
    syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase,
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
  SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase,
) {
  // Criar UseCases
  final getArtistUseCase = GetArtistUseCase(repository: artistsRepository);
  final updateArtistUseCase = UpdateArtistUseCase(repository: artistsRepository);
  final updateArtistProfilePictureUseCase = UpdateArtistProfilePictureUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    storageService: storageService,
    syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase,
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
    syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase,
  );
  final updateArtistAgreementUseCase = UpdateArtistAgreementUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
  );
  final updateArtistActiveStatusUseCase = UpdateArtistActiveStatusUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
  );
  final updateArtistPresentationMediasUseCase = UpdateArtistPresentationMediasUseCase(
    getArtistUseCase: getArtistUseCase,
    updateArtistUseCase: updateArtistUseCase,
    storageService: storageService,
    syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase,
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
    updateArtistActiveStatusUseCase: updateArtistActiveStatusUseCase,
    checkArtistNameExistsUseCase: checkArtistNameExistsUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o DocumentsBloc com todas as dependências
DocumentsBloc _createDocumentsBloc(
  IDocumentsRepository documentsRepository,
  GetUserUidUseCase getUserUidUseCase,
  IStorageService storageService,
  SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase,
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
    syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase, 
  );

  // 4. Criar e retornar DocumentsBloc
  return DocumentsBloc(
    getDocumentsUseCase: getDocumentsUseCase,
    setDocumentUseCase: setDocumentUseCase,
  );
}

/// Factory function para criar o AvailabilityBloc com todas as dependências
AvailabilityBloc _createAvailabilityBloc(
  IAvailabilityRepository availabilityRepository,
  GetUserUidUseCase getUserUidUseCase,
  SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase,
) {
  // ════════════════════════════════════════════════════════════════
  // Criar Use Cases de Consulta
  // ════════════════════════════════════════════════════════════════
  final getAllAvailabilitiesUseCase = GetAllAvailabilitiesUseCase(
    repository: availabilityRepository,
  );
  
  final getAvailabilityByDateUseCase = GetAvailabilityByDateUseCase(
    repository: availabilityRepository,
  );

  // ════════════════════════════════════════════════════════════════
  // Criar Use Cases de Disponibilidade do Dia
  // ════════════════════════════════════════════════════════════════
  final updateAvailabilityDayUseCase = UpdateAvailabilityDayUseCase(
    repository: availabilityRepository,
    getByDate: getAvailabilityByDateUseCase,
  );

  // ════════════════════════════════════════════════════════════════
  // Criar Use Cases de Validação
  // ════════════════════════════════════════════════════════════════
  final getOrganizedDayAfterVerificationUseCase = GetOrganizedDayAfterVerificationUseCase(
    getAvailabilityByDateUseCase: getAvailabilityByDateUseCase,
  );

  final getOrganizedAvailabilitiesAfterVerificationUseCase = GetOrganizedAvailabilitesAfterVerificationUseCase(
    getOrganizedDayAfterVerificationUseCase: getOrganizedDayAfterVerificationUseCase,
  );

  // ════════════════════════════════════════════════════════════════
  // Criar Use Cases de Períodos
  // ════════════════════════════════════════════════════════════════
  final createAvailabilityDayUseCase = CreateAvailabilityDayUseCase(
    repository: availabilityRepository,
  );

  final openPeriodUseCase = OpenPeriodUseCase(
    createAvailabilityDayUseCase: createAvailabilityDayUseCase,
    updateAvailabilityDayUseCase: updateAvailabilityDayUseCase,
  );

  final closePeriodUseCase = ClosePeriodUseCase(
    updateAvailabilityDayUseCase: updateAvailabilityDayUseCase,
  );

  // ════════════════════════════════════════════════════════════════
  // Criar Use Cases de Slots e Endereço
  // ════════════════════════════════════════════════════════════════


  // ════════════════════════════════════════════════════════════════
  // Criar e retornar AvailabilityBloc
  // ════════════════════════════════════════════════════════════════
  return AvailabilityBloc(
    getUserUidUseCase: getUserUidUseCase,
    getAllAvailabilitiesUseCase: getAllAvailabilitiesUseCase,
    getOrganizedDayAfterVerificationUseCase: getOrganizedDayAfterVerificationUseCase,
    getOrganizedAvailabilitiesAfterVerificationUseCase: getOrganizedAvailabilitiesAfterVerificationUseCase,
    openPeriodUseCase: openPeriodUseCase,
    closePeriodUseCase: closePeriodUseCase,
    updateAvailabilityDayUseCase: updateAvailabilityDayUseCase,
  );
}

/// Factory function para criar o BankAccountBloc com todas as dependências
BankAccountBloc _createBankAccountBloc(
  IBankAccountRepository bankAccountRepository,
  GetUserUidUseCase getUserUidUseCase,
  SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase,
) {
  // Criar UseCases
  final getBankAccountUseCase = GetBankAccountUseCase(repository: bankAccountRepository);
  final saveBankAccountUseCase = SaveBankAccountUseCase(repository: bankAccountRepository, syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase);
  final deleteBankAccountUseCase = DeleteBankAccountUseCase(repository: bankAccountRepository, syncArtistCompletenessIfChangedUseCase: syncArtistCompletenessIfChangedUseCase);
  
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
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCase orquestrador de validações (usa helpers internamente)
  final getArtistsWithAvailabilitiesFilteredUseCase = GetArtistsWithAvailabilitiesFilteredUseCase(
    repository: exploreRepository,
    calculateAddressGeohashUseCase: calculateAddressGeohashUseCase,
  );

  // Criar UseCase para buscar todas as disponibilidades ativas de um artista
  final getArtistActiveAvailabilitiesUseCase = GetArtistActiveAvailabilitiesUseCase(
    repository: exploreRepository,
    calculateAddressGeohashUseCase: calculateAddressGeohashUseCase,
  );

  return ExploreBloc(
    getArtistsWithAvailabilitiesFilteredUseCase: getArtistsWithAvailabilitiesFilteredUseCase,
    getArtistActiveAvailabilitiesUseCase: getArtistActiveAvailabilitiesUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o ContractsBloc com todas as dependências
ContractsBloc _createContractsBloc(
  IContractRepository contractRepository,
  GetUserUidUseCase getUserUidUseCase,
  IFirebaseFunctionsService firebaseFunctionsService,
  MercadoPagoService mercadoPagoService,
) {
  // Criar UseCase de atualização de índice (compartilhado)
  final updateContractsIndexUseCase = UpdateContractsIndexUseCase(repository: contractRepository);
  
  // Criar UseCases
  final getContractUseCase = GetContractUseCase(repository: contractRepository);
  final getContractsByClientUseCase = GetContractsByClientUseCase(repository: contractRepository);
  final getContractsByArtistUseCase = GetContractsByArtistUseCase(repository: contractRepository);
  final getContractsByGroupUseCase = GetContractsByGroupUseCase(repository: contractRepository);
  final addContractUseCase = AddContractUseCase(repository: contractRepository, updateContractsIndexUseCase: updateContractsIndexUseCase);
  final updateContractUseCase = UpdateContractUseCase(repository: contractRepository, updateContractsIndexUseCase: updateContractsIndexUseCase);
  final deleteContractUseCase = DeleteContractUseCase(repository: contractRepository);
  final cancelContractUseCase = CancelContractUseCase(repository: contractRepository, updateContractsIndexUseCase: updateContractsIndexUseCase);
  final acceptContractUseCase = AcceptContractUseCase(repository: contractRepository, firebaseFunctionsService: firebaseFunctionsService, updateContractsIndexUseCase: updateContractsIndexUseCase, cancelContractUseCase: cancelContractUseCase);
  final rejectContractUseCase = RejectContractUseCase(repository: contractRepository, updateContractsIndexUseCase: updateContractsIndexUseCase);
  final makePaymentUseCase = MakePaymentUseCase(mercadoPagoService: mercadoPagoService, repository: contractRepository, cancelContractUseCase: cancelContractUseCase);
  final verifyPaymentUseCase = VerifyPaymentUseCase(getContractUseCase: getContractUseCase, updateContractUseCase: updateContractUseCase);
  final confirmShowUseCase = ConfirmShowUseCase(getContractUseCase: getContractUseCase, updateContractUseCase: updateContractUseCase, contractRepository: contractRepository);
  final rateArtistUseCase = RateArtistUseCase(getContractUseCase: getContractUseCase, updateContractUseCase: updateContractUseCase);
  final skipRatingArtistUseCase = SkipRatingArtistUseCase(getContractUseCase: getContractUseCase, updateContractUseCase: updateContractUseCase);
  final rateClientUseCase = RateClientUseCase(getContractUseCase: getContractUseCase, updateContractUseCase: updateContractUseCase);


  // Criar e retornar ContractsBloc
  return ContractsBloc(
    getContractUseCase: getContractUseCase,
    getContractsByClientUseCase: getContractsByClientUseCase,
    getContractsByArtistUseCase: getContractsByArtistUseCase,
    getContractsByGroupUseCase: getContractsByGroupUseCase,
    addContractUseCase: addContractUseCase,
    updateContractUseCase: updateContractUseCase,
    deleteContractUseCase: deleteContractUseCase,
    acceptContractUseCase: acceptContractUseCase,
    rejectContractUseCase: rejectContractUseCase,
    makePaymentUseCase: makePaymentUseCase,
    cancelContractUseCase: cancelContractUseCase,
    verifyPaymentUseCase: verifyPaymentUseCase,
    confirmShowUseCase: confirmShowUseCase,
    getUserUidUseCase: getUserUidUseCase,
    rateArtistUseCase: rateArtistUseCase,
    skipRatingArtistUseCase: skipRatingArtistUseCase,
    rateClientUseCase: rateClientUseCase,
  );
}

FavoritesBloc _createFavoritesBloc(
  IFavoriteRepository favoriteRepository,
  IExploreRepository exploreRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final addFavoriteUseCase = AddFavoriteUseCase(repository: favoriteRepository);
  final removeFavoriteUseCase = RemoveFavoriteUseCase(repository: favoriteRepository);
  final getFavoriteArtistsUseCase = GetFavoriteArtistsUseCase(favoriteRepository: favoriteRepository, exploreRepository: exploreRepository);
  return FavoritesBloc(getUserUidUseCase: getUserUidUseCase, addFavoriteUseCase: addFavoriteUseCase, removeFavoriteUseCase: removeFavoriteUseCase, getFavoriteArtistsUseCase: getFavoriteArtistsUseCase);
}

EnsembleBloc _createEnsembleBloc(
  IEnsembleRepository ensembleRepository,
  IMembersRepository membersRepository,
  IStorageService storageService,
  GetUserUidUseCase getUserUidUseCase,
  SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase,
) {
  final createEmptyEnsembleUseCase = CreateEmptyEnsembleUseCase(repository: ensembleRepository);
  final getAllEnsemblesUseCase = GetAllEnsemblesUseCase(repository: ensembleRepository);
  final getEnsembleUseCase = GetEnsembleUseCase(repository: ensembleRepository);
  final updateEnsembleUseCase = UpdateEnsembleUseCase(
    repository: ensembleRepository,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  final getMemberUseCase = GetMemberUseCase(repository: membersRepository);
  final updateMemberUseCase = UpdateMemberUseCase(repository: membersRepository);
  final createEnsembleUseCase = CreateEnsembleUseCase(
    repository: ensembleRepository,
    createEmptyEnsembleUseCase: createEmptyEnsembleUseCase,
    updateEnsembleUseCase: updateEnsembleUseCase,
    updateMemberUseCase: updateMemberUseCase,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  final updateEnsembleProfilePhotoUseCase = UpdateEnsembleProfilePhotoUseCase(getEnsembleUseCase: getEnsembleUseCase, updateEnsembleUseCase: updateEnsembleUseCase, storageService: storageService);
  final updateEnsemblePresentationVideoUseCase = UpdateEnsemblePresentationVideoUseCase(getEnsembleUseCase: getEnsembleUseCase, updateEnsembleUseCase: updateEnsembleUseCase, storageService: storageService);
  final updateEnsembleProfessionalInfoUseCase = UpdateEnsembleProfessionalInfoUseCase(getEnsembleUseCase: getEnsembleUseCase, updateEnsembleUseCase: updateEnsembleUseCase);
  final updateEnsembleMembersUseCase = UpdateEnsembleMembersUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    updateEnsembleUseCase: updateEnsembleUseCase,
    getMemberUseCase: getMemberUseCase,
    updateMemberUseCase: updateMemberUseCase,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  final updateEnsembleMemberTalentsUseCase = UpdateEnsembleMemberTalentsUseCase(getEnsembleUseCase: getEnsembleUseCase, updateEnsembleUseCase: updateEnsembleUseCase);
  final updateEnsembleActiveStatusUseCase = UpdateEnsembleActiveStatusUseCase(getEnsembleUseCase: getEnsembleUseCase, updateEnsembleUseCase: updateEnsembleUseCase);
  final deleteEnsembleUseCase = DeleteEnsembleUseCase(repository: ensembleRepository, getEnsembleByIdUseCase: getEnsembleUseCase, storageService: storageService);
  return EnsembleBloc(
    getAllEnsemblesUseCase: getAllEnsemblesUseCase, 
    getEnsembleUseCase: getEnsembleUseCase, 
    createEnsembleUseCase: createEnsembleUseCase, 
    updateEnsembleUseCase: updateEnsembleUseCase, 
    updateEnsembleProfilePhotoUseCase: updateEnsembleProfilePhotoUseCase, 
    updateEnsemblePresentationVideoUseCase: updateEnsemblePresentationVideoUseCase, 
    updateEnsembleProfessionalInfoUseCase: updateEnsembleProfessionalInfoUseCase, 
    updateEnsembleMembersUseCase: updateEnsembleMembersUseCase, 
    updateEnsembleMemberTalentsUseCase: updateEnsembleMemberTalentsUseCase,
    updateEnsembleActiveStatusUseCase: updateEnsembleActiveStatusUseCase,
    deleteEnsembleUseCase: deleteEnsembleUseCase, 
    getUserUidUseCase: getUserUidUseCase,
  );
}

MembersBloc _createMembersBloc(
  IMembersRepository membersRepository,
  IEnsembleRepository ensembleRepository,
  IUsersRepository usersRepository,
  GetUserUidUseCase getUserUidUseCase,
  IDocumentsRepository documentsRepository,
  IBankAccountRepository bankAccountRepository,
  IMemberDocumentsRepository memberDocumentsRepository,
) {
  final getUserDataUseCase = GetUserDataUseCase(usersRepository: usersRepository);
  final getAllMembersUseCase = GetAllMembersUseCase(membersRepository: membersRepository);
  final getMemberUseCase = GetMemberUseCase(repository: membersRepository);
  final createMemberUseCase = CreateMemberUseCase(repository: membersRepository, getUserDataUseCase: getUserDataUseCase);
  final updateMemberUseCase = UpdateMemberUseCase(repository: membersRepository);
  final getEnsembleUseCase = GetEnsembleUseCase(repository: ensembleRepository);
  final checkEnsembleCompletenessUseCase = CheckEnsembleCompletenessUseCase();
  final getAllMemberDocumentsUseCase = GetAllMemberDocumentsUseCase(repository: memberDocumentsRepository);
  final getEnsembleCompletenessUseCase = GetEnsembleCompletenessUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    documentsRepository: documentsRepository,
    bankAccountRepository: bankAccountRepository,
    getAllMemberDocumentsUseCase: getAllMemberDocumentsUseCase,
    checkEnsembleCompletenessUseCase: checkEnsembleCompletenessUseCase,
  );
  final updateEnsembleIncompleteSectionsUseCase = UpdateEnsembleIncompleteSectionsUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    repository: ensembleRepository,
  );
  final syncEnsembleCompletenessIfChangedUseCase = SyncEnsembleCompletenessIfChangedUseCase(
    getEnsembleCompletenessUseCase: getEnsembleCompletenessUseCase,
    getEnsembleUseCase: getEnsembleUseCase,
    updateEnsembleIncompleteSectionsUseCase: updateEnsembleIncompleteSectionsUseCase,
  );
  final updateEnsembleUseCase = UpdateEnsembleUseCase(
    repository: ensembleRepository,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  final updateEnsembleMembersUseCase = UpdateEnsembleMembersUseCase(
    getEnsembleUseCase: getEnsembleUseCase,
    updateEnsembleUseCase: updateEnsembleUseCase,
    getMemberUseCase: getMemberUseCase,
    updateMemberUseCase: updateMemberUseCase,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  final deleteMemberUseCase = DeleteMemberUseCase(
    repository: membersRepository,
    getMemberUseCase: getMemberUseCase,
    getEnsembleUseCase: getEnsembleUseCase,
    updateEnsembleMembersUseCase: updateEnsembleMembersUseCase,
  );
  return MembersBloc(
    getAllMembersUseCase: getAllMembersUseCase,
    getMemberUseCase: getMemberUseCase,
    createMemberUseCase: createMemberUseCase,
    updateMemberUseCase: updateMemberUseCase,
    deleteMemberUseCase: deleteMemberUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

MemberDocumentsBloc _createMemberDocumentsBloc(
  IMemberDocumentsRepository memberDocumentsRepository,
  GetUserUidUseCase getUserUidUseCase,
  IStorageService storageService,
  SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase,
) {
  
  final getAllMemberDocumentsUseCase = GetAllMemberDocumentsUseCase(repository: memberDocumentsRepository);
  final getMemberDocumentUseCase = GetMemberDocumentUseCase(repository: memberDocumentsRepository);
  final saveMemberDocumentUseCase = SaveMemberDocumentUseCase(
    repository: memberDocumentsRepository,
    storageService: storageService,
    syncEnsembleCompletenessIfChangedUseCase: syncEnsembleCompletenessIfChangedUseCase,
  );
  return MemberDocumentsBloc(
    getAllMemberDocumentsUseCase: getAllMemberDocumentsUseCase,
    getMemberDocumentUseCase: getMemberDocumentUseCase,
    saveMemberDocumentUseCase: saveMemberDocumentUseCase,
    getUserUidUseCase: getUserUidUseCase,
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

SupportBloc _createSupportBloc(
  ISupportRepository supportRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  final sendSupportMessageUseCase = SendSupportMessageUseCase(repository: supportRepository);
  return SupportBloc(
    sendSupportMessageUseCase: sendSupportMessageUseCase,
    getUserUidUseCase: getUserUidUseCase,
  );
}

/// Factory function para criar o ArtistDashboardBloc com todas as dependências
ArtistDashboardBloc _createArtistDashboardBloc(
  IArtistsRepository artistsRepository,
  IContractRepository contractRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases de cálculo
  const calculateMonthlyEarningsUseCase = CalculateMonthlyEarningsUseCase();
  const calculatePendingRequestsUseCase = CalculatePendingRequestsUseCase();
  const calculateUpcomingEventsUseCase = CalculateUpcomingEventsUseCase();
  const calculateCompletedEventsUseCase = CalculateCompletedEventsUseCase();
  const calculateAcceptanceRateUseCase = CalculateAcceptanceRateUseCase();
  const calculateMonthlyStatsUseCase = CalculateMonthlyStatsUseCase();
  const calculateNextShowUseCase = CalculateNextShowUseCase();

  // Criar UseCases principais
  final getArtistUseCase = GetArtistUseCase(repository: artistsRepository);
  final getContractsByArtistUseCase = GetContractsByArtistUseCase(repository: contractRepository);

  // Criar UseCase principal do dashboard
  final getArtistDashboardStatsUseCase = GetArtistDashboardStatsUseCase(
    getUserUidUseCase: getUserUidUseCase,
    getArtistUseCase: getArtistUseCase,
    getContractsByArtistUseCase: getContractsByArtistUseCase,
    calculateMonthlyEarningsUseCase: calculateMonthlyEarningsUseCase,
    calculatePendingRequestsUseCase: calculatePendingRequestsUseCase,
    calculateUpcomingEventsUseCase: calculateUpcomingEventsUseCase,
    calculateCompletedEventsUseCase: calculateCompletedEventsUseCase,
    calculateAcceptanceRateUseCase: calculateAcceptanceRateUseCase,
    calculateMonthlyStatsUseCase: calculateMonthlyStatsUseCase,
    calculateNextShowUseCase: calculateNextShowUseCase,
  );

  // Criar e retornar ArtistDashboardBloc
  return ArtistDashboardBloc(
    getArtistDashboardStatsUseCase: getArtistDashboardStatsUseCase,
  );
}

/// Factory function para criar o ChatsListBloc com todas as dependências
ChatsListBloc _createChatsListBloc(
  IChatRepository chatRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final createChatUseCase = CreateChatUseCase(repository: chatRepository);

  // Criar e retornar ChatsListBloc
  return ChatsListBloc(
    getUserUidUseCase: getUserUidUseCase,
    createChatUseCase: createChatUseCase,
    chatRepository: chatRepository,
  );
}

/// Factory function para criar o MessagesBloc com todas as dependências
MessagesBloc _createMessagesBloc(
  IChatRepository chatRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCases
  final sendMessageUseCase = SendMessageUseCase(repository: chatRepository);
  final markMessagesAsReadUseCase = MarkMessagesAsReadUseCase(repository: chatRepository);
  final updateTypingStatusUseCase = UpdateTypingStatusUseCase(repository: chatRepository);
  final getMessagesPaginatedUseCase = GetMessagesPaginatedUseCase(repository: chatRepository);

  // Criar e retornar MessagesBloc
  return MessagesBloc(
    getUserUidUseCase: getUserUidUseCase,
    sendMessageUseCase: sendMessageUseCase,
    getMessagesPaginatedUseCase: getMessagesPaginatedUseCase,
    markMessagesAsReadUseCase: markMessagesAsReadUseCase,
    updateTypingStatusUseCase: updateTypingStatusUseCase,
    chatRepository: chatRepository,
  );
}

/// Factory function para criar o UnreadCountBloc com todas as dependências
/// 
/// Este BLoC usa um stream otimizado que escuta apenas o campo totalUnread
/// do documento user_chats/{userId}, sem precisar buscar todos os chats completos.
UnreadCountBloc _createUnreadCountBloc(
  IChatRepository chatRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar UseCase
  final getUnreadCountUseCase = GetUnreadCountUseCase(repository: chatRepository);

  // Criar e retornar UnreadCountBloc
  return UnreadCountBloc(
    getUserUidUseCase: getUserUidUseCase,
    getUnreadCountUseCase: getUnreadCountUseCase,
  );
}

/// Factory function para criar o PendingContractsCountBloc com todas as dependências
/// 
/// Este BLoC usa um stream otimizado que escuta apenas o documento de índice
/// user_contracts_index/{userId}, não todos os contratos.
PendingContractsCountBloc _createPendingContractsCountBloc(
  IContractRepository contractRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  // Criar e retornar PendingContractsCountBloc
  return PendingContractsCountBloc(
    getUserUidUseCase: getUserUidUseCase,
    contractRepository: contractRepository,
  );
}

/// Factory function para criar o EnsembleAvailabilityBloc com todas as dependências
EnsembleAvailabilityBloc _createEnsembleAvailabilityBloc(
  IEnsembleAvailabilityRepository ensembleAvailabilityRepository,
  GetUserUidUseCase getUserUidUseCase,
) {
  final getAllAvailabilitiesUseCase = GetAllEnsembleAvailabilitiesUseCase(repository: ensembleAvailabilityRepository);
  final getEnsembleAvailabilityByDateUseCase = GetEnsembleAvailabilityByDateUseCase(repository: ensembleAvailabilityRepository);
  final getOrganizedDayAfterVerificationUseCase = GetOrganizedEnsembleDayAfterVerificationUseCase(getEnsembleAvailabilityByDateUseCase: getEnsembleAvailabilityByDateUseCase);
  final getOrganizedAvailabilitiesAfterVerificationUseCase = GetOrganizedEnsembleAvailabilitesAfterVerificationUseCase(getOrganizedDayAfterVerificationUseCase: getOrganizedDayAfterVerificationUseCase);
  final createEnsembleAvailabilityDayUseCase = CreateEnsembleAvailabilityDayUseCase(repository: ensembleAvailabilityRepository);
  final updateEnsembleAvailabilityDayUseCase = UpdateEnsembleAvailabilityDayUseCase(getByDate: getEnsembleAvailabilityByDateUseCase, repository: ensembleAvailabilityRepository);
  final openPeriodUseCase = OpenEnsemblePeriodUseCase(createEnsembleAvailabilityDayUseCase: createEnsembleAvailabilityDayUseCase, updateEnsembleAvailabilityDayUseCase: updateEnsembleAvailabilityDayUseCase);
  final closePeriodUseCase = CloseEnsemblePeriodUseCase(updateAvailabilityDayUseCase: updateEnsembleAvailabilityDayUseCase);
  return EnsembleAvailabilityBloc(
    getAllAvailabilitiesUseCase: getAllAvailabilitiesUseCase,
    getOrganizedDayAfterVerificationUseCase: getOrganizedDayAfterVerificationUseCase,
    getOrganizedAvailabilitiesAfterVerificationUseCase: getOrganizedAvailabilitiesAfterVerificationUseCase,
    openPeriodUseCase: openPeriodUseCase,
    closePeriodUseCase: closePeriodUseCase,
    updateAvailabilityDayUseCase: updateEnsembleAvailabilityDayUseCase,
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
  final firebaseFunctionsService = getIt<IFirebaseFunctionsService>();
  final mercadoPagoService = getIt<MercadoPagoService>();

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
      availabilityRepository: availabilityRepository,
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
  final membersLocalDataSource = MembersLocalDataSourceImpl(localCacheService: localCacheService);
  final membersRemoteDataSource = MembersRemoteDataSourceImpl(firestore: firestore);
  final membersRepository = MembersRepositoryImpl(
    remoteDataSource: membersRemoteDataSource,
    localDataSource: membersLocalDataSource,
  );

  // Member Documents (documentos do integrante)
  final memberDocumentsLocalDataSource = MemberDocumentsLocalDataSourceImpl(localCacheService: localCacheService);
  final memberDocumentsRemoteDataSource = MemberDocumentsRemoteDataSourceImpl(firestore: firestore);
  final memberDocumentsRepository = MemberDocumentsRepositoryImpl(
    localDataSource: memberDocumentsLocalDataSource,
    remoteDataSource: memberDocumentsRemoteDataSource,
  );

  // Ensemble Availability
  final ensembleAvailabilityLocalDataSource = EnsembleAvailabilityLocalDataSourceImpl(localCacheService: localCacheService);
  final ensembleAvailabilityRemoteDataSource = EnsembleAvailabilityRemoteDataSourceImpl(firestore: firestore);
  final ensembleAvailabilityRepository = EnsembleAvailabilityRepositoryImpl(localDataSource: ensembleAvailabilityLocalDataSource, remoteDataSource: ensembleAvailabilityRemoteDataSource);

  // Sync Ensemble Completeness If Changed UseCase
  
  final getAllMemberDocumentsUseCase = GetAllMemberDocumentsUseCase(repository: memberDocumentsRepository);
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
    getAllMemberDocumentsUseCase: getAllMemberDocumentsUseCase,
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

  // Chat
  final chatLocalDataSource = ChatLocalDataSourceImpl(autoCache: localCacheService);
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(firestore: firestore);
  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
    localDataSource: chatLocalDataSource,
  );

  // Support (atendimento)
  final supportRemoteDataSource = SupportRemoteDataSourceImpl(firestore: firestore);
  final supportEmailService = SupportEmailServiceImpl(mailService: MailService());
  final supportRepository = SupportRepositoryImpl(
    remoteDataSource: supportRemoteDataSource,
    emailService: supportEmailService,
  );

  runApp(MultiBlocProvider(
        providers: [
          // BLoCs
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
              syncArtistCompletenessIfChangedUseCase,
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
              syncArtistCompletenessIfChangedUseCase,
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
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createAvailabilityBloc(
              availabilityRepository, 
              getUserUidUseCase,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createBankAccountBloc(
              bankAccountRepository,
              getUserUidUseCase,
              syncArtistCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createExploreBloc(
              exploreRepository,
              calculateAddressGeohashUseCase,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createContractsBloc(
              contractRepository,
              getUserUidUseCase,
              firebaseFunctionsService,
              mercadoPagoService,
            ),
          ),
          BlocProvider(
            create: (context) => _createPendingContractsCountBloc(
              contractRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createFavoritesBloc(
              favoriteRepository,
              exploreRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createEnsembleBloc(
              ensembleRepository,
              membersRepository,
              storageService,
              getUserUidUseCase,
              syncEnsembleCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createMembersBloc(
              membersRepository,
              ensembleRepository,
              usersRepository,
              getUserUidUseCase,
              documentsRepository,
              bankAccountRepository,
              memberDocumentsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => _createMemberDocumentsBloc(
              memberDocumentsRepository,
              getUserUidUseCase,
              storageService,
              syncEnsembleCompletenessIfChangedUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createEnsembleAvailabilityBloc(
              ensembleAvailabilityRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createAppListsBloc(
              appListsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => _createSupportBloc(
              supportRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createChatsListBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createMessagesBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createUnreadCountBloc(
              chatRepository,
              getUserUidUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => _createArtistDashboardBloc(
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
