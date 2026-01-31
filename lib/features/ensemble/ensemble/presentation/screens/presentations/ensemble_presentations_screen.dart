import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/features/profile/artists/presentation/widgets/video_upload_card.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

/// Chave única usada para o vídeo de apresentação do conjunto (um único vídeo).
const String _kEnsemblePresentationKey = 'apresentacao';

@RoutePage(deferredLoading: true)
class EnsemblePresentationsScreen extends StatefulWidget {
  /// ID do conjunto. Após build_runner com rota parametrizada, virá pela rota.
  final String ensembleId;

  const EnsemblePresentationsScreen({
    super.key,
    this.ensembleId = '',
  });

  @override
  State<EnsemblePresentationsScreen> createState() => _EnsemblePresentationsScreenState();
}

class _EnsemblePresentationsScreenState extends State<EnsemblePresentationsScreen> {
  File? _selectedVideo;
  String? _videoUrl;
  String? _initialVideoUrl;
  bool _isLoading = false;
  bool _hasLoadedData = false;
  bool _isSavingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _handleGetArtist();
  }

  void _handleGetArtist() {
    context.read<ArtistsBloc>().add(GetArtistEvent());
  }

  Future<void> _onVideoSelected(File? videoFile) async {
    if (videoFile == null) {
      setState(() {
        _selectedVideo = null;
      });
      return;
    }

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
        _selectedVideo = videoFile;
        _videoUrl = null;
      });
    } catch (e) {
      if (mounted) {
        context.showError('Erro ao validar o vídeo: $e');
      }
    }
  }

  void _onVideoRemoved() {
    setState(() {
      _selectedVideo = null;
      _videoUrl = null;
    });
  }

  void _loadPresentationMedia(ArtistEntity artist) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;
      final presentationMedias = artist.presentationMedias;
      _videoUrl = presentationMedias?[_kEnsemblePresentationKey];
      _initialVideoUrl = _videoUrl;
    });
  }

  bool _hasChanges() {
    if (_selectedVideo != null) return true;
    return _videoUrl != _initialVideoUrl;
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
                    Row(children: [
                      Text(
                        '$current/$total',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(8),
                      CustomLoadingIndicator(),
                    ]),
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
                    'Salvando seu vídeo...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DSSize.height(8)),
                  Text(
                    hasProgress
                        ? 'Enviando vídeo. Por favor, não saia da tela.'
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
    final Map<String, String> talentFilePaths = {};
    if (_selectedVideo != null) {
      talentFilePaths[_kEnsemblePresentationKey] = _selectedVideo!.path;
    } else if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      talentFilePaths[_kEnsemblePresentationKey] = _videoUrl!;
    }

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
          setState(() => _isLoading = true);
        } else if (state is GetArtistSuccess) {
          setState(() => _isLoading = false);
          _loadPresentationMedia(state.artist);
        } else if (state is GetArtistFailure) {
          setState(() => _isLoading = false);
          context.showError(state.error);
        } else if (state is UpdateArtistPresentationMediasLoading ||
            state is UpdateArtistPresentationMediasProgress) {
          setState(() => _isLoading = true);
          if (!_isSavingDialogOpen) {
            _isSavingDialogOpen = true;
            _showSavingDialog(context);
          }
        } else if (state is UpdateArtistPresentationMediasSuccess) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          _hasLoadedData = false;
          _handleGetArtist();
          context.showSuccess('Vídeo salvo com sucesso!');
          router.maybePop();
        } else if (state is UpdateArtistPresentationMediasFailure) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          setState(() => _isLoading = false);
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
                'Faça o upload do vídeo de apresentação do conjunto.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              DSSizedBoxSpacing.vertical(8),
              Text(
                'O vídeo deve ter no máximo 60 segundos de duração.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
              VideoUploadCard(
                talent: 'Apresentação',
                videoFile: _selectedVideo,
                videoUrl: _videoUrl,
                onVideoSelected: _onVideoSelected,
                onVideoRemoved: _onVideoRemoved,
                enabled: !_isLoading,
              ),
              DSSizedBoxSpacing.vertical(16),
              CustomButton(
                label: 'Salvar',
                backgroundColor: colorScheme.onPrimaryContainer,
                textColor: colorScheme.primaryContainer,
                onPressed: (_isLoading || !_hasChanges()) ? null : _onSave,
              ),
              DSSizedBoxSpacing.vertical(24),
            ],
          ),
        ),
      ),
    );
  }
}
