import 'dart:io';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/artists/presentation/widgets/video_upload_card.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/profile/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/profile/artists/presentation/bloc/states/artists_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

@RoutePage(deferredLoading: true)
class PresentationsScreen extends StatefulWidget {
  final List<String> talents;

  const PresentationsScreen({
    super.key,
    required this.talents,
  });

  @override
  State<PresentationsScreen> createState() => _PresentationsScreenState();
}

class _PresentationsScreenState extends State<PresentationsScreen> {
  // Mapa para armazenar os vídeos selecionados por talento
  final Map<String, File?> _selectedVideos = {};
  // Mapa para armazenar as URLs dos vídeos (após upload ou se já existirem)
  final Map<String, String?> _videoUrls = {};
  // Mapa para armazenar as URLs iniciais (para comparação de mudanças)
  final Map<String, String?> _initialVideoUrls = {};
  bool _isLoading = false;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o mapa de vídeos para cada talento
    for (final talent in widget.talents) {
      _selectedVideos[talent] = null;
      _videoUrls[talent] = null;
      _initialVideoUrls[talent] = null;
    }
    // Carregar dados do artista
    _handleGetArtist();
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

  void _loadPresentationMedias(Map<String, String>? presentationMedias) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;
      
      // Limpar vídeos selecionados quando recarregamos os dados
      _selectedVideos.clear();
      for (final talent in widget.talents) {
        _selectedVideos[talent] = null;
      }
      
      if (presentationMedias != null) {
        for (final talent in widget.talents) {
          final url = presentationMedias[talent];
          _videoUrls[talent] = url;
          _initialVideoUrls[talent] = url;
        }
      } else {
        // Se não há mídias, limpar URLs
        for (final talent in widget.talents) {
          _videoUrls[talent] = null;
          _initialVideoUrls[talent] = null;
        }
      }
    });
  }

  bool _hasChanges() {
    // Verificar se há mudanças comparando os vídeos selecionados com os iniciais
    for (final talent in widget.talents) {
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

  void _onSave() {
    // Preparar map de arquivos para upload
    final Map<String, String> talentFilePaths = {};

    for (final talent in widget.talents) {
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
          // Carregar mídias de apresentação
          _loadPresentationMedias(state.artist.presentationMedias);
        } else if (state is GetArtistFailure) {
          setState(() {
            _isLoading = false;
          });
          context.showError(state.error);
        } else if (state is UpdateArtistPresentationMediasLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is UpdateArtistPresentationMediasSuccess) {
          // Recarregar dados atualizados para obter as novas URLs
          _hasLoadedData = false;
          _handleGetArtist();
          context.showSuccess('Vídeos salvos com sucesso!');
          router.maybePop();
        } else if (state is UpdateArtistPresentationMediasFailure) {
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
              ...widget.talents.map((talent) {
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
              }).toList(),
              DSSizedBoxSpacing.vertical(16),
              CustomButton(
                label: 'Salvar',
                backgroundColor: colorScheme.onPrimaryContainer,
                textColor: colorScheme.primaryContainer,
                onPressed: (_isLoading || !_hasChanges()) ? null : _onSave,
                isLoading: _isLoading,
              ),
              DSSizedBoxSpacing.vertical(24),
            ],
          ),
        ),
      ),
    );
  }
}

