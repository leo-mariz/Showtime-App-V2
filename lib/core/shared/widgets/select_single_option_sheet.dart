import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Sheet para seleção de uma única opção (estilo igual ao de talentos).
/// Usado ex.: tipo de conjunto (Orquestra, Banda, etc.).
class SelectSingleOptionSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> options;
  final String? initialSelected;
  final String confirmButtonLabel;
  final void Function(String? selected) onConfirm;

  const SelectSingleOptionSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    this.initialSelected,
    this.confirmButtonLabel = 'Confirmar',
    required this.onConfirm,
  });

  @override
  State<SelectSingleOptionSheet> createState() => _SelectSingleOptionSheetState();
}

class _SelectSingleOptionSheetState extends State<SelectSingleOptionSheet> {
  String? _selected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.options
        : widget.options
            .where((name) => name.toLowerCase().contains(query))
            .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(
                top: DSSize.height(12),
                bottom: DSSize.height(8),
              ),
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            DSSizedBoxSpacing.vertical(8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
              child: Text(
                widget.subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          DSSizedBoxSpacing.vertical(12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSSize.width(8)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DSSize.width(12),
                  vertical: DSSize.height(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          DSSizedBoxSpacing.vertical(12),
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(DSSize.width(24)),
                    child: Center(
                      child: Text(
                        query.isEmpty
                            ? 'Nenhuma opção disponível.'
                            : 'Nenhum resultado para "$query".',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : Theme(
                    data: theme.copyWith(
                      radioTheme: RadioThemeData(
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.onPrimaryContainer;
                          }
                          return colorScheme.onSurfaceVariant;
                        }),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
                      child: Column(
                        children: filtered.map((option) {
                          return RadioListTile<String>(
                            value: option,
                            groupValue: _selected,
                            onChanged: (value) =>
                                setState(() => _selected = value),
                            title: Text(
                              option,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              DSSize.width(24),
              DSSize.height(16),
              DSSize.width(24),
              DSSize.height(24) + MediaQuery.of(context).padding.bottom,
            ),
            child: CustomButton(
              label: widget.confirmButtonLabel,
              onPressed: () => widget.onConfirm(_selected),
              backgroundColor: colorScheme.onPrimaryContainer,
              textColor: colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
