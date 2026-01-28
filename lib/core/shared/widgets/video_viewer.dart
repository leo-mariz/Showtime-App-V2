import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget reutilizável para visualização de vídeo com controles completos
/// 
/// Suporta:
/// - Vídeos locais (File) e remotos (URL)
/// - Controles de play/pause
/// - Barra de progresso/seekbar para navegação no vídeo
/// - Exibição de tempo atual e duração total
class VideoViewer extends StatefulWidget {
  /// Arquivo de vídeo local (prioridade sobre videoUrl)
  final File? videoFile;
  
  /// URL do vídeo remoto
  final String? videoUrl;
  
  /// Título do vídeo (opcional, exibido no header)
  final String? title;
  
  /// Se true, o vídeo inicia automaticamente
  final bool autoPlay;
  
  /// Se true, o vídeo toca em loop
  final bool loop;

  const VideoViewer({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.title,
    this.autoPlay = false,
    this.loop = false,
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  String? _errorMessage;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Validar que há um vídeo fornecido
    if (widget.videoFile == null && 
        (widget.videoUrl == null || widget.videoUrl!.isEmpty)) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Nenhum vídeo fornecido';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      VideoPlayerController controller;
      
      if (widget.videoFile != null) {
        controller = VideoPlayerController.file(widget.videoFile!);
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      }

      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
          _isLoading = false;
          _isPlaying = widget.autoPlay;
        });

        // Configurar loop
        if (widget.loop) {
          _controller!.setLooping(true);
        }

        // Adicionar listener para quando o vídeo terminar
        _controller!.addListener(_videoListener);

        // Inicializar durações
        setState(() {
          _totalDuration = _controller!.value.duration;
          _currentPosition = _controller!.value.position;
        });

        // Iniciar reprodução se autoPlay
        if (widget.autoPlay) {
          await _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
      _controller?.dispose();
      _controller = null;
    }
  }

  void _videoListener() {
    if (_controller != null && !_isSeeking) {
      if (mounted) {
        setState(() {
          _isPlaying = _controller!.value.isPlaying;
          _currentPosition = _controller!.value.position;
          _totalDuration = _controller!.value.duration;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (_controller == null) return;
    
    setState(() {
      _isSeeking = true;
    });
    
    await _controller!.seekTo(position);
    
    setState(() {
      _isSeeking = false;
      _currentPosition = position;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLoadingIndicator(
                color: Colors.white,
              ),
              SizedBox(height: DSSize.height(16)),
              Text(
                'Carregando vídeo...',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: DSSize.width(48),
              ),
              SizedBox(height: DSSize.height(16)),
              Text(
                'Erro ao carregar vídeo',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: DSSize.height(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Vídeo não disponível',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Vídeo
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),

        // Overlay com controles
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Ícone de play/pause no centro (aparece quando pausado)
                if (!_isPlaying)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(DSSize.width(12)),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: DSSize.width(48),
                      ),
                    ),
                  ),

                // Controles no topo
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.all(DSSize.width(8)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Botão voltar/fechar
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: DSSize.width(24),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          
                          // Título (se fornecido)
                          if (widget.title != null) ...[
                            Expanded(
                              child: Text(
                                widget.title!,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Controles na parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.all(DSSize.width(8)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barra de progresso/seekbar
                          if (_totalDuration.inMilliseconds > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: DSSize.width(8),
                                vertical: DSSize.height(4),
                              ),
                              child: Row(
                                children: [
                                  // Tempo atual
                                  Text(
                                    _formatDuration(_currentPosition),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: DSSize.width(12),
                                    ),
                                  ),
                                  SizedBox(width: DSSize.width(8)),
                                  // Slider de progresso
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                                        thumbColor: Colors.white,
                                        overlayColor: Colors.white.withOpacity(0.2),
                                        thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: DSSize.width(8),
                                        ),
                                        trackHeight: DSSize.height(2),
                                      ),
                                      child: Slider(
                                        value: _currentPosition.inMilliseconds.toDouble().clamp(
                                          0.0,
                                          _totalDuration.inMilliseconds.toDouble(),
                                        ),
                                        min: 0.0,
                                        max: _totalDuration.inMilliseconds.toDouble(),
                                        onChanged: (value) {
                                          _seekTo(Duration(milliseconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: DSSize.width(8)),
                                  // Duração total
                                  Text(
                                    _formatDuration(_totalDuration),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: DSSize.width(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Botão play/pause
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: DSSize.width(32),
                                ),
                                onPressed: _togglePlayPause,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

