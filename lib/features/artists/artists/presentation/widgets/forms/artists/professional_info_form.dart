import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_message_field.dart';
import 'package:app/core/shared/widgets/custom_multi_select_field.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/material.dart';

class ProfessionalInfoForm extends StatelessWidget {
  /// Quando null, o campo de talentos não é exibido (ex.: dados profissionais do conjunto).
  final TextEditingController? talentController;
  final TextEditingController genrePreferencesController;
  final TextEditingController minimumShowDurationController;
  final TextEditingController preparationTimeController;
  final TextEditingController bioController;
  final VoidCallback onDurationTap;
  final VoidCallback onPreparationTimeTap;
  final VoidCallback onRequestMinimumEarlinessTap;
  final String durationDisplayValue;
  final String preparationTimeDisplayValue;
  final String requestMinimumEarlinessDisplayValue;
  final List<String>? talentOptions;

  const ProfessionalInfoForm({
    super.key,
    this.talentController,
    required this.genrePreferencesController,
    required this.minimumShowDurationController,
    required this.preparationTimeController,
    required this.bioController,
    required this.onDurationTap,
    required this.onPreparationTimeTap,
    required this.onRequestMinimumEarlinessTap,
    required this.durationDisplayValue,
    required this.preparationTimeDisplayValue,
    required this.requestMinimumEarlinessDisplayValue,
    this.talentOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Usar lista fornecida ou fallback para lista padrão
    final defaultTalentOptions = [
      'Cantor',
      'Dançarino',
      'Músico',
      'Atores',
      'Comediantes',
      'Outros',
    ];
    final talentOptionsList = talentOptions ?? defaultTalentOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (talentController != null) ...[
          CustomMultiSelectField(
            controller: talentController!,
            items: talentOptionsList,
            labelText: 'Talentos',
            hintText: 'Selecione seus talentos',
          ),
          DSSizedBoxSpacing.vertical(16),
        ],
        // DSSizedBoxSpacing.vertical(16),
        // CustomMultiSelectField(
        //   controller: genrePreferencesController,
        //   items: talentOptionsList,
        //   labelText: 'Gêneros Musicais',
        //   hintText: 'Quais são as suas especialidades?',
        // ),
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
        DSSizedBoxSpacing.vertical(16),
        SelectableRow(
          label: 'Tempo de Preparação:',
          value: preparationTimeDisplayValue,
          onTap: onPreparationTimeTap,
        ),
        DSSizedBoxSpacing.vertical(16),
        SelectableRow(
          label: 'Antecedência mínima para solicitações:',
          value: requestMinimumEarlinessDisplayValue,
          onTap: onRequestMinimumEarlinessTap,
        ),
      ],
    );
  }
}

