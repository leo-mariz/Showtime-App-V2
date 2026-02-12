import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/contracts/presentation/widgets/rating_section.dart';

/// Modal de avaliação com header "Avaliando [Nome]",
/// opcional referência do contrato (tipo de evento, data, hora), estrelas + comentário e botões.
/// Widget de UI pura: recebe [onAvaliar] e [onAvaliarDepois] para executar a ação de cada botão.
class RatingModal extends StatefulWidget {
  /// Nome da pessoa sendo avaliada (ex.: artista ou anfitrião/cliente).
  final String personName;

  /// Se true, está avaliando artista (cliente); se false, avaliando anfitrião (artista).
  final bool isRatingArtist;

  /// Referência do contrato (opcional): tipo de evento.
  final String? eventTypeName;

  /// Data do evento (opcional).
  final DateTime? date;

  /// Hora do evento (opcional, ex.: "18:00").
  final String? time;

  /// Chamado quando o usuário toca em "Avaliar" (rating > 0). O modal fecha em seguida.
  final void Function(int rating, String? comment) onAvaliar;

  /// Chamado quando o usuário toca em "Avaliar depois". O modal fecha em seguida.
  final VoidCallback onAvaliarDepois;

  const RatingModal({
    super.key,
    required this.personName,
    required this.onAvaliar,
    required this.onAvaliarDepois,
    this.isRatingArtist = true,
    this.eventTypeName,
    this.date,
    this.time,
  });

  /// Exibe o modal de avaliação.
  /// [onAvaliar] e [onAvaliarDepois] são as funções executadas ao tocar em cada botão (modal fecha após chamá-las).
  static Future<void> show({
    required BuildContext context,
    required String personName,
    required void Function(int rating, String? comment) onAvaliar,
    required VoidCallback onAvaliarDepois,
    bool isRatingArtist = true,
    String? eventTypeName,
    DateTime? date,
    String? time,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (modalContext) => RatingModal(
        personName: personName,
        isRatingArtist: isRatingArtist,
        onAvaliar: onAvaliar,
        onAvaliarDepois: onAvaliarDepois,
        eventTypeName: eventTypeName,
        date: date,
        time: time,
      ),
    );
  }

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _currentRating = 0;
  String? _currentComment;
  bool _isSubmitting = false;

  void _onRatingChanged(int rating, String? comment) {
    setState(() {
      _currentRating = rating;
      _currentComment = comment;
    });
  }

  void _onAvaliar() {
    if (_currentRating > 0 && !_isSubmitting) {
      setState(() => _isSubmitting = true);
      widget.onAvaliar(_currentRating, _currentComment);
      // Modal permanece aberto; quem exibiu deve fechá-lo ao receber sucesso/falha do bloc.
    }
  }

  void _onAvaliarDepois() {
    if (!_isSubmitting) {
      setState(() => _isSubmitting = true);
      widget.onAvaliarDepois();
      // Modal permanece aberto; quem exibiu deve fechá-lo ao receber sucesso/falha do bloc.
    }
  }

  Widget _buildContractReference(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final parts = <String>[];
    if (widget.eventTypeName != null && widget.eventTypeName!.isNotEmpty) {
      parts.add(widget.eventTypeName!);
    }
    if (widget.date != null) {
      parts.add(DateFormat('dd/MM/yyyy').format(widget.date!));
    }
    if (widget.time != null && widget.time!.isNotEmpty) {
      parts.add(widget.time!);
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(8),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(DSSize.width(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note, size: DSSize.width(18), color: colorScheme.onSurfaceVariant),
          SizedBox(width: DSSize.width(8)),
          Expanded(
            child: Text(
              parts.join(' • '),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;

    final viewInsets = MediaQuery.of(context).viewInsets;

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
        bottom: viewInsets.bottom + DSSize.height(24),
      ),
      child: SingleChildScrollView(
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
            // Referência do contrato (tipo de evento, data, hora) quando fornecida
            if (widget.eventTypeName != null || widget.date != null || widget.time != null) ...[
              DSSizedBoxSpacing.vertical(8),
              _buildContractReference(context),
              DSSizedBoxSpacing.vertical(8),
            ] else
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
            label: _isSubmitting ? 'Enviando...' : 'Avaliar',
            onPressed: (!_isSubmitting && _currentRating > 0) ? _onAvaliar : null,
            icon: _isSubmitting ? Icons.hourglass_empty : Icons.stars_sharp,
            iconOnLeft: true,
            height: DSSize.height(44),
          ),
          DSSizedBoxSpacing.vertical(12),
          // Botão discreto: Avaliar depois
          TextButton(
            onPressed: _isSubmitting ? null : _onAvaliarDepois,
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
      ),
    );
  }
}
