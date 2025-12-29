import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EmailVerificationPage extends StatefulWidget {
  final String email;
  final bool isChangeEmail;
  const EmailVerificationPage({super.key, required this.email, this.isChangeEmail = false});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  void initState() {
    super.initState();
    // Verificar status inicial do email se necessário
  }

  void _handleCheckEmailVerified() {
    if (widget.isChangeEmail) {
      context.read<AuthBloc>().add(CheckNewEmailVerifiedEvent(newEmail: widget.email));
    } else {
      context.read<AuthBloc>().add(CheckEmailVerifiedEvent());
    }
  }

  void _handleResendVerificationEmail() {
    context.read<AuthBloc>().add(ResendEmailVerificationEvent());
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is CheckEmailVerifiedSuccess) {
          if (state.isVerified) {
            router.maybePop();
            context.showSuccess('E-mail verificado com sucesso.');
            router.replace(OnboardingRoute(email: widget.email));
          } else {
            context.showError('E-mail ainda não verificado. Verifique sua caixa de entrada.');
          }
        } else if (state is CheckEmailVerifiedFailure) {
          context.showError(state.error);
        } else if (state is CheckNewEmailVerifiedSuccess) {
          if (state.isVerified) {
            router.maybePop();
          } else {
            context.showError('E-mail ainda não verificado. Verifique sua caixa de entrada.');
          }
        } else if (state is CheckNewEmailVerifiedFailure) {
          context.showError(state.error);
        } else if (state is ResendEmailVerificationSuccess) {
          context.showSuccess(state.message);
        } else if (state is ResendEmailVerificationFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Estados de loading específicos para cada botão
          final isCheckingEmail = state is CheckEmailVerifiedLoading ||
              state is CheckNewEmailVerifiedLoading;
          final isResendingEmail = state is ResendEmailVerificationLoading;
          
          // Ambos ficam desabilitados durante qualquer loading
          final isAnyLoading = isCheckingEmail || isResendingEmail;

          return BasePage(
            showAppBar: true,
            appBarTitle: "Verifique seu e-mail",
            showAppBarBackButton: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DSSizedBoxSpacing.vertical(24),
                Text(
                  widget.isChangeEmail
                      ? 'Enviamos um e-mail de verificação para o e-mail ${widget.email}. Por favor, verifique seu novo e-mail antes de continuar. Caso não encontre em sua caixa de entrada, verifique sua caixa de spam. O e-mail não será alterado até que você verifique seu novo e-mail.'
                      : 'Enviamos um e-mail de verificação para o e-mail ${widget.email}. Por favor, verifique seu e-mail antes de continuar. Caso não encontre, verifique sua caixa de spam.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                DSSizedBoxSpacing.vertical(24),
                CustomButton(
                  label: widget.isChangeEmail
                      ? "Já verifiquei meu novo e-mail"
                      : "Já verifiquei meu e-mail",
                  onPressed: isAnyLoading ? null : _handleCheckEmailVerified,
                  isLoading: isCheckingEmail,
                ),
                DSSizedBoxSpacing.vertical(16),
                if (!widget.isChangeEmail)
                  CustomButton(
                    label: "Reenviar e-mail de verificação",
                    onPressed: isAnyLoading ? null : _handleResendVerificationEmail,
                    filled: false,
                    textColor: colorScheme.onPrimaryContainer,
                    isLoading: isResendingEmail,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}