import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color onSurfaceVariantColor = colorScheme.onSurfaceVariant;
    final Color onPrimaryContainer = colorScheme.onPrimaryContainer;
    final Color primaryContainer = colorScheme.primaryContainer;

    final contractsText =
        contracts == 0 ? 'Sem contratos' : 'Contratos: $contracts';
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
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          Text(
            groupName,
            style: textTheme.titleMedium,
          ),
          DSSizedBoxSpacing.vertical(2),
          Row(
            children: [
              Text(
                contractsText,
                style: textTheme.bodyMedium?.copyWith(
                  color: onPrimaryContainer,
                ),
              ),
              DSSizedBoxSpacing.horizontal(16),
              Visibility(
                visible: rating > 0,
                replacement: Text(
                  ratingText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: onPrimaryContainer,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: DSSize.width(16),
                    ),
                    DSSizedBoxSpacing.horizontal(4),
                    Text(
                      ratingText,
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
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
