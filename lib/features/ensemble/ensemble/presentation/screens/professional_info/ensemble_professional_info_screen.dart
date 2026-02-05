import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/features/artists/artists/presentation/widgets/forms/artists/professional_info_form.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsembleProfessionalInfoScreen extends StatefulWidget {
  final String ensembleId;

  const EnsembleProfessionalInfoScreen({super.key, required this.ensembleId});

  @override
  EnsembleProfessionalInfoScreenState createState() => EnsembleProfessionalInfoScreenState();
}

class EnsembleProfessionalInfoScreenState extends State<EnsembleProfessionalInfoScreen> {
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController minimumShowDurationController = TextEditingController();
  final TextEditingController preparationTimeController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController requestMinimumEarlinessController = TextEditingController();

  Duration? _selectedMinimumDuration;
  Duration? _selectedPreparationTime;
  Duration? _selectedRequestMinimumEarliness;
  bool _isLoading = false;
  bool _hasLoadedData = false;

  // Valores iniciais para comparação
  ProfessionalInfoEntity? _initialProfessionalInfo;

  /// Conjunto carregado (para salvar com copyWith).
  EnsembleEntity? _currentEnsemble;

  @override
  void initState() {
    super.initState();
    _selectedMinimumDuration = const Duration(minutes: 30);
    minimumShowDurationController.text = _formatDuration(_selectedMinimumDuration!);
    _selectedPreparationTime = const Duration(minutes: 15);
    preparationTimeController.text = _formatDuration(_selectedPreparationTime!);
    specialtyController.addListener(_onFieldChanged);
    minimumShowDurationController.addListener(_onFieldChanged);
    preparationTimeController.addListener(_onFieldChanged);
    bioController.addListener(_onFieldChanged);
    requestMinimumEarlinessController.addListener(_onFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EnsembleBloc>().add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
      }
    });
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    specialtyController.dispose();
    minimumShowDurationController.dispose();
    preparationTimeController.dispose();
    bioController.dispose();
    requestMinimumEarlinessController.dispose();
    super.dispose();
  }

  void _loadProfessionalInfo(ProfessionalInfoEntity? professionalInfo) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;

      // Armazenar valores iniciais para comparação
      _initialProfessionalInfo = professionalInfo;

      // Carregar genrePreferences
      if (professionalInfo?.specialty != null && professionalInfo!.specialty!.isNotEmpty) {
        specialtyController.text = professionalInfo.specialty!.join(', ');
      } else {
        specialtyController.text = '';
      }

      // Carregar minimumShowDuration
      if (professionalInfo?.minimumShowDuration != null) {
        _selectedMinimumDuration = Duration(minutes: professionalInfo!.minimumShowDuration!);
        minimumShowDurationController.text = _formatDuration(_selectedMinimumDuration!);
      } else {
        _selectedMinimumDuration = const Duration(minutes: 30);
        minimumShowDurationController.text = _formatDuration(_selectedMinimumDuration!);
      }

      // Carregar preparationTime
      if (professionalInfo?.preparationTime != null) {
        _selectedPreparationTime = Duration(minutes: professionalInfo!.preparationTime!);
        preparationTimeController.text = _formatDuration(_selectedPreparationTime!);
      } else {
        _selectedPreparationTime = const Duration(minutes: 15);
        preparationTimeController.text = _formatDuration(_selectedPreparationTime!);
      }

      // Carregar bio
      if (professionalInfo?.bio != null && professionalInfo!.bio!.isNotEmpty) {
        bioController.text = professionalInfo.bio!;
      } else {
        bioController.text = '';
      }

      // Carregar requestMinimumEarliness
      if (professionalInfo?.requestMinimumEarliness != null) {
        _selectedRequestMinimumEarliness = Duration(minutes: professionalInfo!.requestMinimumEarliness!);
        requestMinimumEarlinessController.text = _formatDuration(_selectedRequestMinimumEarliness!);
      } else {
        _selectedRequestMinimumEarliness = null;
        requestMinimumEarlinessController.text = '';
      }
    });
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
        minimumDuration: const Duration(minutes: 15), // Duração mínima de 15 minutos
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMinimumDuration = result;
        minimumShowDurationController.text = _formatDuration(result);
        // O listener _onFieldChanged será chamado automaticamente
      });
    }
  }

  Future<void> _selectPreparationTime() async {
    final hours = _selectedPreparationTime?.inHours ?? 0;
    final minutes = (_selectedPreparationTime?.inMinutes ?? 0) % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Tempo de preparação',
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: const Duration(minutes: 0), // Pode ser zero
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPreparationTime = result;
        preparationTimeController.text = _formatDuration(result);
        // O listener _onFieldChanged será chamado automaticamente
      });
    }
  }

  Future<void> _selectRequestMinimumEarliness() async {
    final hours = _selectedRequestMinimumEarliness?.inHours ?? 0;
    final minutes = (_selectedRequestMinimumEarliness?.inMinutes ?? 0) % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Antecedência mínima para solicitações',
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: const Duration(minutes: 0),
        maxHours: 96,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedRequestMinimumEarliness = result;
        requestMinimumEarlinessController.text = _formatDuration(result);
        // O listener _onFieldChanged será chamado automaticamente
      });
    }
  }

  bool _hasChanges() {
    final currentSpecialty = specialtyController.text.trim().isEmpty
        ? null
        : specialtyController.text.split(', ').where((e) => e.isNotEmpty).toList();
    final currentMinimumShowDuration = _selectedMinimumDuration?.inMinutes;
    final currentPreparationTime = _selectedPreparationTime?.inMinutes;
    final currentRequestMinimumEarliness = _selectedRequestMinimumEarliness?.inMinutes;
    final currentBio = bioController.text.trim().isEmpty ? null : bioController.text.trim();

    final initialSpecialty = _initialProfessionalInfo?.specialty;
    final initialMinimumShowDuration = _initialProfessionalInfo?.minimumShowDuration;
    final initialPreparationTime = _initialProfessionalInfo?.preparationTime;
    final initialBio = _initialProfessionalInfo?.bio;
    final initialRequestMinimumEarliness = _initialProfessionalInfo?.requestMinimumEarliness;

    final specialtyChanged = _compareLists(currentSpecialty, initialSpecialty);
    final durationChanged = currentMinimumShowDuration != initialMinimumShowDuration;
    final preparationTimeChanged = currentPreparationTime != initialPreparationTime;
    final bioChanged = currentBio != initialBio;
    final requestMinimumEarlinessChanged = currentRequestMinimumEarliness != initialRequestMinimumEarliness;

    return specialtyChanged || durationChanged || preparationTimeChanged || bioChanged || requestMinimumEarlinessChanged;
  }

  bool _compareLists(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return false;
    if (list1 == null || list2 == null) return true;
    if (list1.length != list2.length) return true;
    
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return true;
    }
    
    return false;
  }

  void _handleSave() {
    final specialty = specialtyController.text.trim().isEmpty
        ? null
        : specialtyController.text.split(', ').where((e) => e.isNotEmpty).toList();

    final minimumShowDuration = _selectedMinimumDuration?.inMinutes;
    final preparationTime = _selectedPreparationTime?.inMinutes;
    final requestMinimumEarliness = _selectedRequestMinimumEarliness?.inMinutes;

    final bio = bioController.text.trim().isEmpty ? null : bioController.text.trim();

    final professionalInfo = ProfessionalInfoEntity(
      specialty: specialty,
      minimumShowDuration: minimumShowDuration,
      preparationTime: preparationTime,
      requestMinimumEarliness: requestMinimumEarliness,
      bio: bio,
    );

    if (_currentEnsemble == null) return;
    context.read<EnsembleBloc>().add(
      UpdateEnsembleProfessionalInfoEvent(
        ensembleId: widget.ensembleId,
        professionalInfo: professionalInfo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EnsembleBloc, EnsembleState>(
          listener: (context, state) {
            if (state is GetAllEnsemblesSuccess && state.currentEnsemble == null) {
              setState(() => _isLoading = true);
            } else if (state is GetAllEnsemblesSuccess && state.currentEnsemble != null) {
              setState(() {
                _isLoading = false;
                _currentEnsemble = state.currentEnsemble;
              });
              _loadProfessionalInfo(state.currentEnsemble?.professionalInfo);
            } else if (state is GetEnsembleByIdFailure) {
              setState(() => _isLoading = false);
              context.showError(state.error);
            } else if (state is UpdateEnsembleLoading || state is UpdateEnsembleProfessionalInfoLoading) {
              setState(() => _isLoading = true);
            } else if (state is UpdateEnsembleSuccess || state is UpdateEnsembleProfessionalInfoSuccess) {
              setState(() {
                _isLoading = false;
                _hasLoadedData = false;
                final specialty = specialtyController.text.trim().isEmpty
                    ? null
                    : specialtyController.text.split(', ').where((e) => e.isNotEmpty).toList();
                final minimumShowDuration = _selectedMinimumDuration?.inMinutes;
                final preparationTime = _selectedPreparationTime?.inMinutes;
                final bio = bioController.text.trim().isEmpty ? null : bioController.text.trim();
                final requestMinimumEarliness = _selectedRequestMinimumEarliness?.inMinutes;
                _initialProfessionalInfo = ProfessionalInfoEntity(
                  specialty: specialty,
                  minimumShowDuration: minimumShowDuration,
                  preparationTime: preparationTime,
                  bio: bio,
                  requestMinimumEarliness: requestMinimumEarliness,
                );
              });
              context.showSuccess('Informações profissionais salvas com sucesso!');
              Navigator.of(context).pop();
            } else if (state is UpdateEnsembleFailure || state is UpdateEnsembleProfessionalInfoFailure) {
              setState(() => _isLoading = false);
              context.showError(state is UpdateEnsembleFailure ? state.error : (state as UpdateEnsembleProfessionalInfoFailure).error);
            }
          },
        ),
      ],
      child: BlocBuilder<EnsembleBloc, EnsembleState>(
        buildWhen: (previous, current) =>
            current is GetAllEnsemblesSuccess ||
            current is GetEnsembleByIdFailure,
        builder: (context, state) {
          // Sincronizar _currentEnsemble quando o estado já tem o ensemble (ex.: veio da área do conjunto)
          if (state is GetAllEnsemblesSuccess &&
              state.currentEnsemble?.id == widget.ensembleId &&
              _currentEnsemble == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentEnsemble == null) {
                setState(() => _currentEnsemble = state.currentEnsemble);
                _loadProfessionalInfo(state.currentEnsemble?.professionalInfo);
              }
            });
          }
          if (state is GetAllEnsemblesSuccess && state.currentEnsemble == null && _currentEnsemble == null) {
            return BasePage(
              showAppBar: true,
              appBarTitle: 'Dados Profissionais',
              showAppBarBackButton: true,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is GetEnsembleByIdFailure && _currentEnsemble == null) {
            return BasePage(
              showAppBar: true,
              appBarTitle: 'Dados Profissionais',
              showAppBarBackButton: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<EnsembleBloc>().add(
                              GetEnsembleByIdEvent(ensembleId: widget.ensembleId),
                            );
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildFormContent(context);
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return BasePage(
        showAppBar: true,
        appBarTitle: 'Dados Profissionais',
        showAppBarBackButton: true,
        appBarActions: [
          IconButton(
            onPressed: _showLegendModal,
            icon: Icon(
              Icons.info_outline,
              size: DSSize.width(22),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Legenda dos campos',
          ),
        ],
        child: GestureDetector(
          onTap: () {
            // Remover foco de qualquer campo quando tocar na tela
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Defina os detalhes da sua apresentação.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                    textAlign: TextAlign.start,
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  ProfessionalInfoForm(
                    talentController: specialtyController,
                    minimumShowDurationController: minimumShowDurationController,
                    preparationTimeController: preparationTimeController,
                    bioController: bioController,
                    onDurationTap: _selectDuration,
                    onPreparationTimeTap: _selectPreparationTime,
                    onRequestMinimumEarlinessTap: _selectRequestMinimumEarliness,
                    durationDisplayValue: minimumShowDurationController.text.isEmpty
                        ? 'Selecione'
                        : minimumShowDurationController.text,
                    preparationTimeDisplayValue: preparationTimeController.text.isEmpty
                        ? 'Selecione'
                        : preparationTimeController.text,
                    requestMinimumEarlinessDisplayValue: requestMinimumEarlinessController.text.isEmpty
                        ? 'Selecione'
                        : requestMinimumEarlinessController.text,
                  ),
                  DSSizedBoxSpacing.vertical(48),
                  CustomButton(
                    label: 'Salvar',
                    backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    textColor: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: (_isLoading || !_hasChanges()) ? null : _handleSave,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
    );
  }

  void _showLegendModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildLegendBottomSheet(),
    );
  }

  Widget _buildLegendBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(
                top: DSSize.height(12),
                bottom: DSSize.height(16),
              ),
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),

          // Título
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
            child: Text(
              'Informações Profissionais',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(height: DSSize.height(8)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
            child: Text(
              'O que cada informação significa?',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          SizedBox(height: DSSize.height(24)),

          // Lista de legendas (scrollável)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  _buildLegendItem(
                    label: 'Minha Bio',
                    description: 'Conte mais sobre você, seu estilo, experiência e o que torna sua apresentação única. Esta informação será visível para os clientes.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  SizedBox(height: DSSize.height(20)),

                  _buildLegendItem(
                    label: 'Duração Mínima',
                    description: 'Tempo mínimo que sua apresentação deve durar. Clientes não poderão solicitar apresentações com duração menor que esta.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  SizedBox(height: DSSize.height(20)),

                  _buildLegendItem(
                    label: 'Tempo de Preparação',
                    description: 'Tempo necessário para você se preparar antes do início da apresentação. Este tempo dará uma estimativa do horário que você chegará no local do show.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  _buildLegendItem(
                    label: 'Antecedência mínima para solicitações',
                    description: 'Tempo mínimo que você precisa para ser solicitado para uma apresentação. Clientes não poderão solicitar apresentações com antecedência menor que esta.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  

                  SizedBox(height: DSSize.height(48)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required String description,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: DSSize.height(4)),
        Text(
          description,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

