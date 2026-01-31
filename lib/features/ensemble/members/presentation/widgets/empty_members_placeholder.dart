import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';

/// Placeholder de UI pura para lista vazia de integrantes.
class EmptyMembersPlaceholder extends StatelessWidget {
  final String message;

  const EmptyMembersPlaceholder({
    super.key,
    this.message = 'Nenhum integrante adicionado.',
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
            Icons.person_add_alt_1_outlined,
            size: DSSize.width(64),
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
        ],
      ),
    );
  }
}
