import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/genre_chip.dart';
import 'package:app/core/shared/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';

/// Seção de tabs para Estilos e Talentos
class TabsSection extends StatelessWidget {
  final ArtistEntity artist;
  final Function(String videoUrl)? onVideoTap;

  const TabsSection({
    super.key,
    required this.artist,
    this.onVideoTap,
  });

  bool get _hasGenres => 
      artist.professionalInfo?.genrePreferences?.isNotEmpty ?? false;
  
  bool get _hasTalents => 
      artist.presentationMedias?.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    // Sempre mostrar as tabs, mesmo quando não houver dados
    final List<String> tabs = [];
    tabs.add('Estilos');
    tabs.add('Talentos');

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            indicatorColor: Theme.of(context).colorScheme.onPrimaryContainer,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
          SizedBox(
            height: _hasTalents ? DSSize.height(220) : DSSize.height(120),
            child: TabBarView(
              children: [
                _buildGenresTab(context),
                _buildTalentsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    if (!_hasGenres) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            'O artista não possui estilos musicais cadastrados',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
      child: Wrap(
        spacing: DSSize.width(8),
        runSpacing: DSSize.height(8),
        children: artist.professionalInfo?.genrePreferences?.map(
              (genre) => GenreChip(label: genre),
            ).toList() ?? [],
      ),
    );
  }

  Widget _buildTalentsTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final talents = artist.presentationMedias ?? {};
    
    if (talents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            'O artista não possui vídeos de apresentações',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
      itemCount: talents.length,
      itemBuilder: (context, index) {
        final entry = talents.entries.elementAt(index);
        final talentName = entry.key;
        final videoUrl = entry.value;

        return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: EdgeInsets.only(
            right: DSSize.width(16),
          ),
          child: VideoThumbnail(
            videoUrl: videoUrl,
            talentName: talentName,
            onTap: () => onVideoTap?.call(videoUrl),
          ),
        );
      },
    );
  }
}

