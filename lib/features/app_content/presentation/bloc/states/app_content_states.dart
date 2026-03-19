import 'package:app/features/app_content/domain/entities/app_content_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AppContentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppContentInitial extends AppContentState {}

// ==================== TERMS OF USE ====================

class GetTermsOfUseLoading extends AppContentState {}

class GetTermsOfUseSuccess extends AppContentState {
  final AppContentEntity termsOfUse;

  GetTermsOfUseSuccess({required this.termsOfUse});

  @override
  List<Object?> get props => [termsOfUse];
}

class GetTermsOfUseFailure extends AppContentState {
  final String error;

  GetTermsOfUseFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== PRIVACY POLICY ====================

class GetPrivacyPolicyLoading extends AppContentState {}

class GetPrivacyPolicySuccess extends AppContentState {
  final AppContentEntity privacyPolicy;

  GetPrivacyPolicySuccess({required this.privacyPolicy});

  @override
  List<Object?> get props => [privacyPolicy];
}

class GetPrivacyPolicyFailure extends AppContentState {
  final String error;

  GetPrivacyPolicyFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
