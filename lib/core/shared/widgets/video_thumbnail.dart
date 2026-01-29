import 'dart:io';

import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget de thumbnail de vídeo clicável
class VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final String talentName;
  final VoidCallback onTap;

  const VideoThumbnail({
    super.key,
    required this.videoUrl,
    required this.talentName,
    required this.onTap,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Só tenta inicializar se a URL não for mock/exemplo
    if (widget.videoUrl.isNotEmpty && 
        !widget.videoUrl.contains('example.com') &&
        !widget.videoUrl.contains('http://localhost')) {
      _initializeController();
    } else {
      // Se for URL mock, marca como erro para mostrar placeholder
      _hasError = true;
    }
  }

  Future<void> _initializeController() async {
    try {
      final controller = widget.videoUrl.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          : VideoPlayerController.file(File(widget.videoUrl));

      await controller.initialize();
      
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _hasError = false;
        });
        await controller.setVolume(0);
        await controller.seekTo(Duration.zero);
        await controller.pause();
      }
    } catch (e) {
      debugPrint('Erro ao inicializar o vídeo: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
      // Limpa o controller em caso de erro
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: DSSize.height(120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vídeo ou placeholder
              if (_hasError || !_isInitialized || _controller == null)
                // Placeholder em caso de erro ou não inicializado
                Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: !_hasError && !_isInitialized
                      ? Center(
                          // Mostra loading enquanto está inicializando
                          child: CustomLoadingIndicator(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                      : Column(
                          // Mostra placeholder apenas se houver erro
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library,
                              size: DSSize.width(48),
                              color: onPrimary.withOpacity(0.5),
                            ),
                            SizedBox(height: DSSize.height(8)),
                            Text(
                              widget.talentName,
                              style: textTheme.bodyMedium?.copyWith(
                                color: onPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                )
              else
                // Vídeo inicializado
                VideoPlayer(_controller!),
              // Overlay com ícone de play
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  size: DSSize.width(64),
                  color: Colors.white,
                ),
              ),
              // Nome do talento no canto inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(DSSize.width(12)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    widget.talentName,
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

