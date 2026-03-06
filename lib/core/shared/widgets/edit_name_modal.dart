import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Modal reutilizável para edição de nome (artístico ou de conjunto).
/// Recebe o [title], o [field] (ex.: [ArtistNameField] ou [EnsembleNameField])
/// e o controle de [onSave], [isLoading] e [canSave] vindos do pai.
class EditNameModal extends StatelessWidget {
  final String title;
  final Widget field;
  final VoidCallback onSave;
  final bool isLoading;
  final bool canSave;

  const EditNameModal({
    super.key,
    required this.title,
    required this.field,
    required this.onSave,
    required this.isLoading,
    required this.canSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(48),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          field,
          DSSizedBoxSpacing.vertical(24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: isLoading ? 'Salvando...' : 'Salvar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: canSave ? onSave : null,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
