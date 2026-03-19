import 'package:app/features/app_content/domain/usecases/get_privacy_policy_usecase.dart';
import 'package:app/features/app_content/domain/usecases/get_terms_of_use_usecase.dart';
import 'package:app/features/app_content/presentation/bloc/events/app_content_events.dart';
import 'package:app/features/app_content/presentation/bloc/states/app_content_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppContentBloc extends Bloc<AppContentEvent, AppContentState> {
  final GetTermsOfUseUseCase getTermsOfUseUseCase;
  final GetPrivacyPolicyUseCase getPrivacyPolicyUseCase;

  AppContentBloc({
    required this.getTermsOfUseUseCase,
    required this.getPrivacyPolicyUseCase,
  }) : super(AppContentInitial()) {
    on<GetTermsOfUseEvent>(_onGetTermsOfUseEvent);
    on<GetPrivacyPolicyEvent>(_onGetPrivacyPolicyEvent);
  }

  Future<void> _onGetTermsOfUseEvent(
    GetTermsOfUseEvent event,
    Emitter<AppContentState> emit,
  ) async {
    emit(GetTermsOfUseLoading());

    final result = await getTermsOfUseUseCase.call();

    result.fold(
      (failure) => emit(GetTermsOfUseFailure(error: failure.message)),
      (entity) => emit(GetTermsOfUseSuccess(termsOfUse: entity)),
    );
  }

  Future<void> _onGetPrivacyPolicyEvent(
    GetPrivacyPolicyEvent event,
    Emitter<AppContentState> emit,
  ) async {
    emit(GetPrivacyPolicyLoading());

    final result = await getPrivacyPolicyUseCase.call();

    result.fold(
      (failure) => emit(GetPrivacyPolicyFailure(error: failure.message)),
      (entity) => emit(GetPrivacyPolicySuccess(privacyPolicy: entity)),
    );
  }
}
