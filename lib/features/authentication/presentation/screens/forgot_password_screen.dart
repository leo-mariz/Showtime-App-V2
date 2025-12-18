import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

@RoutePage(deferredLoading: true)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    // TODO: Implementar lógica de login
    setState(() => _isLoading = true);
    
    // Simulação de login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Navegar para tela de redefinição de senha
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthBasePage(
      title: 'ESQUECI MINHA SENHA',
      subtitle: 'Redefina sua senha',
      children: [
        
        // Campo de Email
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
          },
        ),

        DSSizedBoxSpacing.vertical(16),

        Text(
          'Um link para redefinir sua senha será enviado para seu endereço de email',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        
        DSSizedBoxSpacing.vertical(24),
        
        // Botão de Login
        CustomButton(
          label: _isLoading ? 'Enviando...' : 'Enviar link de redefinição',
          filled: true,
          onPressed: _isLoading ? () {} : _handleForgotPassword,
        ),        
        
      ],
    );
  }
}

