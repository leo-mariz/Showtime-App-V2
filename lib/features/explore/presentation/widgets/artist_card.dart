import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/favorite_button.dart';
import 'package:flutter/material.dart';

/// Card de artista na listagem
/// 
/// Exibe foto, informações, avaliação e botão de solicitar
class ArtistCard extends StatelessWidget {
  final String musicianName;
  final String genres;
  final String description;
  final int contracts;
  final double rating;
  final String? pricePerHour;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onHirePressed;
  final VoidCallback? onTap;
  final String artistId;
  
  const ArtistCard({
    super.key,
    required this.musicianName,
    required this.genres,
    required this.description,
    required this.contracts,
    required this.rating,
    this.pricePerHour,
    this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onHirePressed,
    this.onTap,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final Color onSurfaceVariantColor = colorScheme.onSurfaceVariant;
    final Color onPrimaryContainer = colorScheme.onPrimaryContainer;
    final Color primaryContainer = colorScheme.primaryContainer;
    
    final contractsText = contracts == 0 
        ? 'Sem contratos' 
        : 'Contratos: $contracts';
    final ratingText = rating == 0 
        ? 'Sem avaliações' 
        : rating.toStringAsFixed(1);

    return CustomCard(
      borderRadius: 12,
      margin: EdgeInsets.only(bottom: DSSize.height(16)),
      onTap: onTap,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e botão de favorito
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
                            Icons.person,
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
                                Icons.person,
                                size: DSSize.width(60),
                                color: onPrimaryContainer.withOpacity(0.5),
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: DSSize.height(4),
                  right: DSSize.width(4),
                  child: FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteToggle,
                      ),
                    
                  ),
              ],
            ),
            
            DSSizedBoxSpacing.vertical(8),
            
            // Nome do músico
            Text(
              musicianName,
              style: textTheme.titleMedium
            ),
            
            DSSizedBoxSpacing.vertical(2),
            
            // Gêneros musicais
            Text(
              genres,
              style: textTheme.bodySmall?.copyWith(
                color: onSurfaceVariantColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            DSSizedBoxSpacing.vertical(4),
            
            // Descrição (com limite de 2 linhas)
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: onSurfaceVariantColor,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            
            DSSizedBoxSpacing.vertical(8),
            
            // Contratos e avaliações
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
            
            DSSizedBoxSpacing.vertical(12),
            
            // Botão Solicitar
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

