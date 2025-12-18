import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final unselectedItemColor = colorScheme.onPrimary.withOpacity(0.6); // Cor do item não selecionado
    final surface = colorScheme.surface;
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
      items: items,
    );
  }
}