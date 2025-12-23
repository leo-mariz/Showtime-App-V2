import 'dart:io';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/profile/artists/presentation/widgets/video_upload_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Inicializa o mapa de vídeos para cada talento
    for (final talent in widget.talents) {
      _selectedVideos[talent] = null;
      _videoUrls[talent] = null;
    }
  }

  void _onVideoSelected(String talent, File? videoFile) {
    setState(() {
      _selectedVideos[talent] = videoFile;
    });
  }

  void _onVideoRemoved(String talent) {
    setState(() {
      _selectedVideos[talent] = null;
      _videoUrls[talent] = null;
    });
  }

  void _onSave() {
    // TODO: Implementar upload dos vídeos e salvamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vídeos salvos com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
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
              onPressed: _onSave,
            ),
            DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
    );
  }
}

