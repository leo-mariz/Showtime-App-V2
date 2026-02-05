import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/features/artists/artists/presentation/widgets/video_upload_card.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

@RoutePage(deferredLoading: true)
class PresentationsScreen extends StatefulWidget {

  const PresentationsScreen({
    super.key,
  });

  @override
  State<PresentationsScreen> createState() => _PresentationsScreenState();
}

class _PresentationsScreenState extends State<PresentationsScreen> {
  // Lista de talentos obtidos do artista
  List<String> _talents = [];
  // Mapa para armazenar os vídeos selecionados por talento
  final Map<String, File?> _selectedVideos = {};
  // Mapa para armazenar as URLs dos vídeos (após upload ou se já existirem)
  final Map<String, String?> _videoUrls = {};
  // Mapa para armazenar as URLs iniciais (para comparação de mudanças)
  final Map<String, String?> _initialVideoUrls = {};
  bool _isLoading = false;
  bool _hasLoadedData = false;
  bool _isSavingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // Carregar dados do artista
    _handleGetArtist();
  }

  /// Inicializa os mapas de vídeos para os talentos fornecidos
  void _initializeVideosForTalents(List<String> talents) {
    _selectedVideos.clear();
    _videoUrls.clear();
    _initialVideoUrls.clear();
    
    for (final talent in talents) {
      _selectedVideos[talent] = null;
      _videoUrls[talent] = null;
      _initialVideoUrls[talent] = null;
    }
  }

  void _handleGetArtist() {
    context.read<ArtistsBloc>().add(GetArtistEvent());
  }

  Future<void> _onVideoSelected(String talent, File? videoFile) async {
    if (videoFile == null) {
      setState(() {
        _selectedVideos[talent] = null;
      });
      return;
    }

    // Validar duração do vídeo (máximo 60 segundos)
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();

      if (duration.inSeconds > 60) {
        if (mounted) {
          context.showError('O vídeo deve ter no máximo 60 segundos de duração.');
        }
        return;
      }

      setState(() {
        _selectedVideos[talent] = videoFile;
        // Limpar URL quando um novo arquivo é selecionado
        _videoUrls[talent] = null;
      });
    } catch (e) {
      if (mounted) {
        context.showError('Erro ao validar o vídeo: $e');
      }
    }
  }

  void _onVideoRemoved(String talent) {
    setState(() {
      _selectedVideos[talent] = null;
      _videoUrls[talent] = null;
    });
  }

  void _loadPresentationMedias(ArtistEntity artist) {
    if (_hasLoadedData) return;

    // Obter talentos do professionalInfo
    final specialties = artist.professionalInfo?.specialty ?? [];
    
    // Se não há talentos, não há nada para carregar
    if (specialties.isEmpty) {
      setState(() {
        _hasLoadedData = true;
        _talents = [];
      });
      return;
    }

    setState(() {
      _hasLoadedData = true;
      _talents = specialties;
      
      // Inicializar mapas para os talentos
      _initializeVideosForTalents(specialties);
      
      // Carregar URLs existentes se houver
      final presentationMedias = artist.presentationMedias;
      if (presentationMedias != null) {
        for (final talent in specialties) {
          final url = presentationMedias[talent];
          _videoUrls[talent] = url;
          _initialVideoUrls[talent] = url;
        }
      }
    });
  }

  bool _hasChanges() {
    // Verificar se há mudanças comparando os vídeos selecionados com os iniciais
    for (final talent in _talents) {
      final selectedVideo = _selectedVideos[talent];
      final currentUrl = _videoUrls[talent];
      final initialUrl = _initialVideoUrls[talent];

      // Se há um vídeo selecionado, há mudança
      if (selectedVideo != null) {
        return true;
      }

      // Se a URL atual é diferente da inicial, há mudança
      if (currentUrl != initialUrl) {
        return true;
      }
    }

    return false;
  }

  void _showSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: BlocBuilder<ArtistsBloc, ArtistsState>(
          buildWhen: (previous, current) =>
              current is UpdateArtistPresentationMediasLoading ||
              current is UpdateArtistPresentationMediasProgress,
          builder: (context, state) {
            final hasProgress = state is UpdateArtistPresentationMediasProgress && state.total > 0;
            final current = state is UpdateArtistPresentationMediasProgress ? state.current : 0;
            final total = state is UpdateArtistPresentationMediasProgress ? state.total : 0;
            final progress = total > 0 ? current / total : 0.0;

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasProgress) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        '$current/$total',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(8),
                      CustomLoadingIndicator(),
                      ],
                    ),
                    SizedBox(height: DSSize.height(16)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DSSize.width(8)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: DSSize.height(8),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ] else ...[
                    const CustomLoadingIndicator(),
                  ],
                  SizedBox(height: DSSize.height(24)),
                  Text(
                    'Salvando seus vídeos...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DSSize.height(8)),
                  Text(
                    hasProgress
                        ? 'Enviando vídeos. Por favor, não saia da tela.'
                        : 'Por favor, aguarde.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSave() {
    // Preparar map de arquivos para upload
    final Map<String, String> talentFilePaths = {};

    for (final talent in _talents) {
      final selectedVideo = _selectedVideos[talent];
      final currentUrl = _videoUrls[talent];

      if (selectedVideo != null) {
        // Se há um vídeo selecionado, usar o caminho local
        talentFilePaths[talent] = selectedVideo.path;
      } else if (currentUrl != null && currentUrl.isNotEmpty) {
        // Se não há vídeo selecionado mas há URL, manter a URL existente
        talentFilePaths[talent] = currentUrl;
      }
    }

    // Disparar evento de atualização
    context.read<ArtistsBloc>().add(
      UpdateArtistPresentationMediasEvent(
        talentLocalFilePaths: talentFilePaths,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final router = AutoRouter.of(context);
    
    return BlocListener<ArtistsBloc, ArtistsState>(
      listener: (context, state) {
        if (state is GetArtistLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is GetArtistSuccess) {
          setState(() {
            _isLoading = false;
          });
          // Carregar mídias de apresentação e talentos
          _loadPresentationMedias(state.artist);
        } else if (state is GetArtistFailure) {
          setState(() {
            _isLoading = false;
          });
          context.showError(state.error);
        } else if (state is UpdateArtistPresentationMediasLoading ||
            state is UpdateArtistPresentationMediasProgress) {
          setState(() {
            _isLoading = true;
          });
          if (!_isSavingDialogOpen) {
            _isSavingDialogOpen = true;
            _showSavingDialog(context);
          }
        } else if (state is UpdateArtistPresentationMediasSuccess) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          _hasLoadedData = false;
          _handleGetArtist();
          context.showSuccess('Vídeos salvos com sucesso!');
          router.maybePop();
        } else if (state is UpdateArtistPresentationMediasFailure) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          setState(() {
            _isLoading = false;
          });
          context.showError(state.error);
        }
      },
      child: BasePage(
        showAppBar: true,
        appBarTitle: 'Apresentações',
        showAppBarBackButton: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faça o upload de suas apresentações.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
              DSSizedBoxSpacing.vertical(8),
              Text(
                'Cada vídeo deve ter no máximo 60 segundos de duração.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
              // Mostrar mensagem se não há talentos cadastrados
              if (_talents.isEmpty && _hasLoadedData)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Você precisa cadastrar pelo menos um talento (specialty) nas informações profissionais antes de fazer upload de apresentações.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else if (_talents.isEmpty)
                const SizedBox.shrink()
              else
                ..._talents.map((talent) {
                  return Column(
                    children: [
                      VideoUploadCard(
                        talent: talent,
                        videoFile: _selectedVideos[talent],
                        videoUrl: _videoUrls[talent],
                        onVideoSelected: (file) => _onVideoSelected(talent, file),
                        onVideoRemoved: () => _onVideoRemoved(talent),
                        enabled: !_isLoading,
                      ),
                      DSSizedBoxSpacing.vertical(8),
                    ],
                  );
                }),
              DSSizedBoxSpacing.vertical(16),
              CustomButton(
                label: 'Salvar',
                backgroundColor: colorScheme.onPrimaryContainer,
                textColor: colorScheme.primaryContainer,
                onPressed: (_isLoading || !_hasChanges()) ? null : _onSave,
                // isLoading: _isLoading,
              ),
              DSSizedBoxSpacing.vertical(24),
            ],
          ),
        ),
      ),
    );
  }
}

