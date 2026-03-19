import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/app_content/presentation/bloc/app_content_bloc.dart';
import 'package:app/features/app_content/presentation/bloc/events/app_content_events.dart';
import 'package:app/features/app_content/presentation/bloc/states/app_content_states.dart';
import 'package:app/features/profile/shared/presentation/widgets/terms_base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class TermsOfPrivacyScreen extends StatefulWidget {
  const TermsOfPrivacyScreen({super.key});

  @override
  State<TermsOfPrivacyScreen> createState() => _TermsOfPrivacyScreenState();
}

class _TermsOfPrivacyScreenState extends State<TermsOfPrivacyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppContentBloc>().add(GetPrivacyPolicyEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppContentBloc, AppContentState>(
      buildWhen: (previous, current) =>
          current is GetPrivacyPolicyLoading ||
          current is GetPrivacyPolicySuccess ||
          current is GetPrivacyPolicyFailure,
      builder: (context, state) {
        if (state is GetPrivacyPolicyLoading) {
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Política de Privacidade',
            showAppBarBackButton: true,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is GetPrivacyPolicyFailure) {
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Política de Privacidade',
            showAppBarBackButton: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  state.error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          );
        }
        if (state is GetPrivacyPolicySuccess) {
          final content = state.privacyPolicy.content.trim().isEmpty
              ? 'Conteúdo em breve.'
              : state.privacyPolicy.content;
          return TermsBaseWidget(
            title: 'Política de Privacidade',
            content: content,
          );
        }
        return BasePage(
          showAppBar: true,
          appBarTitle: 'Política de Privacidade',
          showAppBarBackButton: true,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
