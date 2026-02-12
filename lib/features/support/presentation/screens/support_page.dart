import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/artists/artists/presentation/widgets/forms/support_form.dart';
import 'package:app/features/support/presentation/bloc/events/support_events.dart';
import 'package:app/features/support/presentation/bloc/support_bloc.dart';
import 'package:app/features/support/presentation/bloc/states/support_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Assuntos quando a tela não está vinculada a um contrato.
const List<String> _defaultSubjects = [
  'Dúvidas',
  'Problemas técnicos',
  'Sugestões',
  'Outros',
];

/// Assuntos quando a tela está vinculada a um contrato.
const List<String> _contractSubjects = [
  'Cancelamento',
  'Reembolso',
  'Problema durante show',
  'Outros (relacionado ao contrato)',
];

@RoutePage(deferredLoading: true)
class SupportPage extends StatefulWidget {
  /// Quando informado, exibe o tipo de evento e assuntos referentes ao contrato.
  final ContractEntity? contract;

  const SupportPage({super.key, this.contract});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? selectedSubject;
  final _formKey = GlobalKey<FormState>();
  bool _showValidation = false;

  void _clearFormFields() {
    nameController.clear();
    messageController.clear();
    setState(() => selectedSubject = null);
  }

  void _showSuccessDialog(String protocolNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Sucesso',
          message: 'Enviamos sua mensagem à nossa equipe!\n\n'
            'Você também receberá um e-mail de confirmação que conterá o número de protocolo: $protocolNumber',
          confirmText: 'OK',
          onConfirm: () {
            _clearFormFields();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  List<String> get _subjects =>
      widget.contract != null ? _contractSubjects : _defaultSubjects;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _showValidation = false);
      context.read<SupportBloc>().add(
            SendSupportMessageEvent(
              name: nameController.text.trim(),
              subject: selectedSubject ?? '',
              message: messageController.text.trim(),
              contractId: widget.contract?.uid,
            ),
          );
    } else {
      setState(() => _showValidation = true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportBloc, SupportState>(
      listenWhen: (previous, current) =>
          current is SendSupportMessageSuccess || current is SendSupportMessageFailure,
      listener: (context, state) {
        if (state is SendSupportMessageSuccess) {
          final protocol = state.request.protocolNumber ?? state.request.id ?? '—';
          _showSuccessDialog(protocol);
        }
        if (state is SendSupportMessageFailure) {
          context.showError(state.error);
        }
      },
      child: BasePage(
        showAppBar: true,
        appBarTitle: 'Atendimento',
        showAppBarBackButton: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.contract != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_note,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Referente ao contrato',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              widget.contract!.eventType?.name ?? 'Evento',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DSSizedBoxSpacing.vertical(20),
              ],
              Text(
                'Fale conosco pelo email:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DSSizedBoxSpacing.vertical(8),
              TextButton.icon(
                icon: Icon(Icons.email, color: Theme.of(context).colorScheme.onPrimary),
                label: Text(
                  'contato@showtime.app.br',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () {},
              ),
              Divider(height: DSSize.height(30)),
              DSSizedBoxSpacing.vertical(30),
              Text(
                'Ou envie uma mensagem pelo formulário abaixo:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DSSizedBoxSpacing.vertical(16),
              Form(
                key: _formKey,
                autovalidateMode:
                    _showValidation ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: BlocBuilder<SupportBloc, SupportState>(
                  buildWhen: (previous, current) => current is SupportInitial || current is SendSupportMessageLoading,
                  builder: (context, state) {
                    final isLoading = state is SendSupportMessageLoading;
                    return Column(
                      children: [
                        SupportForm(
                          nameController: nameController,
                          messageController: messageController,
                          selectedSubject: selectedSubject,
                          subjects: _subjects,
                          onSubjectChanged: (value) => setState(() => selectedSubject = value),
                          onMessageChanged: (_) {},
                        ),
                        DSSizedBoxSpacing.vertical(16),
                        CustomButton(
                          label: 'Enviar',
                          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          textColor: Theme.of(context).colorScheme.primaryContainer,
                          onPressed: isLoading ? null : _submitForm,
                          isLoading: isLoading,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
