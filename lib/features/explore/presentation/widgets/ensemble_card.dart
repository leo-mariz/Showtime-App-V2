import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_badge.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/favorite_button.dart';
import 'package:app/core/shared/widgets/genre_chip.dart';
import 'package:flutter/material.dart';

/// Card de conjunto na listagem do explorar.
/// Espelho visual de [ArtistCard] para conjuntos.
class EnsembleCard extends StatelessWidget {
  final String groupName;
  final int totalMembers;
  final String talents;
  final String description;
  final int contracts;
  final double rating;
  final String? pricePerHour;
  final String? imageUrl;
  final VoidCallback onHirePressed;
  final VoidCallback? onTap;
  final String ensembleId;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const EnsembleCard({
    super.key,
    required this.groupName,
    required this.totalMembers,
    required this.talents,
    required this.description,
    required this.contracts,
    required this.rating,
    this.pricePerHour,
    this.imageUrl,
    required this.onHirePressed,
    this.onTap,
    required this.ensembleId,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color onSurfaceVariantColor = colorScheme.onSurfaceVariant;
    final Color onPrimaryContainer = colorScheme.onPrimaryContainer;
    final Color primaryContainer = colorScheme.primaryContainer;

    final contractsText =
        contracts == 0 ? '0' : 'Contratos: $contracts';
    final ratingText =
        rating == 0 ? 'Sem avaliações' : rating.toStringAsFixed(1);

    return CustomCard(
      borderRadius: 12,
      margin: EdgeInsets.only(bottom: DSSize.height(16)),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DSSize.width(12)),
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Container(
                        height: DSSize.height(150),
                        width: double.infinity,
                        color: colorScheme.surface.withOpacity(0.1),
                        child: Icon(
                          Icons.groups,
                          size: DSSize.width(60),
                          color: onPrimaryContainer.withOpacity(0.5),
                        ),
                      )
                    : Image.network(
                        imageUrl!,
                        height: DSSize.height(150),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: DSSize.height(150),
                            width: double.infinity,
                            color: colorScheme.surface.withOpacity(0.1),
                            child: Icon(
                              Icons.groups,
                              size: DSSize.width(60),
                              color: onPrimaryContainer.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
              ),
              if (onFavoriteToggle != null)
                Positioned(
                  top: DSSize.height(4),
                  right: DSSize.width(4),
                  child: FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onFavoriteToggle!,
                  ),
                ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          Text(
            groupName,
            style: textTheme.titleMedium,
          ),
          DSSizedBoxSpacing.vertical(4),
          Row(
            children: [
              CustomBadge(value: ratingText, icon: Icons.star, color: onPrimaryContainer, 
                valueStyle: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )
                ),
                DSSizedBoxSpacing.horizontal(8),
                CustomBadge(title: 'Contratos', value: contractsText, color: onPrimaryContainer, valueStyle: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                )
                ),          
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          // Wrap(
          //   spacing: DSSize.width(8),
          //   runSpacing: DSSize.height(8),
          //   children: [
          //     GenreChip(label: '$totalMembers Integrantes'),
          //   ],
          // ),
          // DSSizedBoxSpacing.vertical(4),
          if (talents.isNotEmpty) ...[
            Wrap(
              spacing: DSSize.width(8),
              runSpacing: DSSize.height(8),
              children: [
                for (final t in talents.split(', '))
                  GenreChip(label: t),
              ],
            )
          ],
          DSSizedBoxSpacing.vertical(16),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: onSurfaceVariantColor,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          DSSizedBoxSpacing.vertical(16),
          SizedBox(
            width: double.infinity,
            height: DSSize.height(40),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(onPrimaryContainer),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(16)),
                  ),
                ),
              ),
              onPressed: onHirePressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solicitar',
                    style: textTheme.labelMedium?.copyWith(
                      color: primaryContainer,
                    ),
                  ),
                  if (pricePerHour != null && pricePerHour!.isNotEmpty)
                    Text(
                      pricePerHour!,
                      style: textTheme.labelMedium?.copyWith(
                        color: primaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
