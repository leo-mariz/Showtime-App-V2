import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

/// Header do grupo com foto e nome editáveis
class GroupHeader extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final VoidCallback? onProfilePictureTap;
  final bool isLoadingProfilePicture;
  final VoidCallback? onEditName;

  const GroupHeader({
    super.key,
    this.imageUrl,
    required this.name,
    this.onProfilePictureTap,
    this.isLoadingProfilePicture = false,
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
              ],
            ),
          ],
        ),
      ],
    );
  }
}
