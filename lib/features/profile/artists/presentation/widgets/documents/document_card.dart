import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final DocumentsEntity document;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.title,
    required this.document,
    required this.onTap,
  });

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Não enviado';
      case 1:
        return 'Em análise';
      case 2:
        return 'Aprovado';
      case 3:
        return 'Rejeitado';
      default:
        return 'Não enviado';
    }
  }

  Color _getStatusColor(int status, ColorScheme colorScheme) {
    switch (status) {
      case 0:
        return colorScheme.onSurfaceVariant.withOpacity(0.6);
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant.withOpacity(0.6);
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.upload_outlined;
      case 1:
        return Icons.hourglass_empty;
      case 2:
        return Icons.check_circle_outline;
      case 3:
        return Icons.error_outline;
      default:
        return Icons.upload_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDocument = document.url != null && document.url!.isNotEmpty;
    final statusText = _getStatusText(document.status);
    final statusColor = _getStatusColor(document.status, colorScheme);
    final statusIcon = _getStatusIcon(document.status);

    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          // Ícone do documento
          Container(
            width: DSSize.width(48),
            height: DSSize.width(48),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DSSize.width(12)),
            ),
            child: Icon(
              hasDocument ? Icons.description : Icons.upload_outlined,
              color: colorScheme.onPrimaryContainer,
              size: DSSize.width(24),
            ),
          ),
          DSSizedBoxSpacing.horizontal(16),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                if (document.documentOption != null && document.documentOption!.isNotEmpty) ...[
                  Text(
                    document.documentOption!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(4),
                ],
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: DSSize.width(16),
                      color: statusColor,
                    ),
                    DSSizedBoxSpacing.horizontal(4),
                    Text(
                      statusText,
                      style: textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

