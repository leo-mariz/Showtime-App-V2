import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';

/// Seção de tabs para Show, Vídeos e Disponibilidades
class TabsSection extends StatelessWidget {
  final ArtistEntity artist;
  final Function(String videoUrl)? onVideoTap;
  final Widget? calendarTab; // Tab customizada para calendário

  const TabsSection({
    super.key,
    required this.artist,
    this.onVideoTap,
    this.calendarTab,
  });

  bool get _hasTalents => 
      artist.presentationMedias?.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    // Sempre mostrar as tabs, mesmo quando não houver dados
    final List<String> tabs = [];
    tabs.add('Sobre o Show');
    tabs.add('Vídeos');
    if (calendarTab != null) {
      tabs.add('Disponibilidades');
    }

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
            height: _calculateTabHeight(),
            child: TabBarView(
              children: [
                _buildGenresTab(context),
                _buildTalentsTab(context),
                if (calendarTab != null) calendarTab!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTabHeight() {
    if (calendarTab != null) {
      // Altura maior para o calendário
      return DSSize.height(500);
    }
    // Altura padrão para Estilos/Talentos
    return _hasTalents ? DSSize.height(220) : DSSize.height(120);
  }

  Widget _buildGenresTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final professionalInfo = artist.professionalInfo;
    
    // Verificar se há informações para mostrar
    final hasSpecialty = professionalInfo?.specialty?.isNotEmpty ?? false;
    final hasMinimumDuration = professionalInfo?.minimumShowDuration != null;
    final hasPreparationTime = professionalInfo?.preparationTime != null;
    
    if (!hasSpecialty && !hasMinimumDuration && !hasPreparationTime) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            'O artista não possui informações de show cadastradas',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Talentos (Specialty) - mantém como estava se existir no arquivo
          
          // Cards lado a lado: tempo mínimo e tempo de preparação
          if (hasMinimumDuration || hasPreparationTime) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasMinimumDuration)
                  Expanded(
                    child: _buildDurationCard(
                      context: context,
                      title: 'Duração mínima',
                      value: _formatDuration(Duration(minutes: professionalInfo!.minimumShowDuration!)),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                if (hasMinimumDuration && hasPreparationTime) SizedBox(width: DSSize.width(12)),
                if (hasPreparationTime)
                  Expanded(
                    child: _buildDurationCard(
                      context: context,
                      title: 'Preparação',
                      value: _formatDuration(Duration(minutes: professionalInfo!.preparationTime!)),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationCard({
    required BuildContext context,
    required String title,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DSSize.height(6)),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    }
    return '${minutes}min';
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
          width: MediaQuery.of(context).size.width * 0.7,
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

