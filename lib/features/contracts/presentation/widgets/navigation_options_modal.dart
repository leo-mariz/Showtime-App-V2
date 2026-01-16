import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal para escolher o aplicativo de navegação (Maps ou Waze)
class NavigationOptionsModal {
  /// Exibe o modal com opções de navegação
  static Future<void> show({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? addressLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NavigationOptionsModalContent(
        latitude: latitude,
        longitude: longitude,
        addressLabel: addressLabel,
      ),
    );
  }
}

class _NavigationOptionsModalContent extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? addressLabel;

  const _NavigationOptionsModalContent({
    required this.latitude,
    required this.longitude,
    this.addressLabel,
  });

  Future<void> _openMaps() async {
    // URL do Google Maps
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o Google Maps');
      }
    } catch (e) {
      // Se falhar, tenta abrir com o app nativo do Maps (iOS)
      final nativeUrl = Uri.parse('maps://?q=$latitude,$longitude');
      try {
        if (await canLaunchUrl(nativeUrl)) {
          await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Não foi possível abrir o aplicativo de mapas');
        }
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> _openWaze() async {
    // URL do Waze
    final url = Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Se o app do Waze não estiver instalado, tenta abrir na web
        final webUrl = Uri.parse(
          'https://www.waze.com/ul?ll=$latitude,$longitude&navigate=yes',
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Não foi possível abrir o Waze');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(DSSize.width(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Como chegar',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(16),
              
              // Endereço (se fornecido)
              if (addressLabel != null && addressLabel!.isNotEmpty) ...[
                Text(
                  addressLabel!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                DSSizedBoxSpacing.vertical(16),
              ],
              
              // Opções de navegação
              _NavigationOption(
                icon: Icons.map_rounded,
                title: 'Google Maps',
                subtitle: 'Abrir no Google Maps',
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await _openMaps();
                  } catch (e) {
                    if (context.mounted) {
                      context.showError('Não foi possível abrir o Google Maps');
                    }
                  }
                },
              ),
              
              DSSizedBoxSpacing.vertical(12),
              
              _NavigationOption(
                icon: Icons.navigation_rounded,
                title: 'Waze',
                subtitle: 'Abrir no Waze',
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await _openWaze();
                  } catch (e) {
                    if (context.mounted) {
                      context.showError('Não foi possível abrir o Waze');
                    }
                  }
                },
              ),
              
              DSSizedBoxSpacing.vertical(16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSSize.width(12)),
      child: Container(
        padding: EdgeInsets.all(DSSize.width(16)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(DSSize.width(12)),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DSSize.width(12)),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(8)),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: DSSize.width(24),
              ),
            ),
            DSSizedBoxSpacing.horizontal(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
