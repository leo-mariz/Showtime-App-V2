import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatelessWidget {
  final GroupEntity group;
  final bool isAdmin; // Se o artista atual é administrador
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.isAdmin = false,
    required this.onTap,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  int _getMembersCount() {
    return group.members?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          // Foto do grupo
          Container(
            width: DSSize.width(64),
            height: DSSize.width(64),
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
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.group_outlined,
                        color: colorScheme.onPrimaryContainer,
                        size: DSSize.width(32),
                      ),
                    ),
                  )
                : Icon(
                    Icons.group_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: DSSize.width(32),
                  ),
          ),
          DSSizedBoxSpacing.horizontal(16),
          
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.groupName ?? 'Sem nome',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      DSSizedBoxSpacing.horizontal(8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DSSize.width(8),
                          vertical: DSSize.height(4),
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(DSSize.width(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: DSSize.width(12),
                              color: colorScheme.primaryContainer,
                            ),
                            DSSizedBoxSpacing.horizontal(4),
                            Text(
                              'Admin',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                DSSizedBoxSpacing.vertical(4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: DSSize.width(16),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    DSSizedBoxSpacing.horizontal(4),
                    Text(
                      '${_getMembersCount()} integrante${_getMembersCount() != 1 ? 's' : ''}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                DSSizedBoxSpacing.vertical(4),
                Text(
                  'Criado em ${_formatDate(group.dateRegistered)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Seta
          Icon(
            Icons.arrow_forward_ios,
            size: DSSize.width(16),
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

