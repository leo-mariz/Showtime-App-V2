import 'package:flutter/material.dart';

/// Legenda do calendário
/// 
/// Explica os indicadores visuais
class CalendarLegendWidget extends StatelessWidget {
  const CalendarLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(
          icon: Icons.check_circle,
          color: Colors.green.shade400,
          label: 'Disponível',
        ),
        _buildLegendItem(
          icon: Icons.star,
          color: Colors.purple.shade400,
          label: 'Customizado',
        ),
        _buildLegendItem(
          icon: Icons.access_time,
          color: Colors.orange.shade400,
          label: 'Parcial',
        ),
        _buildLegendItem(
          icon: Icons.block,
          color: Colors.red.shade400,
          label: 'Bloqueado',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
