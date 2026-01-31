import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class ProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isArtist;
  final bool isGroup;
  final VoidCallback? onProfilePictureTap;
  final bool isLoadingProfilePicture;
  final VoidCallback? onSwitchUserType;
  final VoidCallback? onEditName;

  const ProfileHeader({
    super.key,
    this.imageUrl,
    required this.name,
    required this.isArtist,
    this.isGroup = false,
    this.onProfilePictureTap,
    this.isLoadingProfilePicture = false,
    this.onSwitchUserType,
    this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomCircleAvatar(
              imageUrl: imageUrl,
              onEdit: onProfilePictureTap,
              isLoading: isLoadingProfilePicture,
              size: DSSize.width(80),
              showCameraIcon: true,
            ),   
            DSSizedBoxSpacing.horizontal(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                      
                    ),
                    if (onEditName != null) ...[
                      DSSizedBoxSpacing.horizontal(8),
                      InkWell(
                        onTap: onEditName,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(DSSize.width(4)),
                          child: Icon(
                            Icons.edit_outlined,
                            size: DSSize.width(18),
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              
                DSSizedBoxSpacing.vertical(4),
                Row(
                  children: [
                    // Card do tipo atual
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DSSize.width(12),
                        vertical: DSSize.height(4),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(DSSize.width(12)),
                      ),
                      child: Text(
                        isArtist ? 'Artista' : isGroup ? 'Conjunto' : 'Anfitrião',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),

                      ), 
                    ),
                    // Seta clicável
                    if (onSwitchUserType != null) ...[
                      InkWell(
                        onTap: onSwitchUserType,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(DSSize.width(4)),
                          child: Icon(
                            Icons.swap_horiz,
                            size: DSSize.width(20),
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      // Card do tipo oposto (mais opaco)
                      Text(
                        isArtist ? 'Anfitrião' : 'Artista',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
             ),
             
            ],
        ),
        
      ],
    );
  } 
}