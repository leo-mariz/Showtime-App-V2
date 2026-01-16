import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';

/// Widget que exibe feedback visual de validação de documento (CPF/CNPJ)
/// 
/// Estados:
/// - null: Nenhuma validação realizada ainda
/// - loading: Validando documento
/// - available: Documento disponível (check verde)
/// - exists: Documento já existe (X vermelho)
class DocumentValidationIndicator extends StatelessWidget {
  final DocumentValidationStatus? status;
  final String? errorMessage;

  const DocumentValidationIndicator({
    super.key,
    this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (status!) {
      case DocumentValidationStatus.loading:
        return SizedBox(
          width: DSSize.width(20),
          height: DSSize.height(20),
          child: CustomLoadingIndicator(
            strokeWidth: 2,
            color: colorScheme.onPrimaryContainer,
          ),
        );
      case DocumentValidationStatus.available:
        return Icon(
          Icons.check_circle,
          color: Colors.green,
          size: DSSize.width(20),
        );
      case DocumentValidationStatus.exists:
        return Tooltip(
          message: errorMessage ?? 'Este documento já está em uso',
          child: Icon(
            Icons.cancel,
            color: colorScheme.onError,
            size: DSSize.width(20),
          ),
        );
      case DocumentValidationStatus.error:
        return Tooltip(
          message: errorMessage ?? 'Erro ao validar documento',
          child: Icon(
            Icons.error_outline,
            color: colorScheme.onError,
            size: DSSize.width(20),
          ),
        );
    }
  }
}

enum DocumentValidationStatus {
  loading,
  available,
  exists,
  error,
}

