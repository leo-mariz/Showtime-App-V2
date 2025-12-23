import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/profile/artists/presentation/widgets/forms/support_form.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final List<String> subjects = ['Dúvidas', 'Problemas técnicos', 'Sugestões', 'Outros'];
  String? selectedSubject;
  final _formKey = GlobalKey<FormState>();
  bool _showValidation = false;
  bool _isLoading = false;

  void _clearFormFields() {
    nameController.clear();
    messageController.clear();
    setState(() {
      selectedSubject = null;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () {
                _clearFormFields();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showValidation = false;
        _isLoading = true;
      });

      // Mock: Simula envio de email
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
        final protocolNumber = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
        _showDialog(
          'Sucesso',
          'Enviamos sua mensagem à nossa equipe!\nVocê também receberá um e-mail de confirmação que conterá o número de protocolo: $protocolNumber',
        );
        _clearFormFields();
      });
    } else {
      setState(() {
        _showValidation = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Atendimento',
      showAppBarBackButton: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Atendimento via WhatsApp
                Text(
                  "Fale conosco pelo email:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                DSSizedBoxSpacing.vertical(8),
                TextButton.icon(
                  icon: Icon(Icons.email, color: Theme.of(context).colorScheme.onPrimary,),
                  label: Text("contato@showtime.app.br", style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () {},
                ),
                Divider(height: DSSize.height(30)),
                DSSizedBoxSpacing.vertical(30),
                // Formulário de Atendimento
                Text(
                  "Ou envie uma mensagem pelo formulário abaixo:",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                DSSizedBoxSpacing.vertical(16),
                Form(
                  key: _formKey,
                  autovalidateMode: _showValidation 
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      SupportForm(
                        nameController: nameController,
                        messageController: messageController,
                        selectedSubject: selectedSubject,
                        subjects: subjects,
                        onSubjectChanged: (value) => setState(() => selectedSubject = value),
                        onMessageChanged: (value) {},
                      ),
                      DSSizedBoxSpacing.vertical(16),
                      CustomButton(
                        label: 'Enviar',
                        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        textColor: Theme.of(context).colorScheme.primaryContainer,
                        onPressed: _isLoading ? null : () => _submitForm(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
