import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Valores aplicados no modal de filtros do Explorar.
class ExploreFilterValues {
  final List<String> selectedTalentNames;
  final double? minPrice;
  final double? maxPrice;
  final int? minDurationMinutes;

  const ExploreFilterValues({
    this.selectedTalentNames = const [],
    this.minPrice,
    this.maxPrice,
    this.minDurationMinutes,
  });

  bool get hasAnyFilter =>
      selectedTalentNames.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      minDurationMinutes != null;
}

/// Modal de filtros do Explorar: talentos, faixa de preço e duração mínima.
class ExploreFilterModal extends StatefulWidget {
  /// Lista de talentos disponíveis (ex.: da AppList) para exibir como chips.
  final List<String> talentOptions;
  /// Valores iniciais (ex.: filtros já aplicados).
  final ExploreFilterValues initialValues;
  /// Limites opcionais de preço para o contexto (ex.: min/max do dia).
  final double? suggestedMinPrice;
  final double? suggestedMaxPrice;

  const ExploreFilterModal({
    super.key,
    required this.talentOptions,
    this.initialValues = const ExploreFilterValues(),
    this.suggestedMinPrice,
    this.suggestedMaxPrice,
  });

  static Future<ExploreFilterValues?> show({
    required BuildContext context,
    required List<String> talentOptions,
    ExploreFilterValues initialValues = const ExploreFilterValues(),
    double? suggestedMinPrice,
    double? suggestedMaxPrice,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<ExploreFilterValues>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => ExploreFilterModal(
        talentOptions: talentOptions,
        initialValues: initialValues,
        suggestedMinPrice: suggestedMinPrice,
        suggestedMaxPrice: suggestedMaxPrice,
      ),
    );
  }

  @override
  State<ExploreFilterModal> createState() => _ExploreFilterModalState();
}

class _ExploreFilterModalState extends State<ExploreFilterModal> {
  late Set<String> _selectedTalents;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  int? _minDurationMinutes;

  static const List<int> _durationOptions = [30, 60, 90, 120, 150, 180, 240, 300];

  @override
  void initState() {
    super.initState();
    _selectedTalents = Set.from(widget.initialValues.selectedTalentNames);
    _minPriceController = TextEditingController(
      text: widget.initialValues.minPrice != null
          ? widget.initialValues.minPrice!.toStringAsFixed(0)
          : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialValues.maxPrice != null
          ? widget.initialValues.maxPrice!.toStringAsFixed(0)
          : '',
    );
    _minDurationMinutes = widget.initialValues.minDurationMinutes;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final minP = double.tryParse(_minPriceController.text.replaceAll(',', '.'));
    final maxP = double.tryParse(_maxPriceController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(ExploreFilterValues(
      selectedTalentNames: _selectedTalents.toList(),
      minPrice: minP,
      maxPrice: maxP,
      minDurationMinutes: _minDurationMinutes,
    ));
  }

  void _clear() {
    setState(() {
      _selectedTalents.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minDurationMinutes = null;
    });
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Text(
            'Filtros',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(20),

          // Talentos
          Text(
            'Talento',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          if (widget.talentOptions.isEmpty)
            Text(
              'Nenhum talento disponível',
              style: textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
            )
          else
            Wrap(
              spacing: DSSize.width(8),
              runSpacing: DSSize.height(8),
              children: widget.talentOptions.map((name) {
                final selected = _selectedTalents.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) _selectedTalents.add(name);
                      else _selectedTalents.remove(name);
                    });
                  },
                  selectedColor: colorScheme.primaryContainer.withOpacity(0.6),
                  checkmarkColor: colorScheme.onPrimaryContainer,
                );
              }).toList(),
            ),
          DSSizedBoxSpacing.vertical(20),

          // Preço (mín e máx)
          Text(
            r'Preço (R$/hora)',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
                  decoration: InputDecoration(
                    hintText: 'Mín',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(8)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DSSize.width(12),
                      vertical: DSSize.height(12),
                    ),
                  ),
                ),
              ),
              DSSizedBoxSpacing.horizontal(12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
                  decoration: InputDecoration(
                    hintText: 'Máx',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(8)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DSSize.width(12),
                      vertical: DSSize.height(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(20),

          // Duração mínima do show
          Text(
            'Duração mínima do show',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          DropdownButtonFormField<int>(
            value: _minDurationMinutes,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSSize.width(8)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: DSSize.width(12),
                vertical: DSSize.height(12),
              ),
            ),
            hint: const Text('Qualquer'),
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('Qualquer')),
              ..._durationOptions.map(
                (m) => DropdownMenuItem<int>(
                  value: m,
                  child: Text(_formatDuration(m)),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _minDurationMinutes = v),
          ),
          DSSizedBoxSpacing.vertical(24),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Limpar',
                  filled: false,
                  textColor: onPrimary,
                  onPressed: _clear,
                ),
              ),
              DSSizedBoxSpacing.horizontal(12),
              Expanded(
                child: CustomButton(
                  label: 'Aplicar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
