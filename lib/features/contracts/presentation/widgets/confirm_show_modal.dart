import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';

/// Modal para artista confirmar o show realizando com código
/// 
/// Artista digita o código fornecido pelo cliente para confirmar que o show foi realizado
class ConfirmShowModal extends StatefulWidget {
  final String contractUid;

  const ConfirmShowModal({
    super.key,
    required this.contractUid,
  });

  /// Método estático para exibir o modal de confirmação do show
  /// 
  /// Retorna o código digitado pelo artista, ou null se cancelou
  static Future<String?> show({
    required BuildContext context,
    required String contractUid,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ContractsBloc>(),
        child: ConfirmShowModal(
          contractUid: contractUid,
        ),
      ),
    );
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

  void _handleConfirm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = ConfirmShowModal._codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      return;
    }

    context.read<ContractsBloc>().add(
      ConfirmShowEvent(
        contractUid: widget.contractUid,
        confirmationCode: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractsBloc, ContractsState>(
      listener: (context, state) {
        if (state is ConfirmShowSuccess) {
          Navigator.of(context).pop(ConfirmShowModal._codeController.text.trim().toUpperCase());
        } else if (state is ConfirmShowFailure) {
          // Não fecha o modal em caso de erro, apenas mostra o erro
          // O erro será mostrado pelo listener da tela pai
        }
      },
      child: BlocBuilder<ContractsBloc, ContractsState>(
        builder: (context, state) {
          final isLoading = state is ConfirmShowLoading;
          
          return PopScope(
            canPop: !isLoading,
            child: _buildModalContent(context, isLoading),
          );
        },
      ),
    );
  }

  Widget _buildModalContent(BuildContext context, bool isLoading) {
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
                    enabled: !isLoading,
                  ),
                ),
                DSSizedBoxSpacing.vertical(24),
                // Botões
                Row(
                  children: [
                    // Expanded(
                    //   child: TextButton(
                    //     onPressed: isLoading ? null : () => Navigator.of(context).pop(null),
                    //     child: Text(
                    //       'Cancelar',
                    //       style: textTheme.bodyLarge?.copyWith(
                    //         color: onPrimary.withOpacity(0.7),
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // DSSizedBoxSpacing.horizontal(12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        label: 'Confirmar',
                        backgroundColor: colorScheme.onPrimaryContainer,
                        textColor: colorScheme.primaryContainer,
                        onPressed: isLoading ? null : () => _handleConfirm(context),
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
