import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_message_field.dart';
import 'package:app/core/shared/widgets/custom_multi_select_field.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

class ProfessionalInfoForm extends StatelessWidget {
  final TextEditingController talentController;
  final TextEditingController genrePreferencesController;
  final TextEditingController minimumShowDurationController;
  final TextEditingController bioController;
  final VoidCallback onDurationTap;
  final String durationDisplayValue;
  

  const ProfessionalInfoForm({
    super.key,
    required this.talentController,
    required this.genrePreferencesController,
    required this.minimumShowDurationController,
    required this.bioController,
    required this.onDurationTap,
    required this.durationDisplayValue,
  });

  @override
  Widget build(BuildContext context) {
    final talentOptions = [
      'Cantor',
      'Dançarino',
      'Músico',
      'Atores',
      'Comediantes',
      'Outros',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomMultiSelectField(
          controller: talentController,
          items: talentOptions,
          labelText: 'Talentos',
          hintText: 'Selecione seus talentos',
        ),
        DSSizedBoxSpacing.vertical(16),
        CustomMultiSelectField(
          controller: genrePreferencesController,
          items: talentOptions,
          labelText: 'Gêneros Musicais',
          hintText: 'Quais são as suas especialidades?',
        ),
        DSSizedBoxSpacing.vertical(16),
        CustomMessageField(
          controller: bioController,
          hintText: 'Fale mais sobre o artista que você é...',
          labelText: 'Minha Bio',
          onChanged: (value) {},
          validator: Validators.validateIsNull,
        ),
        DSSizedBoxSpacing.vertical(16),
        SelectableRow(
          label: 'Duração Mínima:',
          value: durationDisplayValue,
          onTap: onDurationTap,
        ),
      ],
    );
  }
}

