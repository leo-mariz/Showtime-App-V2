import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/features/artist_profile/presentation/widgets/genre_chip.dart';
import 'package:app/features/artist_profile/presentation/widgets/video_thumbnail.dart';
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
    if (!_hasGenres && !_hasTalents) {
      return const SizedBox.shrink();
    }

    final List<String> tabs = [];
    if (_hasGenres) tabs.add('Estilos');
    if (_hasTalents) tabs.add('Talentos');

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
                if (_hasGenres) _buildGenresTab(),
                if (_hasTalents) _buildTalentsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresTab() {
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
    final talents = artist.presentationMedias ?? {};
    
    if (talents.isEmpty) {
      return Center(
        child: Text(
          'Nenhum talento disponível',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

