import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/informative_banner.dart';
import 'package:app/core/shared/widgets/custom_message_field.dart';
import 'package:app/core/shared/widgets/custom_button.dart';

/// Widget de seção de avaliação para contratos completados
/// 
/// Exibe UI para avaliar artista (cliente) ou anfitrião (artista)
/// com estrelas, comentário opcional e botões de ação
class RatingSection extends StatefulWidget {
  /// Nome da pessoa a ser avaliada (artista ou anfitrião)
  final String personName;
  
  /// Se true, está avaliando um artista (cliente avaliando)
  /// Se false, está avaliando um anfitrião (artista avaliando)
  final bool isRatingArtist;
  
  /// Se está carregando (enviando avaliação)
  final bool isLoading;
  
  /// Se já foi avaliado
  final bool hasAlreadyRated;
  
  /// Rating existente (1-5) se já foi avaliado
  final int? existingRating;
  
  /// Comentário existente se já foi avaliado
  final String? existingComment;
  
  /// Callback quando o usuário clicar em "Avaliar"
  /// Recebe o rating (1-5) e o comentário (opcional)
  final void Function(int rating, String? comment)? onSubmit;

  /// Se false, não exibe o rótulo "Avaliando: [nome]" (útil quando usado dentro de modal com header próprio).
  final bool showHeaderLabel;

  /// Se false, não exibe o botão "Avaliar" (útil quando o modal tem seus próprios botões).
  final bool showSubmitButton;

  /// Chamado quando o rating ou o comentário mudam (para o pai sincronizar estado, ex.: modal).
  final void Function(int rating, String? comment)? onRatingChanged;

  const RatingSection({
    super.key,
    required this.personName,
    this.isRatingArtist = true,
    this.isLoading = false,
    this.hasAlreadyRated = false,
    this.existingRating,
    this.existingComment,
    this.onSubmit,
    this.showHeaderLabel = true,
    this.showSubmitButton = true,
    this.onRatingChanged,
  });

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  late int _selectedRating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.existingRating ?? 0;
    _commentController = TextEditingController(text: widget.existingComment ?? '');
  }

  @override
  void didUpdateWidget(RatingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualizar rating se mudou ou se agora está marcado como já avaliado
    if (widget.existingRating != oldWidget.existingRating || 
        (widget.hasAlreadyRated && !oldWidget.hasAlreadyRated)) {
      _selectedRating = widget.existingRating ?? 0;
    }
    // Atualizar comentário se mudou ou se agora está marcado como já avaliado
    if (widget.existingComment != oldWidget.existingComment || 
        (widget.hasAlreadyRated && !oldWidget.hasAlreadyRated)) {
      _commentController.text = widget.existingComment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getInformativeMessage() {
    if (widget.isRatingArtist ) {
      return 'Sua avaliação é muito importante para o artista! Ela ajuda outros anfitriões a conhecerem melhor o trabalho dele e contribui para o crescimento da plataforma.';
    } else {
      return 'Sua avaliação é muito importante para o anfitrião! Ela ajuda outros artistas a conhecerem melhor o recepcionamento do anfitrião e contribui para o crescimento da plataforma.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;
    final primaryContainer = colorScheme.primaryContainer;

    return Container(
      padding: EdgeInsets.only(left: DSSize.width(16), right: DSSize.width(16), top: DSSize.height(0), bottom: DSSize.height(16)),
      decoration: BoxDecoration(
        color: primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: primaryContainer.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Título da seção
          // Text(
          //   _getSectionTitle(),
          //   style: textTheme.titleMedium?.copyWith(
          //     color: onPrimary,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          DSSizedBoxSpacing.vertical(12),

          // Banner informativo
          if (!widget.hasAlreadyRated)
          InformativeBanner(
            message: _getInformativeMessage(),
            icon: Icons.star_outline_rounded,
            textColor: onPrimary,
          ),
          DSSizedBoxSpacing.vertical(16),

          // Nome da pessoa sendo avaliada (pode ser ocultado em modal)
          if (widget.showHeaderLabel)
            Text.rich(
              TextSpan(
                text: widget.hasAlreadyRated ? 'Avaliado: ' : 'Avaliando: ',
                style: textTheme.bodyMedium?.copyWith(
                  color: onPrimary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: widget.personName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: onPrimary.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.showHeaderLabel) DSSizedBoxSpacing.vertical(16),

          // Estrelas
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= _selectedRating;
                final isDisabled = widget.isLoading || widget.hasAlreadyRated;
                
                return GestureDetector(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      _selectedRating = starIndex;
                      widget.onRatingChanged?.call(
                        _selectedRating,
                        _commentController.text.trim().isEmpty
                            ? null
                            : _commentController.text.trim(),
                      );
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected 
                          ? Colors.amber 
                          : (isDisabled 
                              ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                              : colorScheme.onSurfaceVariant),
                      size: DSSize.width(40),
                    ),
                  ),
                );
              }),
            ),
          ),
          DSSizedBoxSpacing.vertical(8),
          
          // Texto indicando a seleção (opcional)
          if (_selectedRating > 0)
            Center(
              child: Text(
                _selectedRating == 1 
                    ? 'Péssimo'
                    : _selectedRating == 2
                        ? 'Ruim'
                        : _selectedRating == 3
                            ? 'Regular'
                            : _selectedRating == 4
                                ? 'Bom'
                                : 'Excelente',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          DSSizedBoxSpacing.vertical(16),

          // Campo de comentário (opcional)
          CustomMessageField(
            controller: _commentController,
            labelText: 'Comentário (opcional)',
            hintText: 'Conte mais sobre sua experiência...',
            onChanged: (value) {
              widget.onRatingChanged?.call(
                _selectedRating,
                value.trim().isEmpty ? null : value.trim(),
              );
            },
            readOnly: widget.isLoading || widget.hasAlreadyRated,
          ),
          DSSizedBoxSpacing.vertical(16),

          // Botão (só aparece se ainda não foi avaliado e showSubmitButton)
          if (!widget.hasAlreadyRated && widget.showSubmitButton)
            Row(
              children: [
                DSSizedBoxSpacing.horizontal(12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    label: 'Avaliar',
                    onPressed: (_selectedRating > 0 && !widget.isLoading && widget.onSubmit != null) ? () {
                      final comment = _commentController.text.trim().isEmpty 
                          ? null 
                          : _commentController.text.trim();
                      widget.onSubmit!(_selectedRating, comment);
                    } : null,
                    icon: Icons.stars_sharp,
                    iconOnLeft: true,
                    height: DSSize.height(44),
                    isLoading: widget.isLoading,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

