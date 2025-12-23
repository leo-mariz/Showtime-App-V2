import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final String title;
  final String street;
  final String district;
  final String number;
  final String? complement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelected;

  const AddressCard({
    super.key,
    required this.title,
    required this.street,
    required this.district,
    required this.number,
    this.complement,
    required this.onEdit,
    required this.onDelete,
    this.isSelected = false,
  });

  void _showOptionsModal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final primaryContainer = colorScheme.primaryContainer;
    final onError = colorScheme.onError;
    final error = colorScheme.error;
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceContainerHighest,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DSSize.width(20)),
            topRight: Radius.circular(DSSize.width(20)),
          ),
        ),
        padding: EdgeInsets.all(DSSize.width(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
            // Título do endereço
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
            DSSizedBoxSpacing.vertical(24),
            // Botões Excluir e Editar lado a lado
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Excluir',
                    icon: Icons.delete_forever,
                    iconOnLeft: true,
                    iconColor: onError,
                    backgroundColor: error.withOpacity(0.8),
                    textColor: onError,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ),
                DSSizedBoxSpacing.horizontal(12),
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: Icons.edit,
                    iconOnLeft: true,
                    iconColor: primaryContainer,
                    backgroundColor: onPrimaryContainer.withOpacity(0.8),
                    textColor: primaryContainer,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                  ),
                ),
              ],
            ),
            DSSizedBoxSpacing.vertical(12),
            // Botão Cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text('Cancelar', style: textTheme.bodyMedium?.copyWith(
                  color: onPrimary,
                )),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            DSSizedBoxSpacing.vertical(8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: onPrimaryContainer,
                    width: 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(DSSize.width(16)),
          ),
          child: CustomCard(
            padding: EdgeInsets.all(DSSize.width(8)),
            customBorderRadius: BorderRadius.circular(DSSize.width(8)),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ícone de localização (esquerda, centralizado verticalmente)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: DSSize.width(32),
                      color: onPrimaryContainer,
                    ),
                    DSSizedBoxSpacing.horizontal(16),
                    // Conteúdo do endereço
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onPrimary,
                          ),
                        ),
                        // Rua
                        Text(
                          street,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onPrimary.withOpacity(0.8),
                          ),
                        ),
                        // Bairro
                        Text(
                          district,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onPrimary.withOpacity(0.8),
                          ),
                        ),
                        // Número / Complemento
                        Text(
                          complement != null && complement!.isNotEmpty
                              ? '$number / $complement'
                              : number,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: onPrimaryContainer),
                    onPressed: () => _showOptionsModal(context),
                    iconSize: DSSize.width(24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Ícone de check no canto superior direito quando selecionado
        if (isSelected)
          Positioned(
            top: DSSize.height(8),
            right: DSSize.width(8),
            child: Container(
              padding: EdgeInsets.all(DSSize.width(4)),
              decoration: BoxDecoration(
                color: onPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: colorScheme.primaryContainer,
                size: DSSize.width(16),
              ),
            ),
          ),
      ],
    );
  }
}

