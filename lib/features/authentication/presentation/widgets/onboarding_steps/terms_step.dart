import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
    final router = AutoRouter.of(context);

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
            router.push(isArtist ? ArtistsTermsOfUseRoute() : ClientTermsOfUseRoute());
          },
        ),
        
        DSSizedBoxSpacing.vertical(16),
        
        // Checkbox Política de Privacidade
        _TermsCheckbox(
          value: isPrivacyPolicyAccepted,
          onChanged: onPrivacyPolicyChanged,
          label: 'Li e aceito a Política de Privacidade',
          onLinkTap: () {
            router.push(TermsOfPrivacyRoute());
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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
          child: _buildRichText(context, label),
        ),
      ],
    );
  }

  Widget _buildRichText(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Identificar os textos que devem ter underline
    final termosIndex = label.indexOf('Termos de Uso');
    final politicaIndex = label.indexOf('Política de Privacidade');
    
    // Se não encontrar nenhum dos textos, retornar texto normal
    if (termosIndex == -1 && politicaIndex == -1) {
      return Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }
    
    // Construir TextSpans
    final spans = <TextSpan>[];
    int currentIndex = 0;
    
    // Processar "Termos de Uso" se existir
    if (termosIndex != -1) {
      // Texto antes de "Termos de Uso"
      if (termosIndex > currentIndex) {
        spans.add(TextSpan(
          text: label.substring(currentIndex, termosIndex),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ));
      }
      
      // "Termos de Uso" com underline e clicável
      spans.add(TextSpan(
        text: 'Termos de Uso',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()..onTap = onLinkTap,
      ));
      
      currentIndex = termosIndex + 'Termos de Uso'.length;
    }
    
    // Processar "Política de Privacidade" se existir
    if (politicaIndex != -1) {
      // Texto antes de "Política de Privacidade"
      if (politicaIndex > currentIndex) {
        spans.add(TextSpan(
          text: label.substring(currentIndex, politicaIndex),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ));
      }
      
      // "Política de Privacidade" com underline e clicável
      spans.add(TextSpan(
        text: 'Política de Privacidade',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()..onTap = onLinkTap,
      ));
      
      currentIndex = politicaIndex + 'Política de Privacidade'.length;
    }
    
    // Texto restante após os links
    if (currentIndex < label.length) {
      spans.add(TextSpan(
        text: label.substring(currentIndex),
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ));
    }
    
    return Text.rich(
      TextSpan(children: spans),
    );
  }
}

