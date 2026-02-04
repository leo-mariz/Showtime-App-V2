import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/artists/artists/presentation/widgets/video_upload_card.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

@RoutePage(deferredLoading: true)
class EnsemblePresentationsScreen extends StatefulWidget {
  final String ensembleId;

  const EnsemblePresentationsScreen({
    super.key,
    this.ensembleId = '',
  });

  @override
  State<EnsemblePresentationsScreen> createState() =>
      _EnsemblePresentationsScreenState();
}

class _EnsemblePresentationsScreenState
    extends State<EnsemblePresentationsScreen> {
  File? _selectedVideo;
  String? _videoUrl;
  String? _initialVideoUrl;
  bool _isLoading = false;
  bool _hasLoadedData = false;
  bool _isSavingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    context
        .read<EnsembleBloc>()
        .add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
  }

  void _tryLoadFromState(EnsembleState state) {
    if (_hasLoadedData || widget.ensembleId.isEmpty) return;
    if (state is GetAllEnsemblesSuccess &&
        state.currentEnsemble?.id == widget.ensembleId) {
      _loadPresentationVideo(state.currentEnsemble!);
    }
  }

  Future<void> _onVideoSelected(File? videoFile) async {
    if (videoFile == null) {
      setState(() => _selectedVideo = null);
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

  void _loadPresentationVideo(EnsembleEntity ensemble) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;
      _isLoading = false;
      _videoUrl = ensemble.presentationVideoUrl;
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
        child: BlocBuilder<EnsembleBloc, EnsembleState>(
          buildWhen: (previous, current) =>
              current is UpdateEnsemblePresentationVideoLoading,
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomLoadingIndicator(),
                  SizedBox(height: DSSize.height(24)),
                  Text(
                    'Seu Show está sendo salvo...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DSSize.height(8)),
                  Text(
                    'Esse processo pode levar alguns minutos. Por favor, aguarde.',
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
    final localFilePath = _selectedVideo?.path ?? '';
    context.read<EnsembleBloc>().add(
          UpdateEnsemblePresentationVideoEvent(
            ensembleId: widget.ensembleId,
            localFilePath: localFilePath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final router = AutoRouter.of(context);

    return BlocConsumer<EnsembleBloc, EnsembleState>(
      listenWhen: (previous, current) {
        if (current is GetEnsembleByIdFailure) return true;
        if (current is UpdateEnsemblePresentationVideoLoading) return true;
        if (current is UpdateEnsemblePresentationVideoSuccess) return true;
        if (current is UpdateEnsemblePresentationVideoFailure) return true;
        if (current is GetAllEnsemblesSuccess) {
          return current.currentEnsemble?.id == widget.ensembleId;
        }
        return false;
      },
      listener: (context, state) {
        if (state is GetAllEnsemblesSuccess &&
            state.currentEnsemble?.id == widget.ensembleId) {
          setState(() => _isLoading = false);
          _loadPresentationVideo(state.currentEnsemble!);
        } else if (state is GetEnsembleByIdFailure) {
          setState(() => _isLoading = false);
          context.showError(state.error);
        } else if (state is UpdateEnsemblePresentationVideoLoading) {
          setState(() => _isLoading = true);
          if (!_isSavingDialogOpen) {
            _isSavingDialogOpen = true;
            _showSavingDialog(context);
          }
        } else if (state is UpdateEnsemblePresentationVideoSuccess) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          _hasLoadedData = false;
          context.read<EnsembleBloc>().add(
                GetEnsembleByIdEvent(ensembleId: widget.ensembleId),
              );
          context.showSuccess('Vídeo salvo com sucesso!');
          router.maybePop();
        } else if (state is UpdateEnsemblePresentationVideoFailure) {
          _isSavingDialogOpen = false;
          if (context.mounted) Navigator.of(context).pop(context);
          setState(() => _isLoading = false);
          context.showError(state.error);
        }
      },
      buildWhen: (previous, current) =>
          current is GetAllEnsemblesSuccess || current is GetEnsembleByIdFailure,
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _tryLoadFromState(state);
        });
        return BasePage(
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
        );
      },
    );
  }
}
