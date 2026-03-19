import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

/// Legenda do calendário de disponibilidade.
///
/// Explica os ícones exibidos nos dias: intervalos disponíveis, fechado,
/// indisponível (desativado) e shows confirmados.
/// Usado no bottom sheet da tela de calendário (artista e conjunto).
class CalendarLegendWidget extends StatelessWidget {
  const CalendarLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSecondaryContainer = colorScheme.onSecondaryContainer;
    final error = colorScheme.error;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    const showColor = Colors.yellow;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.all(DSSize.width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Text(
            'Legenda',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: DSSize.height(8)),
          Text(
            'Entenda os ícones do calendário',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DSSize.height(24)),
          _buildLegendItem(
            icon: Icons.check_circle,
            label: 'Disponível',
            description: 'Possui intervalos de horário livres.',
            color: onSecondaryContainer,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: DSSize.height(16)),
          _buildLegendItem(
            icon: Icons.circle,
            label: 'Indisponível',
            description: 'Disponibilidade desativada',
            color: error,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: DSSize.height(16)),
          _buildLegendItem(
            icon: Icons.star,
            label: 'Shows',
            description: 'Número de apresentações confirmadas',
            color: showColor,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: DSSize.height(16)),
          _buildLegendItem(
            label: 'Sem horários cadastrados',
            description: 'Dias que não contêm nenhum ícone são dias sem horários cadastrados.',
            color: onSurfaceVariant,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: DSSize.height(24)),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    IconData? icon,
    required String label,
    required String description,
    required Color color,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      children: [
        Container(
          width: DSSize.width(40),
          height: DSSize.width(40),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DSSize.width(8)),
          ),
          child: icon != null ? Icon(
            icon,
              size: DSSize.width(20),
              color: color,
            ) : null,
        ),
        SizedBox(width: DSSize.width(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: DSSize.height(2)),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
