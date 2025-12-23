import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onError = colorScheme.onError;
    final error = colorScheme.error;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DSPadding.vertical(16)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout, color: onError),
          label: Text(
            'Sair',
            style: theme.textTheme.bodySmall?.copyWith(
              color: onError,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSSize.width(12)),
            ),
          ),
          onPressed: onLogout,
        ),
      ),
    );
  }
}