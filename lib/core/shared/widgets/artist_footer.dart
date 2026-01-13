import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Footer fixo com botão de solicitar
class ArtistFooter extends StatelessWidget {
  final VoidCallback onRequestPressed;

  const ArtistFooter({
    super.key,
    required this.onRequestPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(DSSize.width(16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: DSSize.width(10),
            offset: Offset(0, -DSSize.height(2)),
          ),
        ],
      ),
      child: CustomButton(
          label: 'Solicitar',
          onPressed: onRequestPressed,
          icon: Icons.send,
          iconOnRight: true,
        ),
      
    );
  }
}

