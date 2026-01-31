import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Placeholder de UI pura para lista vazia de conjuntos.
/// Recebe apenas texto e callback opcional do botão.
class EmptyEnsemblesPlaceholder extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyEnsemblesPlaceholder({
    super.key,
    this.message = 'Você ainda não possui conjuntos cadastrados.',
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: DSSize.width(80),
            color: onPrimaryContainer,
          ),
          DSSizedBoxSpacing.vertical(16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          // if (buttonLabel != null && onButtonPressed != null) ...[
          //   DSSizedBoxSpacing.vertical(24),
          //   CustomButton(
          //     label: buttonLabel!,
          //     onPressed: onButtonPressed,
          //     icon: Icons.add,
          //   ),
          // ],
        ],
      ),
    );
  }
}
