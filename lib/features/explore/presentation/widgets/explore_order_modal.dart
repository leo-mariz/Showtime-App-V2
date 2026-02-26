import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Opções de ordenação no Explorar.
enum ExploreOrderOption {
  rating,
  contractCount,
  alphabetical,
  priceLowToHigh,
  priceHighToLow,
}

extension ExploreOrderOptionDisplay on ExploreOrderOption {
  String get label {
    switch (this) {
      case ExploreOrderOption.rating:
        return 'Avaliação';
      case ExploreOrderOption.contractCount:
        return 'Número de contratos';
      case ExploreOrderOption.alphabetical:
        return 'Ordem alfabética';
      case ExploreOrderOption.priceLowToHigh:
        return 'Preço (menor ao maior)';
      case ExploreOrderOption.priceHighToLow:
        return 'Preço (maior ao menor)';
    }
  }

  IconData get icon {
    switch (this) {
      case ExploreOrderOption.rating:
        return Icons.star_rounded;
      case ExploreOrderOption.contractCount:
        return Icons.description_rounded;
      case ExploreOrderOption.alphabetical:
        return Icons.sort_by_alpha_rounded;
      case ExploreOrderOption.priceLowToHigh:
        return Icons.arrow_upward_rounded;
      case ExploreOrderOption.priceHighToLow:
        return Icons.arrow_downward_rounded;
    }
  }
}

/// Modal de ordenação do Explorar.
class ExploreOrderModal extends StatelessWidget {
  /// Ordenação atualmente selecionada (opcional).
  final ExploreOrderOption? initialOrder;

  const ExploreOrderModal({
    super.key,
    this.initialOrder,
  });

  static Future<ExploreOrderOption?> show({
    required BuildContext context,
    ExploreOrderOption? initialOrder,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<ExploreOrderOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => ExploreOrderModal(initialOrder: initialOrder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Container(
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
            'Ordenar por',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          ...ExploreOrderOption.values.map((option) {
            final isSelected = initialOrder == option;
            return Padding(
              padding: EdgeInsets.only(bottom: DSSize.height(8)),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(option),
                borderRadius: BorderRadius.circular(DSSize.width(12)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSize.width(16),
                    vertical: DSSize.height(14),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer.withOpacity(0.5)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primaryContainer,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        size: DSSize.width(22),
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : onSurfaceVariant,
                      ),
                      DSSizedBoxSpacing.horizontal(12),
                      Expanded(
                        child: Text(
                          option.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : onPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: DSSize.width(20),
                          color: colorScheme.onPrimaryContainer,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          DSSizedBoxSpacing.vertical(16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Fechar',
              filled: false,
              textColor: onPrimary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
