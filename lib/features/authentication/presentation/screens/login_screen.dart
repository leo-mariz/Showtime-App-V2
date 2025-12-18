import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/enums/user_type.dart';
import 'package:app/core/shared/widgets/link_text.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/features/authentication/presentation/widgets/user_type_selector.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

@RoutePage(deferredLoading: true)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.artist;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final router = AutoRouter.of(context);
    router.push(NavigationRoute(isArtist: true));
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    return AuthBasePage(
      title: 'LOGIN',
      subtitle: 'Acessar conta',
      children: [
        
        // Campo de Email
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
          },
        ),
        
        DSSizedBoxSpacing.vertical(4),
        
        // Campo de Senha
        CustomTextField(
          label: 'Senha',
          obscureText: true,
          isPassword: true,
          keyboardType: TextInputType.text,
          controller: _passwordController,
          onChanged: (value) {
          },
        ),
        
        DSSizedBoxSpacing.vertical(20),

        // Link para esqueci senha
        Align(
          alignment: Alignment.centerRight,
          child: CustomLinkText(
            text: 'Esqueci minha senha',
            onTap: () {
              router.push(const ForgotPasswordRoute());
            },
          ),
        ),
        
        DSSizedBoxSpacing.vertical(12),
        
        // Seleção de Tipo de Usuário
        UserTypeSelector(
          selectedType: _selectedUserType,
          onChanged: (type) {
            if (!_isLoading) {
              setState(() => _selectedUserType = type);
            }
          },
        ),
        
        DSSizedBoxSpacing.vertical(48),
        
        // Botão de Login
        CustomButton(
          label: _isLoading ? 'Entrando...' : 'Entrar',
          filled: true,
          onPressed: _isLoading ? () {} : _handleLogin,
        ),
        
        DSSizedBoxSpacing.vertical(16),
        
        
      ],
    );
  }
}

