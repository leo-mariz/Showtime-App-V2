import 'dart:io';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

/// Dialog para confirmar a foto de perfil selecionada
class PhotoConfirmationDialog extends StatelessWidget {
  final File imageFile;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const PhotoConfirmationDialog({
    super.key,
    required this.imageFile,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSSize.width(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(DSSize.width(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Foto de perfil',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),

            DSSizedBoxSpacing.vertical(16),

            // Subtítulo
            Text(
              'Esta será sua nova foto de perfil',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            DSSizedBoxSpacing.vertical(24),

            // Preview da imagem em formato circular
            Container(
              width: DSSize.width(120),
              height: DSSize.height(120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.file(
                  imageFile,
                  width: DSSize.width(120),
                  height: DSSize.height(120),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: DSSize.width(40),
                      ),
                    );
                  },
                ),
              ),
            ),

            DSSizedBoxSpacing.vertical(32),

            // Botões de ação
            Row(
              children: [
                // Botão Cancelar
                Expanded(
                  child: DialogButton.text(
                    text: 'Cancelar',
                    foregroundColor: Theme.of(context).colorScheme.error,
                    onPressed: onCancel,
                  ),
                ),

                DSSizedBoxSpacing.horizontal(16),

                // Botão Confirmar
                Expanded(
                  child: DialogButton.primary(
                    text: 'Confirmar',
                    backgroundColor: colorScheme.onPrimaryContainer,
                    onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Método estático para mostrar o dialog
  static Future<bool?> show(
    BuildContext context, {
    required File imageFile,
  }) async {
    final router = AutoRouter.of(context);
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhotoConfirmationDialog(
        imageFile: imageFile,
        onConfirm: () => router.maybePop(true),
        onCancel: () => router.maybePop(false),
      ),
    );
  }
}
