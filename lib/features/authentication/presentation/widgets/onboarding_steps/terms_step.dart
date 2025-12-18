import 'package:flutter/material.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';

/// Step 3 do onboarding: Aceite de termos e privacidade
class TermsStep extends StatelessWidget {
  final bool isArtist;
  final bool isTermsOfUseAccepted;
  final bool isPrivacyPolicyAccepted;
  final Function(bool) onTermsOfUseChanged;
  final Function(bool) onPrivacyPolicyChanged;
  final bool showError;

  const TermsStep({
    super.key,
    required this.isArtist,
    required this.isTermsOfUseAccepted,
    required this.isPrivacyPolicyAccepted,
    required this.onTermsOfUseChanged,
    required this.onPrivacyPolicyChanged,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSizedBoxSpacing.vertical(24),
        
        // Checkbox Termos de Uso
        _TermsCheckbox(
          value: isTermsOfUseAccepted,
          onChanged: onTermsOfUseChanged,
          label: isArtist 
              ? 'Li e aceito os Termos de Uso para Artistas'
              : 'Li e aceito os Termos de Uso para Anfitriões',
          onLinkTap: () {
            // TODO: Abrir termos de uso
          },
        ),
        
        DSSizedBoxSpacing.vertical(16),
        
        // Checkbox Política de Privacidade
        _TermsCheckbox(
          value: isPrivacyPolicyAccepted,
          onChanged: onPrivacyPolicyChanged,
          label: 'Li e aceito a Política de Privacidade',
          onLinkTap: () {
            // TODO: Abrir política de privacidade
          },
        ),
        
        // Mensagem de erro
        if (showError) ...[
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.only(left: DSSize.width(8)),
            child: Text(
              'Aceite todos os termos para continuar',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget de checkbox para aceite de termos
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final String label;
  final VoidCallback onLinkTap;

  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: DSSize.width(24),
          height: DSSize.height(24),
          child: Checkbox(
            value: value,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            activeColor: colorScheme.primaryContainer,
            checkColor: colorScheme.onPrimary,
            side: BorderSide(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.5 * 255),
              width: 1.5,
            ),
          ),
        ),
        DSSizedBoxSpacing.horizontal(12),
        Expanded(
          child: GestureDetector(
            onTap: onLinkTap,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

