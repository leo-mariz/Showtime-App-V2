import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_message_field.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

class SupportForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController messageController;
  final String? selectedSubject;
  final List<String> subjects;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String> onMessageChanged;

  const SupportForm({
    super.key,
    required this.nameController,
    required this.messageController,
    required this.selectedSubject,
    required this.subjects,
    required this.onSubjectChanged,
    required this.onMessageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: nameController,
          label: 'Nome',
          validator: (value) =>
              value == null || value.isEmpty ? 'Digite seu nome' : null,
        ),
        DSSizedBoxSpacing.vertical(16),
        CustomDropdownButton(
          selectedValue: selectedSubject,
          itemsList: subjects,
          labelText: 'Assunto',
          onChanged: onSubjectChanged,
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecione um assunto' : null,
        ),
        DSSizedBoxSpacing.vertical(16),
        CustomMessageField(
          controller: messageController,
          hintText: 'Descreva seu problema ou sugestão',
          labelText: 'Mensagem',
          onChanged: onMessageChanged,
          validator: Validators.validateIsNull,
        ),
      ],
    );
  }
}

