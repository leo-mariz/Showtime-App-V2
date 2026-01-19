import 'package:flutter/material.dart';

/// Widget para célula de dia no calendário
/// 
/// Mostra indicadores visuais baseado no estado do dia
class DayCellWidget extends StatelessWidget {
  final DateTime day;
  final Map<String, dynamic>? dayState;
  final bool isToday;
  final bool isSelected;

  const DayCellWidget({
    super.key,
    required this.day,
    this.dayState,
    this.isToday = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvailability = dayState?['hasAvailability'] ?? false;
    final isPartial = dayState?['isPartial'] ?? false;
    final isBlocked = dayState?['isBlocked'] ?? false;
    final isCustom = dayState?['isCustom'] ?? false;

    // Definir cor do indicador
    Color? indicatorColor;
    IconData? indicatorIcon;
    
    if (isBlocked) {
      indicatorColor = Colors.red.shade400;
      indicatorIcon = Icons.block;
    } else if (isPartial) {
      indicatorColor = Colors.orange.shade400;
      indicatorIcon = Icons.access_time;
    } else if (hasAvailability) {
      indicatorColor = isCustom ? Colors.purple.shade400 : Colors.green.shade400;
      indicatorIcon = isCustom ? Icons.star : Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : null,
        border: isToday
            ? Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Número do dia
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? Theme.of(context).primaryColor
                    : null,
              ),
            ),
          ),
          
          // Indicador visual
          if (indicatorColor != null && indicatorIcon != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Icon(
                indicatorIcon,
                size: 16,
                color: indicatorColor,
              ),
            ),
        ],
      ),
    );
  }
}
