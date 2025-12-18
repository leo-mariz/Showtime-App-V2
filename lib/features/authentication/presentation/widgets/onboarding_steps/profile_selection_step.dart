import 'package:app/features/authentication/presentation/widgets/profile_option_card.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Step 1 do onboarding: Seleção de perfil (Artista ou Anfitrião)
class ProfileSelectionStep extends StatelessWidget {
  final Function(bool isArtist) onProfileSelected;

  const ProfileSelectionStep({
    super.key,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Opção Anfitrião
        ProfileOptionCard(
          title: 'ANFITRIÃO',
          icon: Icons.home_work_outlined,
          iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
          description: 'Estou em busca de artistas para meus eventos.',
          onTap: () => onProfileSelected(false),
        ),
        
        DSSizedBoxSpacing.vertical(16),
        
        // Opção Artista
        ProfileOptionCard(
          title: 'ARTISTA',
          icon: Icons.mic_external_on_outlined,
          iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
          description: 'Eu gostaria de oferecer meus talentos.',
          onTap: () => onProfileSelected(true),
        ),
      ],
    );
  }
}

