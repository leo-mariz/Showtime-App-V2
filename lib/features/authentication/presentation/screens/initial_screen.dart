import 'package:app/core/shared/widgets/app_logo.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/config/auto_router_config.gr.dart';

@RoutePage()
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final router = AutoRouter.of(context);
    return PopScope(
      canPop: false,
      child: BasePage(
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                CustomLogo(size: 140),
                Text(
                  "A magia da música e da arte\n tornando seus momentos\n inesquecíveis.",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall!.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                // Botão Fazer Login
                DSSizedBoxSpacing.vertical(40),
                // Botão Cadastrar-se
                CustomButton(
                  label: 'Cadastre-se',
                  filled: true,
                  icon: Icons.person_add,
                  iconColor: colorScheme.primaryContainer,
                  textColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.onPrimaryContainer,
                  onPressed: () {
                    router.push(const RegisterRoute());
                  },
                ),
                // Espaçamento entre botões
                DSSizedBoxSpacing.vertical(16),
                CustomButton(
                  label: 'Fazer Login',
                  icon: Icons.login,
                  iconColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.onPrimaryContainer,
                  backgroundColor: colorScheme.primaryContainer,
                  filled: true,
                  onPressed: () {
                    router.push(const LoginRoute());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
