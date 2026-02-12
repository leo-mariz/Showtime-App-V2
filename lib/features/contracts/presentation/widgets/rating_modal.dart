import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/contracts/presentation/widgets/rating_section.dart';

/// Resultado ao fechar o modal de avaliação.
/// - [rating] e [comment] preenchidos quando o usuário tocou em "Avaliar".
/// - [null] quando tocou em "Avaliar depois" ou fechou o modal.
class RatingModalResult {
  final int rating;
  final String? comment;

  RatingModalResult({required this.rating, this.comment});
}

/// Modal de avaliação com header "Avaliando [Nome]",
/// widget de avaliação (estrelas + comentário), botão "Avaliar" e "Avaliar depois".
class RatingModal extends StatefulWidget {
  /// Nome da pessoa sendo avaliada (ex.: artista ou anfitrião).
  final String personName;

  /// Se true, está avaliando artista (cliente); se false, avaliando anfitrião (artista).
  final bool isRatingArtist;

  const RatingModal({
    super.key,
    required this.personName,
    this.isRatingArtist = true,
  });

  /// Exibe o modal de avaliação.
  /// Retorna [RatingModalResult] se o usuário tocou em "Avaliar", ou null se "Avaliar depois" / fechou.
  static Future<RatingModalResult?> show({
    required BuildContext context,
    required String personName,
    bool isRatingArtist = true,
  }) async {
    return await showModalBottomSheet<RatingModalResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (modalContext) => RatingModal(
        personName: personName,
        isRatingArtist: isRatingArtist,
      ),
    );
  }

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _currentRating = 0;
  String? _currentComment;

  void _onRatingChanged(int rating, String? comment) {
    setState(() {
      _currentRating = rating;
      _currentComment = comment;
    });
  }

  void _onAvaliar() {
    if (_currentRating > 0) {
      Navigator.of(context).pop(RatingModalResult(
        rating: _currentRating,
        comment: _currentComment,
      ));
    }
  }

  void _onAvaliarDepois() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.only(
        left: DSSize.width(16),
        right: DSSize.width(16),
        top: DSSize.height(16),
        bottom: MediaQuery.of(context).viewInsets.bottom + DSSize.height(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          // Header: "Avaliando Nome"
          Text(
            'Avaliando ${widget.personName}',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onPrimary,
            ),
          ),
          DSSizedBoxSpacing.vertical(16),
          // Widget de avaliação (estrelas + comentário, sem botão interno)
          RatingSection(
            personName: widget.personName,
            isRatingArtist: widget.isRatingArtist,
            isLoading: false,
            hasAlreadyRated: false,
            showHeaderLabel: false,
            showSubmitButton: false,
            onRatingChanged: _onRatingChanged,
          ),
          DSSizedBoxSpacing.vertical(16),
          // Botão principal: Avaliar (igual ao event detail)
          CustomButton(
            label: 'Avaliar',
            onPressed: _currentRating > 0 ? _onAvaliar : null,
            icon: Icons.stars_sharp,
            iconOnLeft: true,
            height: DSSize.height(44),
          ),
          DSSizedBoxSpacing.vertical(12),
          // Botão discreto: Avaliar depois
          TextButton(
            onPressed: _onAvaliarDepois,
            child: Text(
              'Avaliar depois',
              style: textTheme.bodyMedium?.copyWith(
                color: onPrimary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
