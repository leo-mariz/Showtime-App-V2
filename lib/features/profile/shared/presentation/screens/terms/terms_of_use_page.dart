import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/app_content/presentation/bloc/app_content_bloc.dart';
import 'package:app/features/app_content/presentation/bloc/events/app_content_events.dart';
import 'package:app/features/app_content/presentation/bloc/states/app_content_states.dart';
import 'package:app/features/profile/shared/presentation/widgets/terms_base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppContentBloc>().add(GetTermsOfUseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppContentBloc, AppContentState>(
      buildWhen: (previous, current) =>
          current is GetTermsOfUseLoading ||
          current is GetTermsOfUseSuccess ||
          current is GetTermsOfUseFailure,
      builder: (context, state) {
        if (state is GetTermsOfUseLoading) {
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Termos de Uso',
            showAppBarBackButton: true,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is GetTermsOfUseFailure) {
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Termos de Uso',
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
        if (state is GetTermsOfUseSuccess) {
          final content = state.termsOfUse.content.trim().isEmpty
              ? 'Conteúdo em breve.'
              : state.termsOfUse.content;
          return TermsBaseWidget(
            title: 'Termos de Uso',
            content: content,
          );
        }
        return BasePage(
          showAppBar: true,
          appBarTitle: 'Termos de Uso',
          showAppBarBackButton: true,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
