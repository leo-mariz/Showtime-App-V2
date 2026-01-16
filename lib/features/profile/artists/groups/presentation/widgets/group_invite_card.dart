import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GroupInviteCard extends StatelessWidget {
  final GroupEntity group;
  final String? invitedBy; // Nome de quem convidou
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const GroupInviteCard({
    super.key,
    required this.group,
    this.invitedBy,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto do grupo
              Container(
                width: DSSize.width(56),
                height: DSSize.width(56),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DSSize.width(12)),
                ),
                child: group.profilePicture != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(DSSize.width(12)),
                        child: CachedNetworkImage(
                          imageUrl: group.profilePicture!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CustomLoadingIndicator(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.group_outlined,
                            color: colorScheme.onPrimaryContainer,
                            size: DSSize.width(28),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.group_outlined,
                        color: colorScheme.onPrimaryContainer,
                        size: DSSize.width(28),
                      ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              
              // Nome do grupo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName ?? 'Sem nome',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(4),
                    Text(
                      invitedBy != null
                          ? 'Convite de $invitedBy'
                          : 'Convite para participar',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          DSSizedBoxSpacing.vertical(16),
          
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Recusar',
                  buttonType: CustomButtonType.cancel,
                  onPressed: onReject,
                  height: 40,
                ),
              ),
              DSSizedBoxSpacing.horizontal(12),
              Expanded(
                child: CustomButton(
                  label: 'Aceitar',
                  onPressed: onAccept,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

