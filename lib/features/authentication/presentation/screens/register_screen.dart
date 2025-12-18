import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/shared/widgets/link_text.dart';
import 'package:app/core/shared/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

@RoutePage(deferredLoading: true)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final router = AutoRouter.of(context);
    router.push(EmailVerificationRoute(email: 'teste@teste.com'));
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    return AuthBasePage(
      title: 'CADASTRO',
      subtitle: 'Crie sua conta',
      children: [
        // Campos de cadastro
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {},
        ),
        
        DSSizedBoxSpacing.vertical(4),
        
        // Campo de Senha
        CustomTextField(
          label: 'Senha',
          obscureText: true,
          isPassword: true,
          keyboardType: TextInputType.text,
          controller: _passwordController,
          onChanged: (value) {},
        ),

        DSSizedBoxSpacing.vertical(4),
        
        // Campo de Confirmar Senha
        CustomTextField(
          label: 'Confirmar Senha',
          obscureText: true,
          isPassword: true,
          keyboardType: TextInputType.text,
          controller: _confirmPasswordController,
          onChanged: (value) {},
        ),
        
        DSSizedBoxSpacing.vertical(24),
        
        // Botão de Cadastrar
        CustomButton(
          label: _isLoading ? 'Cadastrando...' : 'Cadastrar',
          filled: true,
          onPressed: _isLoading ? () {} : _handleRegister,
        ),
        
        DSSizedBoxSpacing.vertical(190),
        
        // Link "Já tenho uma conta"
        Center(
          child: CustomLinkText(
            text: 'Já possui uma conta? Faça login',
            textColor: onPrimaryContainer,
            onTap: () {
              router.push(const LoginRoute());
            },
          ),
        ),
      ],
    );
  }
}

