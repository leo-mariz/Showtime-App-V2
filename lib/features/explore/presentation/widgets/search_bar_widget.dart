import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final IconData searchIcon;
  final IconData clearIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.searchIcon = Icons.search,
    this.clearIcon = Icons.clear,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surfaceContainerHighest; // Cor de fundo do campo
    final hintColor = colorScheme.onSurfaceVariant; // Cor do hint text
    final searchIconColor = iconColor ?? colorScheme.onSurface; // Cor do ícone de busca

    return Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16), // Deixa a barra arredondada
        ),
        height: 48,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: hintColor), // Estilo do hint text
            prefixIcon: Icon(searchIcon, color: searchIconColor), // Ícone de busca
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(clearIcon, color: searchIconColor), // Ícone de limpar
                    onPressed: () {
                      controller.clear();
                      if (onClear != null) {
                        onClear!();
                      }
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        )
      );
  }
}
