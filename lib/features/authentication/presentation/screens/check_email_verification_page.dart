import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class EmailVerificationPage extends StatefulWidget {
  final String email;
  final bool isChangeEmail;
  const EmailVerificationPage({super.key, required this.email, this.isChangeEmail = false});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  String? _message;

  Future<void> _checkEmailVerified() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      final router = AutoRouter.of(context);
      router.maybePop();
      // router.replace(const OnboardingFlowRoute());
      
    // } else {
    //   setState(() {
    //     _message = 'E-mail ainda não verificado. Verifique sua caixa de entrada.';
    //     _isLoading = false;
    //   });
    }
  }

  // Future<void> _checkNewEmailVerified(String newEmail) async {
  //   setState(() {
  //     _isLoading = true;
  //     _message = null;
  //   });
  //   final router = AutoRouter.of(context);

  // }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() {
        _message = 'E-mail de verificação reenviado!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Erro ao reenviar e-mail: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    return BasePage(
      showAppBar: true,
      appBarTitle: "Verifique seu e-mail",
      showAppBarBackButton: true,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DSSizedBoxSpacing.vertical(24),
            Text(
              widget.isChangeEmail ? 'Enviamos um e-mail de verificação para o e-mail ${widget.email}. Por favor, verifique seu novo e-mail antes de continuar. Caso não encontre em sua caixa de entrada, verifique sua caixa de spam. O e-mail não será alterado até que você verifique seu novo e-mail.' : 'Enviamos um e-mail de verificação para o e-mail ${widget.email}. Por favor, verifique seu e-mail antes de continuar. Caso não encontre, verifique sua caixa de spam.',
              textAlign: TextAlign.center,
            ),
            DSSizedBoxSpacing.vertical(24),
            if (_message != null)
              Text(
                _message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center,
              ),
            DSSizedBoxSpacing.vertical(16),
            CustomButton(
              label: widget.isChangeEmail ? "Já verifiquei meu novo e-mail" : "Já verifiquei meu e-mail",
              // onPressed: _isLoading ? () {} : _checkEmailVerified,
              onPressed: () {
                router.push(OnboardingRoute(email: widget.email));
              },
            ),
            DSSizedBoxSpacing.vertical(16),
            if (!widget.isChangeEmail)
            CustomButton(
              label: "Reenviar e-mail de verificação",
              // onPressed: _isLoading ? () {} : _resendVerificationEmail,
              onPressed: () {
                router.push(OnboardingRoute(email: widget.email));
              },
            ),
          ],
        ),
    );
  }
}