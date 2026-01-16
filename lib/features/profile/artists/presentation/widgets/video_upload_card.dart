import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/selection_modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoUploadCard extends StatefulWidget {
  final String talent;
  final File? videoFile;
  final String? videoUrl;
  final Function(File?) onVideoSelected;
  final VoidCallback onVideoRemoved;
  final bool enabled;

  const VideoUploadCard({
    super.key,
    required this.talent,
    this.videoFile,
    this.videoUrl,
    required this.onVideoSelected,
    required this.onVideoRemoved,
    this.enabled = true,
  });

  @override
  State<VideoUploadCard> createState() => _VideoUploadCardState();
}

class _VideoUploadCardState extends State<VideoUploadCard> {
  VideoPlayerController? _controller;
  bool _isLoadingThumbnail = false;
  File? _lastProcessedFile; // Rastrear o último arquivo processado

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(VideoUploadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile != widget.videoFile || oldWidget.videoUrl != widget.videoUrl) {
      _loadThumbnail();
    } else if (_isLoadingThumbnail) {
      // Se está em loading mas não houve mudança no vídeo, verificar se foi rejeitado
      // Isso acontece quando o vídeo é rejeitado na validação (ex: > 60 segundos)
      _checkIfVideoWasRejected();
    }
  }
  
  void _checkIfVideoWasRejected() {
    // Se está em loading mas não há vídeo nem URL, significa que foi rejeitado
    if (_isLoadingThumbnail && 
        widget.videoFile == null && 
        (widget.videoUrl == null || widget.videoUrl!.isEmpty)) {
      // Aguardar um pouco para garantir que a validação foi processada
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && 
            widget.videoFile == null && 
            (widget.videoUrl == null || widget.videoUrl!.isEmpty)) {
          setState(() {
            _isLoadingThumbnail = false;
          });
        }
      });
    }
  }

  Future<void> _loadThumbnail() async {
    // Se já está em loading (por exemplo, iniciado pelo _selectVideo), manter
    // Caso contrário, iniciar o loading
    if (!_isLoadingThumbnail && mounted) {
      setState(() {
        _isLoadingThumbnail = true;
      });
    }

    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    if (widget.videoFile != null) {
      try {
        _controller = VideoPlayerController.file(widget.videoFile!);
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isLoadingThumbnail = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingThumbnail = false;
          });
        }
      }
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isLoadingThumbnail = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingThumbnail = false;
          });
        }
      }
    } else {
      // Se não há vídeo nem URL, não precisa de loading
      if (mounted) {
        setState(() {
          _isLoadingThumbnail = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _selectVideo() async {
    try {
      final source = await _showVideoSourceDialog();
      if (source == null) return;

      // Mostrar loading imediatamente antes de selecionar o vídeo
      if (mounted) {
        setState(() {
          _isLoadingThumbnail = true;
          _lastProcessedFile = null; // Resetar arquivo processado
        });
      }

      final file = await _pickVideo(source);
      if (file != null) {
        // Garantir que o loading seja visível por pelo menos 300ms para feedback visual
        final loadStartTime = DateTime.now();
        
        // Armazenar o arquivo que está sendo processado
        _lastProcessedFile = file;
        
        widget.onVideoSelected(file);
        
        // Aguardar um tempo mínimo para garantir feedback visual
        final elapsed = DateTime.now().difference(loadStartTime);
        if (elapsed.inMilliseconds < 300) {
          await Future.delayed(Duration(milliseconds: 300 - elapsed.inMilliseconds));
        }
        
        // Verificar se o vídeo foi aceito após um tempo razoável
        // Se após 1 segundo o widget.videoFile ainda não foi atualizado, significa que foi rejeitado
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && 
              _isLoadingThumbnail && 
              _lastProcessedFile == file && 
              widget.videoFile != file) {
            // Vídeo foi rejeitado (não foi atualizado no widget)
            setState(() {
              _isLoadingThumbnail = false;
              _lastProcessedFile = null;
            });
          }
        });
        
        // O _loadThumbnail() será chamado pelo didUpdateWidget, que vai continuar o loading
        // até o thumbnail estar pronto
      } else {
        // Se não selecionou arquivo, remover loading
        if (mounted) {
          setState(() {
            _isLoadingThumbnail = false;
            _lastProcessedFile = null;
          });
        }
      }
    } catch (e) {
      // Em caso de erro, remover loading
      if (mounted) {
        setState(() {
          _isLoadingThumbnail = false;
          _lastProcessedFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar vídeo: $e')),
        );
      }
    }
  }

  Future<ImageSource?> _showVideoSourceDialog() async {

    return SelectionModal.show<ImageSource>(
      context: context,
      title: 'Selecionar vídeo',
      showCancelButton: false,
      options: [
        SelectionModalOption<ImageSource>(
          icon: Icons.photo_library,
          title: 'Galeria',
          value: ImageSource.gallery,
        ),
        SelectionModalOption<ImageSource>(
          icon: Icons.videocam,
          title: 'Câmera',
          value: ImageSource.camera,
        ),
      ],
    );
  }

  Future<File?> _pickVideo(ImageSource source) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? pickedFile = await imagePicker.pickVideo(
        source: source,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasVideo = widget.videoFile != null || (widget.videoUrl != null && widget.videoUrl!.isNotEmpty);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.talent,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          GestureDetector(
            onTap: widget.enabled ? _selectVideo : null,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.6,
              child: Container(
              width: double.infinity,
              height: DSSize.height(200),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DSSize.width(12)),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: _isLoadingThumbnail
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // Fundo com cor de loading
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(DSSize.width(12)),
                          ),
                        ),
                        // Indicador de loading centralizado
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomLoadingIndicator(
                                color: colorScheme.onPrimaryContainer,
                              ),
                              DSSizedBoxSpacing.vertical(16),
                              Text(
                                'Carregando vídeo...',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : hasVideo && _controller != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(DSSize.width(12)),
                              child: VideoPlayer(_controller!),
                            ),
                            // Overlay com botão de remover
                            Positioned(
                              top: DSSize.height(8),
                              right: DSSize.width(8),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: colorScheme.onPrimary,
                                  size: DSSize.width(24),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.surface.withOpacity(0.8),
                                ),
                                onPressed: () {
                                  widget.onVideoRemoved();
                                },
                              ),
                            ),
                            // Ícone de play no centro
                            Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                size: DSSize.width(48),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: DSSize.width(48),
                              color: colorScheme.onSurfaceVariant,
                            ),
                            DSSizedBoxSpacing.vertical(8),
                            Text(
                              'Toque para adicionar vídeo',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

