import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Sheet reutilizável para seleção de talentos (checkbox + busca).
/// Usado em: dados profissionais do artista, talentos do integrante no ensemble.
class SelectTalentsSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> talentNames;
  final List<String> initialSelected;
  final bool loading;
  final String confirmButtonLabel;
  final void Function(List<String> selected) onConfirm;

  const SelectTalentsSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.talentNames,
    required this.initialSelected,
    this.loading = false,
    this.confirmButtonLabel = 'Salvar',
    required this.onConfirm,
  });

  @override
  State<SelectTalentsSheet> createState() => _SelectTalentsSheetState();
}

class _SelectTalentsSheetState extends State<SelectTalentsSheet> {
  late Set<String> _selected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelected);
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
        ? widget.talentNames
        : widget.talentNames
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
                hintText: 'Buscar talento...',
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
            child: widget.talentNames.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(DSSize.width(24)),
                    child: Center(
                      child: Text(
                        'Nenhum talento disponível.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(DSSize.width(24)),
                        child: Center(
                          child: Text(
                            'Nenhum talento encontrado para "$query".',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: filtered.map((name) {
                            final isSelected = _selected.contains(name);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selected.add(name);
                                  } else {
                                    _selected.remove(name);
                                  }
                                });
                              },
                              title: Text(
                                name,
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              DSSize.width(24),
              DSSize.height(16),
              DSSize.width(24),
              DSSize.height(24) + MediaQuery.of(context).padding.bottom,
            ),
            child: CustomButton(
              label: widget.loading ? 'Salvando...' : widget.confirmButtonLabel,
              isLoading: widget.loading,
              onPressed: widget.loading
                  ? null
                  : () => widget.onConfirm(_selected.toList()..sort()),
              backgroundColor: colorScheme.onPrimaryContainer,
              textColor: colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
