import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/features/profile/artists/presentation/widgets/forms/artists/professional_info_form.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage(deferredLoading: true)
class ProfessionalInfoScreen extends StatefulWidget {
  const ProfessionalInfoScreen({super.key});

  @override
  ProfessionalInfoScreenState createState() => ProfessionalInfoScreenState();
}

class ProfessionalInfoScreenState extends State<ProfessionalInfoScreen> {

  final TextEditingController talentController = TextEditingController();
  final TextEditingController genrePreferencesController = TextEditingController();
  final TextEditingController minimumShowDurationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  Duration? _selectedMinimumDuration;

  @override
  void initState() {
    super.initState();
    // Define duração mínima padrão de 30 minutos
    _selectedMinimumDuration = const Duration(minutes: 30);
    minimumShowDurationController.text = _formatDuration(_selectedMinimumDuration!);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  Future<void> _selectDuration() async {
    final hours = _selectedMinimumDuration?.inHours ?? 0;
    final minutes = (_selectedMinimumDuration?.inMinutes ?? 0) % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Duração mínima da sua apresentação',
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: const Duration(minutes: 15), // Duração mínima de 30 minutos
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMinimumDuration = result;
        minimumShowDurationController.text = _formatDuration(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarTitle: 'Dados Profissionais',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Defina os detalhes da sua apresentação.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
              textAlign: TextAlign.start,
            ),
            DSSizedBoxSpacing.vertical(16),
            ProfessionalInfoForm(
              talentController: talentController,
              genrePreferencesController: genrePreferencesController,
              minimumShowDurationController: minimumShowDurationController,
              bioController: bioController,
              onDurationTap: _selectDuration,
              durationDisplayValue: minimumShowDurationController.text.isEmpty 
                  ? 'Selecione' 
                  : minimumShowDurationController.text,
            ),
            DSSizedBoxSpacing.vertical(48),
            CustomButton(
              label: 'Salvar',
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              textColor: Theme.of(context).colorScheme.primaryContainer,
              onPressed: () {
                // TODO: Implementar a lógica de salvamento das informações profissionais
              },
            ),
          ],
        ),
      ),
    );
  }
}

