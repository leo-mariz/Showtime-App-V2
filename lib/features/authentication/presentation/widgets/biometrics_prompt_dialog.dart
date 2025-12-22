import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';

/// Modal para oferecer habilitar biometria após login bem-sucedido
class BiometricsPromptDialog extends StatelessWidget {
  final UserEntity user;

  const BiometricsPromptDialog({
    super.key,
    required this.user,
  });

  static Future<void> show({
    required BuildContext context,
    required UserEntity user,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BiometricsPromptDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DSSize.width(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle bar
              Container(
                width: DSSize.width(40),
                height: DSSize.height(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4 * 255),
                  borderRadius: BorderRadius.circular(DSSize.width(2)),
                ),
              ),

              DSSizedBoxSpacing.vertical(24),

              // Ícone de biometria
              Icon(
                Icons.fingerprint,
                size: DSSize.width(64),
                color: colorScheme.primary,
              ),

              DSSizedBoxSpacing.vertical(16),

              // Título
              Text(
                'Login rápido com biometria',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),

              DSSizedBoxSpacing.vertical(8),

              // Descrição
              Text(
                'Deseja habilitar login rápido usando sua biometria? Você poderá entrar no app sem precisar digitar email e senha.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              DSSizedBoxSpacing.vertical(32),

              // Botões
              Row(
                children: [
                  // Botão "Agora não"
                  Expanded(
                    child: CustomButton(
                      label: 'Agora não',
                      filled: false,
                      textColor: colorScheme.onPrimaryContainer,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  DSSizedBoxSpacing.horizontal(12),

                  // Botão "Habilitar"
                  Expanded(
                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          Navigator.of(context).pop();
                          // A notificação de sucesso já é mostrada pelo BlocListener da tela
                        } else if (state is AuthFailure) {
                          // Erro já é mostrado pelo BlocListener da tela
                        }
                      },
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return CustomButton(
                            label: isLoading ? 'Habilitando...' : 'Habilitar',
                            filled: true,
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          EnableBiometricsEvent(user: user),
                                        );
                                  },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              DSSizedBoxSpacing.vertical(12),

              // Link "Não mostrar novamente"
              TextButton(
                onPressed: () {
                  // TODO: Salvar preferência de não mostrar novamente
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Não mostrar novamente',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

