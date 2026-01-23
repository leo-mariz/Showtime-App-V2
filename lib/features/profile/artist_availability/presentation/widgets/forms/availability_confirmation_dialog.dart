import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlaps_dto.dart';

/// Dialog de confirmação para disponibilidades com sobreposições e shows
/// 
/// Exibe informações sobre dias com sobreposições e dias com shows marcados
class AvailabilityConfirmationDialog extends StatelessWidget {
  final String title;
  final bool isClose;
  final CheckOverlapsDto? checkOverlapsDto;
  final List<DayOverlapInfo> daysWithOverlap;
  final List<AvailabilityDayEntity> daysWithBookedSlot;
  final List<AvailabilityDayEntity> daysWithoutOverlap;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const AvailabilityConfirmationDialog({
    super.key,
    required this.title,
    required this.isClose,
    this.checkOverlapsDto,
    required this.daysWithOverlap,
    required this.daysWithBookedSlot,
    this.daysWithoutOverlap = const [],
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
  });

  /// Método estático para exibir o diálogo de confirmação
  /// 
  /// Retorna `true` se o usuário confirmou, `false` se cancelou
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required bool isClose,
    CheckOverlapsDto? checkOverlapsDto,
    required List<DayOverlapInfo> daysWithOverlap,
    required List<AvailabilityDayEntity> daysWithBookedSlot,
    List<AvailabilityDayEntity> daysWithoutOverlap = const [],
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AvailabilityConfirmationDialog(
        title: title,
        isClose: isClose,
        checkOverlapsDto: checkOverlapsDto,
        daysWithOverlap: daysWithOverlap,
        daysWithBookedSlot: daysWithBookedSlot,
        daysWithoutOverlap: daysWithoutOverlap,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  /// Formata horário para exibição
  String _formatTime(String timeString) {
    return timeString; // Já vem no formato "HH:mm"
  }

  /// Gera widget com mensagem detalhada do período
  Widget _buildDetailedMessageWidget(ThemeData theme, ColorScheme colorScheme) {
    if (checkOverlapsDto?.patternMetadata?.recurrence == null) {
      return const SizedBox.shrink();
    }

    final recurrence = checkOverlapsDto!.patternMetadata!.recurrence!;
    final startDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(recurrence.originalStartDate);
    final endDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(recurrence.originalEndDate);
    
    final hasConflict = daysWithOverlap.isNotEmpty || daysWithBookedSlot.isNotEmpty;
    final action = isClose ? 'FECHAR' : 'ABRIR';
    
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          // Primeira linha com ação em negrito
          TextSpan(
            text: hasConflict ? 'Ao ' : 'Confirmar ',
          ),
          TextSpan(
            text: action,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' o período de:\n',
          ),
          // Informações do período
          TextSpan(text: '• Data inicial: $startDate\n'),
          TextSpan(text: '• Data final: $endDate\n'),
          // Horários
          if (checkOverlapsDto!.startTime != null && checkOverlapsDto!.endTime != null)
            TextSpan(text: '• Horário: ${checkOverlapsDto!.startTime} - ${checkOverlapsDto!.endTime}\n')
          else
            TextSpan(text: '• Horário: Todos os horários\n'),
          // Valor (apenas para abertura)
          if (!isClose && checkOverlapsDto!.valorHora != null)
            TextSpan(text: '• Valor por hora: R\$ ${checkOverlapsDto!.valorHora!.toStringAsFixed(2)}\n'),
          // Endereço (apenas para abertura)
          if (!isClose && checkOverlapsDto!.endereco != null) ...[
            TextSpan(text: '• Endereço: '),
            TextSpan(
              text: checkOverlapsDto!.endereco!.title.isNotEmpty 
                  ? checkOverlapsDto!.endereco!.title 
                  : (checkOverlapsDto!.endereco!.street ?? 'Endereço não especificado'),
            ),
            const TextSpan(text: '\n'),
          ],
          // Raio (apenas para abertura)
          if (!isClose && checkOverlapsDto!.raioAtuacao != null)
            TextSpan(text: '• Raio de atuação: ${checkOverlapsDto!.raioAtuacao!.toStringAsFixed(0)} km\n'),
          // Dias da semana
          if (recurrence.weekdays != null && recurrence.weekdays!.isNotEmpty) ...[
            const TextSpan(text: '• Dias da semana: '),
            TextSpan(
              text: recurrence.weekdays!.map((day) {
                const weekdaysNames = {
                  'MO': 'Segunda',
                  'TU': 'Terça',
                  'WE': 'Quarta',
                  'TH': 'Quinta',
                  'FR': 'Sexta',
                  'SA': 'Sábado',
                  'SU': 'Domingo',
                };
                return weekdaysNames[day] ?? day;
              }).join(', '),
            ),
            const TextSpan(text: '\n'),
          ] else
            const TextSpan(text: '• Dias da semana: Todos os dias\n'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSSize.width(20)),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: DSSize.width(400),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ════════════════════════════════════════════════════════════
            // Cabeçalho fixo (título e mensagem)
            // ════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.all(DSSize.width(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(12),
                  _buildDetailedMessageWidget(theme, colorScheme),
                ],
              ),
            ),

            // ════════════════════════════════════════════════════════════
            // Área scrollable com seções
            // ════════════════════════════════════════════════════════════
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção de sobreposições (apenas para abertura)
                    if (!isClose && daysWithOverlap.isNotEmpty) ...[
                      _buildOverlapSection(context, theme, colorScheme),
                      DSSizedBoxSpacing.vertical(12),
                    ],

                    // Seção de dias com shows
                    if (daysWithBookedSlot.isNotEmpty) ...[
                      _buildBookedSlotSection(context, theme, colorScheme),
                      DSSizedBoxSpacing.vertical(12),
                    ],
                    
                    // Seção de dias que NÃO serão afetados (apenas para fechamento com shows)
                    if (isClose && daysWithBookedSlot.isNotEmpty && daysWithoutOverlap.isNotEmpty) ...[
                      _buildUnaffectedDaysSection(context, theme, colorScheme),
                      DSSizedBoxSpacing.vertical(12),
                    ],
                  ],
                ),
              ),
            ),

            // ════════════════════════════════════════════════════════════
            // Botões de ação
            // ════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.all(DSSize.width(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DialogButton.text(
                    text: cancelText,
                    onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                    foregroundColor: colorScheme.onSurface,
                  ),
                  DSSizedBoxSpacing.horizontal(4),
                  DialogButton.primary(
                    text: confirmText,
                    backgroundColor: colorScheme.onPrimaryContainer,
                    textColor: colorScheme.primaryContainer,
                    onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção de sobreposições
  Widget _buildOverlapSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os horários abaixo serão sobrepostos:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        DSSizedBoxSpacing.vertical(4),
        ...daysWithOverlap.map((overlap) => _buildOverlapItem(
              context,
              theme,
              colorScheme,
              overlap,
            )),
      ],
    );
  }

  /// Constrói item de sobreposição
  Widget _buildOverlapItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DayOverlapInfo overlap,
  ) {
    return _ExpandableOverlapItem(
      overlap: overlap,
      theme: theme,
      colorScheme: colorScheme,
      formatDate: _formatDate,
      formatTime: _formatTime,
      checkOverlapsDto: checkOverlapsDto,
    );
  }

  /// Constrói seção de dias não afetados (para fechamento com shows)
  Widget _buildUnaffectedDaysSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os dias abaixo serão fechados normalmente:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        DSSizedBoxSpacing.vertical(4),
        ...daysWithoutOverlap.map((day) => Container(
              margin: EdgeInsets.only(bottom: DSSize.height(8)),
              padding: EdgeInsets.all(DSSize.width(12)),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(DSSize.width(8)),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: DSSize.width(20),
                    color: colorScheme.primary,
                  ),
                  DSSizedBoxSpacing.horizontal(4),
                  Expanded(
                    child: Text(
                      _formatDate(day.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Constrói seção de dias com shows
  Widget _buildBookedSlotSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os dias abaixo não serão considerados por estarem sobrepondo shows marcados.',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        DSSizedBoxSpacing.vertical(4),
        ...daysWithBookedSlot.map((day) => _buildBookedSlotItem(
              context,
              theme,
              colorScheme,
              day,
            )),
      ],
    );
  }

  /// Constrói item de dia com show
  Widget _buildBookedSlotItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AvailabilityDayEntity day,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: DSSize.height(8)),
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_busy,
            size: DSSize.width(20),
            color: colorScheme.error,
          ),
          DSSizedBoxSpacing.horizontal(4),
          Expanded(
            child: Text(
              _formatDate(day.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget expansível para item de sobreposição
class _ExpandableOverlapItem extends StatefulWidget {
  final DayOverlapInfo overlap;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(DateTime) formatDate;
  final String Function(String) formatTime;
  final CheckOverlapsDto? checkOverlapsDto;

  const _ExpandableOverlapItem({
    required this.overlap,
    required this.theme,
    required this.colorScheme,
    required this.formatDate,
    required this.formatTime,
    this.checkOverlapsDto,
  });

  @override
  State<_ExpandableOverlapItem> createState() => _ExpandableOverlapItemState();
}

class _ExpandableOverlapItemState extends State<_ExpandableOverlapItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasOldSlots = widget.overlap.oldTimeSlots != null &&
        widget.overlap.oldTimeSlots!.isNotEmpty;
    final hasNewSlots = widget.overlap.newTimeSlots != null &&
        widget.overlap.newTimeSlots!.isNotEmpty;
    final hasAnySlots = hasOldSlots || hasNewSlots;

    return Container(
      margin: EdgeInsets.only(bottom: DSSize.height(8)),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(
          color: widget.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header clicável
          InkWell(
            onTap: hasAnySlots ? _toggleExpanded : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DSSize.width(8)),
              topRight: Radius.circular(DSSize.width(8)),
            ),
            child: Padding(
              padding: EdgeInsets.all(DSSize.width(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.formatDate(widget.overlap.date),
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: widget.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasAnySlots) ...[
                    SizedBox(width: DSSize.width(8)),
                    Text(
                      _isExpanded ? 'Ocultar' : 'Ver horários',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: widget.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: DSSize.width(4)),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: DSSize.width(20),
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Conteúdo expansível
          if (hasAnySlots)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  DSSize.width(12),
                  0,
                  DSSize.width(12),
                  DSSize.height(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informações de endereço e raio (se houver mudança)
                    if (widget.overlap.isAddressDifferent || widget.overlap.isRadiusDifferent) ...[
                      if (widget.overlap.isAddressDifferent) ...[
                        Text(
                          'Endereço:',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: DSSize.width(8),
                            top: DSSize.height(2),
                          ),
                          child: Text(
                            'Antigo: ${widget.overlap.oldAddress?.title.isNotEmpty == true ? widget.overlap.oldAddress!.title : (widget.overlap.oldAddress?.street ?? "Não especificado")}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: DSSize.width(8),
                            top: DSSize.height(2),
                          ),
                          child: Text(
                            'Novo: ${widget.overlap.newAddress?.title.isNotEmpty == true ? widget.overlap.newAddress!.title : (widget.overlap.newAddress?.street ?? "Não especificado")}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(4),
                      ],
                      if (widget.overlap.isRadiusDifferent) ...[
                        Text(
                          'Raio de atuação:',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: DSSize.width(8),
                            top: DSSize.height(2),
                          ),
                          child: Text(
                            'Antigo: ${widget.overlap.oldRadius?.toStringAsFixed(0) ?? "N/A"} km',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: DSSize.width(8),
                            top: DSSize.height(2),
                          ),
                          child: Text(
                            'Novo: ${widget.overlap.newRadius?.toStringAsFixed(0) ?? "N/A"} km',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(4),
                      ],
                    ],
                    
                    if (hasOldSlots) ...[
                      Text(
                        'Horários existentes:',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      ...widget.overlap.oldTimeSlots!.map((slot) => Padding(
                            padding: EdgeInsets.only(
                              left: DSSize.width(8),
                              top: DSSize.height(4),
                            ),
                            child: Text(
                              '${widget.formatTime(slot.startTime)} - ${widget.formatTime(slot.endTime)} (R\$ ${slot.valorHora?.toStringAsFixed(2) ?? '0.00'})',
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: widget.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )),
                    ],
                    if (hasOldSlots && hasNewSlots)
                      DSSizedBoxSpacing.vertical(4),
                    if (hasNewSlots) ...[
                      Text(
                        'Novos horários:',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ...widget.overlap.newTimeSlots!.map((slot) => Padding(
                            padding: EdgeInsets.only(
                              left: DSSize.width(8),
                              top: DSSize.height(4),
                            ),
                            child: Text(
                              '${widget.formatTime(slot.startTime)} - ${widget.formatTime(slot.endTime)} (R\$ ${slot.valorHora?.toStringAsFixed(2) ?? '0.00'})',
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: widget.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
