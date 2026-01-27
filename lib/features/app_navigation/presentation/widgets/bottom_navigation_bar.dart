import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Map<int, bool>? badgeIndicators; // Mapa de índice -> mostrar badge

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.badgeIndicators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final unselectedItemColor = colorScheme.onPrimary.withOpacity(0.6); // Cor do item não selecionado
    final surface = colorScheme.surface;
    final errorColor = colorScheme.error;
    
    // Criar items com badges se necessário
    final itemsWithBadges = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final showBadge = badgeIndicators?[index] ?? false;
      
      if (showBadge) {
        return BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              item.icon,
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          activeIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              item.activeIcon,
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          label: item.label,
          tooltip: item.tooltip,
        );
      }
      return item;
    }).toList();
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedLabelStyle: textTheme.bodySmall?.copyWith(
        fontSize: calculateFontSize(14),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.bodySmall?.copyWith(
        fontSize: calculateFontSize(10),
      ),
      selectedItemColor: onPrimaryContainer,
      unselectedItemColor: unselectedItemColor,
      backgroundColor: surface,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
      items: itemsWithBadges,
    );
  }
}