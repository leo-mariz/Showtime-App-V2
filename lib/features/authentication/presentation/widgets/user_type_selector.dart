import 'package:app/core/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Widget para seleção do tipo de usuário (Artista ou Anfitrião) usando Radio buttons
class UserTypeSelector extends StatelessWidget {
  final UserType selectedType;
  final ValueChanged<UserType> onChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Converte UserType para bool (true = artist, false = host)
    final bool isArtist = selectedType == UserType.artist;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Anfitrião
        Radio<bool>(
          value: false,
          groupValue: isArtist,
          onChanged: (value) {
            if (value != null) {
              onChanged(UserType.host);
            }
          },
          activeColor: colorScheme.onPrimaryContainer,
        ),
        DSSizedBoxSpacing.horizontal(5),
        GestureDetector(
          onTap: () => onChanged(UserType.host),
          child: Text(
            'Anfitrião',
            style: theme.textTheme.bodySmall,
          ),
        ),
        
        DSSizedBoxSpacing.horizontal(60),
        
        // Artista
        Radio<bool>(
          value: true,
          groupValue: isArtist,
          onChanged: (value) {
            if (value != null) {
              onChanged(UserType.artist);
            }
          },
          activeColor: colorScheme.onPrimaryContainer,
        ),
        DSSizedBoxSpacing.horizontal(5),
        GestureDetector(
          onTap: () => onChanged(UserType.artist),
          child: Text(
            'Artista',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

