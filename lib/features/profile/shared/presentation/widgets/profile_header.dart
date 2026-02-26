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
  /// Quando true, exibe um ícone de alerta (!) no canto superior direito do avatar (ex.: foto incompleta).
  final bool showPhotoIncompleteBadge;
  /// Avaliação (ex.: 4.5). Se null ou sem avaliações, não exibe nada no header.
  final double? rating;
  /// Quantidade de avaliações. Opcional, usado junto com [rating] para exibir "4.5 ★ (12 avaliações)".
  final int? rateCount;

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
    this.showPhotoIncompleteBadge = false,
    this.rating,
    this.rateCount,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                CustomCircleAvatar(
                  imageUrl: imageUrl,
                  onEdit: onProfilePictureTap,
                  isLoading: isLoadingProfilePicture,
                  size: DSSize.width(80),
                  showCameraIcon: true,
                ),
                if (showPhotoIncompleteBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: DSSize.width(24),
                      height: DSSize.width(24),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.error_outline,
                        size: DSSize.width(16),
                        color: colorScheme.onError,
                      ),
                    ),
                  ),
              ],
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
                // Rating: só exibe se houver avaliação (rating > 0 ou rateCount > 0)
                if (rating != null && (rating! > 0 || (rateCount != null && rateCount! > 0))) ...[
                  DSSizedBoxSpacing.vertical(0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: DSSize.width(18),
                        color: colorScheme.onPrimaryContainer,
                      ),
                      SizedBox(width: DSSize.width(4)),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      // if (rateCount != null && rateCount! > 0) ...[
                      //   SizedBox(width: DSSize.width(6)),
                      //   Text(
                      //     '($rateCount ${rateCount == 1 ? 'avaliação' : 'avaliações'})',
                      //     style: theme.textTheme.bodySmall?.copyWith(
                      //       color: colorScheme.onSurface.withOpacity(0.7),
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ],
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