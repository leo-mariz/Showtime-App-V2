import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/genre_chip.dart';
import 'package:app/core/shared/widgets/video_thumbnail.dart';
import 'package:flutter/material.dart';

/// Seção de tabs para Show, Vídeos e Disponibilidades.
/// Para grupos (ensemble), passe [ensemble] para exibir dados do grupo (professionalInfo, vídeo).
/// [artist] é opcional quando [ensemble] está presente (ex.: tela do conjunto aberta pela aba Conjuntos).
class TabsSection extends StatelessWidget {
  final ArtistEntity? artist;
  final Function(String videoUrl)? onVideoTap;
  final Widget? calendarTab; // Tab customizada para calendário
  /// Quando informado, exibe dados do conjunto (professionalInfo, vídeo único).
  final EnsembleEntity? ensemble;
  /// Talentos do artista dono do conjunto (exibidos na aba "Sobre o Show" quando [ensemble] está presente).
  final List<String>? ownerArtistSpecialty;

  const TabsSection({
    super.key,
    this.artist,
    this.onVideoTap,
    this.calendarTab,
    this.ensemble,
    this.ownerArtistSpecialty,
  }) : assert(artist != null || ensemble != null, 'Informe artist ou ensemble');

  bool get _hasTalents =>
      ensemble != null
          ? (ensemble!.presentationVideoUrl != null && ensemble!.presentationVideoUrl!.isNotEmpty)
          : (artist?.presentationMedias?.isNotEmpty ?? false);



  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [];
    tabs.add('Sobre o Show');
    tabs.add('Vídeos');

    final isEnsembleWithTalents = ensemble != null;
    if (isEnsembleWithTalents) {
      tabs.add('Talentos');
    }

    if (calendarTab != null) {
      tabs.add('Disponibilidades');
    }

    final tabViews = <Widget>[
      _buildGenresTab(context),
      _buildTalentsTab(context),
    ];
    if (isEnsembleWithTalents) {
      tabViews.add(_buildEnsembleTalentsListTab(context));
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
    if (ensemble != null) {
      return DSSize.height(280);
    }
    return _hasTalents ? DSSize.height(220) : DSSize.height(120);
  }

  Widget _buildGenresTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final professionalInfo = ensemble?.professionalInfo ?? artist?.professionalInfo;
    final isEnsemble = ensemble != null;
    // Para conjunto: talentos do dono (ownerArtistSpecialty); para artista: professionalInfo.specialty
    final hasOwnerSpecialty = isEnsemble && (ownerArtistSpecialty?.isNotEmpty ?? false);
    final hasSpecialty = !isEnsemble && (professionalInfo?.specialty?.isNotEmpty ?? false);
    final hasMinimumDuration = professionalInfo?.minimumShowDuration != null;
    final hasPreparationTime = professionalInfo?.preparationTime != null;

    if (!hasSpecialty && !hasOwnerSpecialty && !hasMinimumDuration && !hasPreparationTime) {
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
          // if (hasOwnerSpecialty || hasSpecialty) ...[
          //   Wrap(
          //     spacing: DSSize.width(8),
          //     runSpacing: DSSize.height(6),
          //     children: (hasOwnerSpecialty ? ownerArtistSpecialty! : professionalInfo!.specialty!)
          //         .map((t) => GenreChip(label: t))
          //         .toList(),
          //   ),
          //   if (hasMinimumDuration || hasPreparationTime) SizedBox(height: DSSize.height(16)),
          // ],
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
      talents = artist?.presentationMedias ?? {};
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

  /// Aba "Talentos" do conjunto: lista de talentos (repertório) do grupo.
  Widget _buildEnsembleTalentsListTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final talents = ensemble?.talents ?? const [];

    if (talents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
          child: Text(
            'O conjunto não possui talentos cadastrados',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: DSSize.height(12)),
      child: Wrap(
        spacing: DSSize.width(8),
        runSpacing: DSSize.height(8),
        children: talents.map((t) => GenreChip(label: t)).toList(),
      ),
    );
  }
}

