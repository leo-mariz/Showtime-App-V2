import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/features/profile/artists/presentation/widgets/forms/artists/professional_info_form.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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
  final TextEditingController preparationTimeController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  Duration? _selectedMinimumDuration;
  Duration? _selectedPreparationTime;
  bool _isLoading = false;
  bool _hasLoadedData = false;

  // Valores iniciais para comparação
  ProfessionalInfoEntity? _initialProfessionalInfo;
  
  // Lista de talentos obtida do AppListsBloc
  List<String> _talentOptions = [];

  @override
  void initState() {
    super.initState();
    // Define duração mínima padrão de 30 minutos (será sobrescrito se houver dados)
    _selectedMinimumDuration = const Duration(minutes: 30);
    minimumShowDurationController.text = _formatDuration(_selectedMinimumDuration!);
    
    // Define tempo de preparação padrão de 15 minutos (será sobrescrito se houver dados)
    _selectedPreparationTime = const Duration(minutes: 15);
    preparationTimeController.text = _formatDuration(_selectedPreparationTime!);
    
    // Adicionar listeners para detectar mudanças
    talentController.addListener(_onFieldChanged);
    genrePreferencesController.addListener(_onFieldChanged);
    minimumShowDurationController.addListener(_onFieldChanged);
    preparationTimeController.addListener(_onFieldChanged);
    bioController.addListener(_onFieldChanged);
    
    // Carregar dados do artista após o frame ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetArtist(forceRefresh: false);
      // Buscar lista de talentos do AppListsBloc
      _loadTalents();
    });
  }

  void _onFieldChanged() {
    // Atualizar estado para verificar se há mudanças
    if (mounted) {
      setState(() {});
    }
  }

  void _loadTalents() {
    // Buscar talentos do AppListsBloc
    context.read<AppListsBloc>().add(GetTalentsEvent());
  }

  @override
  void dispose() {
    talentController.dispose();
    genrePreferencesController.dispose();
    minimumShowDurationController.dispose();
    preparationTimeController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _handleGetArtist({bool forceRefresh = false}) {
    final artistsBloc = context.read<ArtistsBloc>();
    // Sempre buscar quando forçado (após logout/login ou atualização)
    if (forceRefresh) {
      setState(() {
        _hasLoadedData = false; // Resetar flag para permitir recarregar
      });
      artistsBloc.add(GetArtistEvent());
    } else if (artistsBloc.state is GetArtistSuccess) {
      // Se já tem dados e não foi forçado, carregar diretamente
      final state = artistsBloc.state as GetArtistSuccess;
      _loadProfessionalInfo(state.artist.professionalInfo);
    } else {
      // Se não tem dados, buscar
      artistsBloc.add(GetArtistEvent());
    }
  }

  void _loadProfessionalInfo(ProfessionalInfoEntity? professionalInfo) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;

      // Armazenar valores iniciais para comparação
      _initialProfessionalInfo = professionalInfo;

      // Carregar specialty (talentos)
      if (professionalInfo?.specialty != null && professionalInfo!.specialty!.isNotEmpty) {
        talentController.text = professionalInfo.specialty!.join(', ');
      } else {
        talentController.text = '';
      }

      // Carregar genrePreferences
      if (professionalInfo?.genrePreferences != null && professionalInfo!.genrePreferences!.isNotEmpty) {
        genrePreferencesController.text = professionalInfo.genrePreferences!.join(', ');
      } else {
        genrePreferencesController.text = '';
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

  bool _hasChanges() {
    // Converter valores atuais
    final currentSpecialty = talentController.text.trim().isEmpty
        ? null
        : talentController.text.split(', ').where((e) => e.isNotEmpty).toList();
    
    final currentGenrePreferences = genrePreferencesController.text.trim().isEmpty
        ? null
        : genrePreferencesController.text.split(', ').where((e) => e.isNotEmpty).toList();
    
    final currentMinimumShowDuration = _selectedMinimumDuration?.inMinutes;
    final currentPreparationTime = _selectedPreparationTime?.inMinutes;
    
    final currentBio = bioController.text.trim().isEmpty ? null : bioController.text.trim();

    // Comparar com valores iniciais
    final initialSpecialty = _initialProfessionalInfo?.specialty;
    final initialGenrePreferences = _initialProfessionalInfo?.genrePreferences;
    final initialMinimumShowDuration = _initialProfessionalInfo?.minimumShowDuration;
    final initialPreparationTime = _initialProfessionalInfo?.preparationTime;
    final initialBio = _initialProfessionalInfo?.bio;

    // Verificar se há mudanças
    final specialtyChanged = _compareLists(currentSpecialty, initialSpecialty);
    final genrePreferencesChanged = _compareLists(currentGenrePreferences, initialGenrePreferences);
    final durationChanged = currentMinimumShowDuration != initialMinimumShowDuration;
    final preparationTimeChanged = currentPreparationTime != initialPreparationTime;
    final bioChanged = currentBio != initialBio;

    return specialtyChanged || genrePreferencesChanged || durationChanged || preparationTimeChanged || bioChanged;
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
    // Converter dados dos controllers para ProfessionalInfoEntity
    final specialty = talentController.text.trim().isEmpty
        ? null
        : talentController.text.split(', ').where((e) => e.isNotEmpty).toList();

    final genrePreferences = genrePreferencesController.text.trim().isEmpty
        ? null
        : genrePreferencesController.text.split(', ').where((e) => e.isNotEmpty).toList();

    final minimumShowDuration = _selectedMinimumDuration?.inMinutes;
    final preparationTime = _selectedPreparationTime?.inMinutes;

    final bio = bioController.text.trim().isEmpty ? null : bioController.text.trim();

    final professionalInfo = ProfessionalInfoEntity(
      specialty: specialty,
      genrePreferences: genrePreferences,
      minimumShowDuration: minimumShowDuration,
      preparationTime: preparationTime,
      bio: bio,
    );

    // Disparar evento de atualização
    context.read<ArtistsBloc>().add(
      UpdateArtistProfessionalInfoEvent(professionalInfo: professionalInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ArtistsBloc, ArtistsState>(
          listener: (context, state) {
            if (state is GetArtistLoading) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is GetArtistSuccess) {
              setState(() {
                _isLoading = false;
              });
              // Carregar dados profissionais do artista
              _loadProfessionalInfo(state.artist.professionalInfo);
            } else if (state is GetArtistFailure) {
              setState(() {
                _isLoading = false;
              });
              context.showError(state.error);
            } else if (state is UpdateArtistProfessionalInfoLoading) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is UpdateArtistProfessionalInfoSuccess) {
              setState(() {
                _isLoading = false;
                _hasLoadedData = false; // Resetar flag para permitir recarregar após atualização
                // Atualizar valores iniciais com os novos valores salvos
                final specialty = talentController.text.trim().isEmpty
                    ? null
                    : talentController.text.split(', ').where((e) => e.isNotEmpty).toList();
                final genrePreferences = genrePreferencesController.text.trim().isEmpty
                    ? null
                    : genrePreferencesController.text.split(', ').where((e) => e.isNotEmpty).toList();
                final minimumShowDuration = _selectedMinimumDuration?.inMinutes;
                final preparationTime = _selectedPreparationTime?.inMinutes;
                final bio = bioController.text.trim().isEmpty ? null : bioController.text.trim();
                _initialProfessionalInfo = ProfessionalInfoEntity(
                  specialty: specialty,
                  genrePreferences: genrePreferences,
                  minimumShowDuration: minimumShowDuration,
                  preparationTime: preparationTime,
                  bio: bio,
                );
              });
              // Recarregar dados atualizados antes de voltar
              _handleGetArtist(forceRefresh: true);
              context.showSuccess('Informações profissionais salvas com sucesso!');
              // Voltar para a tela anterior após salvar
              Navigator.of(context).pop();
            } else if (state is UpdateArtistProfessionalInfoFailure) {
              setState(() {
                _isLoading = false;
              });
              context.showError(state.error);
            }
          },
        ),
        BlocListener<AppListsBloc, AppListsState>(
          listener: (context, state) {
            if (state is GetTalentsSuccess) {
              // Extrair nomes dos talentos e ordenar alfabeticamente
              final talentNames = state.talents
                  .map((talent) => talent.name)
                  .toList()
                ..sort();
              
              setState(() {
                _talentOptions = talentNames;
              });
            } else if (state is GetTalentsFailure) {
              // Em caso de erro, manter lista vazia (o form usará a lista padrão)
              setState(() {
                _talentOptions = [];
              });
            }
          },
        ),
      ],
      child: BasePage(
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
                    talentController: talentController,
                    genrePreferencesController: genrePreferencesController,
                    minimumShowDurationController: minimumShowDurationController,
                    preparationTimeController: preparationTimeController,
                    bioController: bioController,
                    onDurationTap: _selectDuration,
                    onPreparationTimeTap: _selectPreparationTime,
                    durationDisplayValue: minimumShowDurationController.text.isEmpty
                        ? 'Selecione'
                        : minimumShowDurationController.text,
                    preparationTimeDisplayValue: preparationTimeController.text.isEmpty
                        ? 'Selecione'
                        : preparationTimeController.text,
                    talentOptions: _talentOptions.isNotEmpty ? _talentOptions : null,
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
                    label: 'Talentos',
                    description: 'Selecione os talentos ou especialidades que você possui. Cada talento poderá ter um vídeo de apresentação na área de apresentações.',
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

                  SizedBox(height: DSSize.height(20)),

                  _buildLegendItem(
                    label: 'Minha Bio',
                    description: 'Conte mais sobre você, seu estilo, experiência e o que torna sua apresentação única. Esta informação será visível para os clientes.',
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

