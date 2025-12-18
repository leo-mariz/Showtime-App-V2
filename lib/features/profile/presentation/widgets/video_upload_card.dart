import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoUploadCard extends StatefulWidget {
  final String talent;
  final File? videoFile;
  final String? videoUrl;
  final Function(File?) onVideoSelected;
  final VoidCallback onVideoRemoved;

  const VideoUploadCard({
    super.key,
    required this.talent,
    this.videoFile,
    this.videoUrl,
    required this.onVideoSelected,
    required this.onVideoRemoved,
  });

  @override
  State<VideoUploadCard> createState() => _VideoUploadCardState();
}

class _VideoUploadCardState extends State<VideoUploadCard> {
  VideoPlayerController? _controller;
  bool _isLoadingThumbnail = false;

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
    }
  }

  Future<void> _loadThumbnail() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    if (widget.videoFile != null) {
      setState(() {
        _isLoadingThumbnail = true;
      });

      try {
        _controller = VideoPlayerController.file(widget.videoFile!);
        await _controller!.initialize();
        setState(() {
          _isLoadingThumbnail = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingThumbnail = false;
        });
      }
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      setState(() {
        _isLoadingThumbnail = true;
      });

      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
        await _controller!.initialize();
        setState(() {
          _isLoadingThumbnail = false;
        });
      } catch (e) {
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

      final file = await _pickVideo(source);
      if (file != null) {
        widget.onVideoSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar vídeo: $e')),
        );
      }
    }
  }

  Future<ImageSource?> _showVideoSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar vídeo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Câmera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
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
            onTap: _selectVideo,
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
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimaryContainer,
                      ),
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
        ],
      ),
    );
  }
}

