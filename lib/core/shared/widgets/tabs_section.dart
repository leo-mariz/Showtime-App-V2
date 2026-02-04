import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/genre_chip.dart';
import 'package:app/core/shared/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';

/// Seção de tabs para Show, Vídeos e Disponibilidades.
/// Para grupos (ensemble), passe [ensemble] e [ownerDisplayName] para exibir dados do grupo e tab "Integrantes" com nome + talentos.
class TabsSection extends StatelessWidget {
  final ArtistEntity artist;
  final Function(String videoUrl)? onVideoTap;
  final Widget? calendarTab; // Tab customizada para calendário
  /// Nomes dos integrantes (para artista com lista simples); quando não vazio, adiciona tab "Integrantes"
  final List<String>? memberNames;
  /// Quando informado, exibe dados do conjunto (professionalInfo, vídeo único, integrantes com nome + talentos)
  final EnsembleEntity? ensemble;
  /// Nome do dono do conjunto (exibido na tab Integrantes para o membro owner)
  final String? ownerDisplayName;

  const TabsSection({
    super.key,
    required this.artist,
    this.onVideoTap,
    this.calendarTab,
    this.memberNames,
    this.ensemble,
    this.ownerDisplayName,
  });

  bool get _hasTalents =>
      ensemble != null
          ? (ensemble!.presentationVideoUrl != null && ensemble!.presentationVideoUrl!.isNotEmpty)
          : (artist.presentationMedias?.isNotEmpty ?? false);

  bool get _hasMembersTab =>
      ensemble != null
          ? true // Conjunto sempre tem pelo menos o dono (exibido na tab)
          : (memberNames != null && memberNames!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [];
    tabs.add('Sobre o Show');
    tabs.add('Vídeos');
    if (_hasMembersTab) {
      tabs.add('Integrantes');
    }
    if (calendarTab != null) {
      tabs.add('Disponibilidades');
    }

    final tabViews = <Widget>[
      _buildGenresTab(context),
      _buildTalentsTab(context),
    ];
    if (_hasMembersTab) {
      tabViews.add(_buildMembersTab(context));
    }
    if (calendarTab != null) {
      tabViews.add(calendarTab!);
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
              children: tabViews,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTabHeight() {
    if (calendarTab != null) {
      return DSSize.height(500);
    }
    if (_hasMembersTab) {
      return DSSize.height(200);
    }
    return _hasTalents ? DSSize.height(220) : DSSize.height(120);
  }

  Widget _buildMembersTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (ensemble != null) {
      final members = ensemble!.members ?? [];
      final itemCount = 1 + members.length;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final displayName = index == 0
                ? (ownerDisplayName ?? 'Dono')
                : (members[index - 1].name ?? 'Integrante');
            final specialties = index == 0 ? <String>[] : (members[index - 1].specialty ?? []);
            return Padding(
              padding: EdgeInsets.only(bottom: DSSize.height(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: DSSize.width(20),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: DSSize.width(12)),
                      Expanded(
                        child: Text(
                          displayName,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (specialties.isNotEmpty) ...[
                    SizedBox(height: DSSize.height(8)),
                    Wrap(
                      spacing: DSSize.width(8),
                      runSpacing: DSSize.height(6),
                      children: specialties
                          .map((t) => GenreChip(label: t))
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }

    final names = memberNames!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: names.length,
        itemBuilder: (context, index) {
          final memberName = names[index];
          return Padding(
            padding: EdgeInsets.only(bottom: DSSize.height(8)),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: DSSize.width(20),
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: DSSize.width(12)),
                Text(
                  memberName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenresTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final professionalInfo = ensemble?.professionalInfo ?? artist.professionalInfo;
    final isEnsemble = ensemble != null;

    // Para conjunto não exibimos specialty (talento é por integrante)
    final hasSpecialty = !isEnsemble && (professionalInfo?.specialty?.isNotEmpty ?? false);
    final hasMinimumDuration = professionalInfo?.minimumShowDuration != null;
    final hasPreparationTime = professionalInfo?.preparationTime != null;

    if (!hasSpecialty && !hasMinimumDuration && !hasPreparationTime) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            isEnsemble
                ? 'O conjunto não possui informações de show cadastradas'
                : 'O artista não possui informações de show cadastradas',
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
    final Map<String, String> talents;
    final bool isEnsemble = ensemble != null;
    if (ensemble != null && ensemble!.presentationVideoUrl != null && ensemble!.presentationVideoUrl!.isNotEmpty) {
      talents = {'Apresentação': ensemble!.presentationVideoUrl!};
    } else {
      talents = artist.presentationMedias ?? {};
    }

    if (talents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            isEnsemble
                ? 'O conjunto não possui vídeo de apresentação'
                : 'O artista não possui vídeos de apresentações',
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

