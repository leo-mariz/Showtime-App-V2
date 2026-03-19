import 'package:equatable/equatable.dart';

abstract class AppContentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetTermsOfUseEvent extends AppContentEvent {}

class GetPrivacyPolicyEvent extends AppContentEvent {}
