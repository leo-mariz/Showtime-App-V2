import 'package:flutter/material.dart';
import 'package:app/core/shared/widgets/selection_modal.dart';

/// Opções disponíveis para a imagem de perfil
enum ProfilePictureOption {
  view,
  gallery,
  camera,
  remove,
}

/// Widget que exibe as opções de ação para a foto de perfil
class ProfilePictureOptionsMenu {
  /// Método estático para mostrar o modal
  static Future<ProfilePictureOption?> show(
    BuildContext context, {
    required bool hasImage,
  }) async {
    final options = <SelectionModalOption<ProfilePictureOption>>[];

    // Visualizar imagem (só aparece se tem imagem)
    if (hasImage) {
      options.add(
        SelectionModalOption<ProfilePictureOption>(
          icon: Icons.visibility,
          title: 'Visualizar imagem',
          value: ProfilePictureOption.view,
        ),
      );
    }

    // Escolher da galeria
    options.add(
      SelectionModalOption<ProfilePictureOption>(
        icon: Icons.photo_library,
        title: 'Escolher da galeria',
        value: ProfilePictureOption.gallery,
      ),
    );

    // Tirar foto
    options.add(
      SelectionModalOption<ProfilePictureOption>(
        icon: Icons.camera_alt,
        title: 'Tirar foto',
        value: ProfilePictureOption.camera,
      ),
    );

    // Remover imagem (só aparece se tem imagem)
    if (hasImage) {
      options.add(
        SelectionModalOption<ProfilePictureOption>(
          icon: Icons.delete,
          title: 'Remover imagem',
          value: ProfilePictureOption.remove,
          isDestructive: true,
        ),
      );
    }

    return SelectionModal.show<ProfilePictureOption>(
      context: context,
      title: 'Foto de perfil',
      options: options,
      showCancelButton: false, // Não mostrar botão cancelar para manter compatibilidade
    );
  }
}
