import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {

  const BackButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerHighestColor = colorScheme.surfaceContainerHighest;
    final iconColor = colorScheme.onSurface;
    return Positioned(
      top: DSSize.height(0),
      left: DSSize.width(0),
      child: CircleAvatar(
        backgroundColor: surfaceContainerHighestColor,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
