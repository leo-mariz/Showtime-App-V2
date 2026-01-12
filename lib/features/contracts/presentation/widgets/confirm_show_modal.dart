import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';

/// Modal para artista confirmar o show realizando com código
/// 
/// Artista digita o código fornecido pelo cliente para confirmar que o show foi realizado
class ConfirmShowModal extends StatefulWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ConfirmShowModal({
    super.key,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  /// Método estático para exibir o modal de confirmação do show
  /// 
  /// Retorna o código digitado pelo artista, ou null se cancelou
  static Future<String?> show({
    required BuildContext context,
    bool isLoading = false,
  }) async {
    String? result;
    
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ConfirmShowModal(
        isLoading: isLoading,
        onConfirm: () {
          result = _codeController.text.trim().toUpperCase();
          Navigator.of(modalContext).pop(result);
        },
        onCancel: () {
          Navigator.of(modalContext).pop(null);
        },
      ),
    );

    return result;
  }

  static final TextEditingController _codeController = TextEditingController();

  @override
  State<ConfirmShowModal> createState() => _ConfirmShowModalState();
}

class _ConfirmShowModalState extends State<ConfirmShowModal> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Limpar código anterior quando modal abrir
    ConfirmShowModal._codeController.clear();
  }

  @override
  void dispose() {
    // Não dispose do controller estático, pois será reutilizado
    super.dispose();
  }

  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          // Título
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.onPrimaryContainer,
                size: DSSize.width(24),
              ),
              DSSizedBoxSpacing.horizontal(8),
              Expanded(
                child: Text(
                  'Palavra-chave',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onPrimary,
                  ),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          // Descrição
          Text(
            'Digite o código de confirmação fornecido pelo cliente após a finalização do show:',
            style: textTheme.bodyMedium?.copyWith(
              color: onPrimary.withOpacity(0.7),
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          // Formulário
          Form(
            key: _formKey,
            child: CustomTextField(
              label: 'Código de Confirmação',
              controller: ConfirmShowModal._codeController,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, digite o código';
                }
                return null;
              },
              enabled: !widget.isLoading,
            ),
          ),
          DSSizedBoxSpacing.vertical(24),
          // Botões
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Confirmar',
                  backgroundColor: colorScheme.onPrimaryContainer,
                  textColor: colorScheme.primaryContainer,
                  onPressed: widget.isLoading ? null : _handleConfirm,
                  isLoading: widget.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

