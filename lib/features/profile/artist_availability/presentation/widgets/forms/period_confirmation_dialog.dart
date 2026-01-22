import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/dialog_button.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/close_period_dto.dart';

/// Dialog de confirmação para abertura/fechamento de período de disponibilidade
/// 
/// Exibe um resumo das informações do período e solicita confirmação do usuário
class PeriodConfirmationDialog extends StatelessWidget {
  final bool isOpening; // true = abrir, false = fechar
  final OpenPeriodDto? openDto;
  final ClosePeriodDto? closeDto;

  const PeriodConfirmationDialog({
    super.key,
    required this.isOpening,
    this.openDto,
    this.closeDto,
  }) : assert(
          (isOpening && openDto != null) || (!isOpening && closeDto != null),
          'DTO deve ser fornecido conforme o tipo de operação',
        );

  /// Exibe o dialog de confirmação para abrir período
  static Future<bool?> showOpenPeriod({
    required BuildContext context,
    required OpenPeriodDto dto,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PeriodConfirmationDialog(
        isOpening: true,
        openDto: dto,
      ),
    );
  }

  /// Exibe o dialog de confirmação para fechar período
  static Future<bool?> showClosePeriod({
    required BuildContext context,
    required ClosePeriodDto dto,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PeriodConfirmationDialog(
        isOpening: false,
        closeDto: dto,
      ),
    );
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  /// Formata horário para exibição
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Formata dias da semana para exibição
  String _formatWeekdays(List<String>? weekdays) {
    if (weekdays == null || weekdays.isEmpty) {
      return 'Todos os dias';
    }

    final weekdayNames = {
      'MO': 'Segunda',
      'TU': 'Terça',
      'WE': 'Quarta',
      'TH': 'Quinta',
      'FR': 'Sexta',
      'SA': 'Sábado',
      'SU': 'Domingo',
    };

    return weekdays.map((code) => weekdayNames[code] ?? code).join(', ');
  }

  /// Verifica se é "todos os horários" (00:00 - 23:59)
  bool _isAllHours(TimeOfDay start, TimeOfDay end) {
    return start.hour == 0 &&
        start.minute == 0 &&
        end.hour == 23 &&
        end.minute == 59;
  }

  /// Formata endereço completo para exibição
  String _formatAddress(OpenPeriodDto openDto) {
    final address = openDto.endereco;
    final parts = <String>[];
    
    // Rua e número
    if (address.street != null && address.street!.isNotEmpty) {
      final streetPart = address.street!;
      final numberPart = address.number != null ? ', ${address.number}' : '';
      parts.add('$streetPart$numberPart');
    }
    
    // Bairro, cidade e estado
    if (address.district != null && 
        address.district!.isNotEmpty && 
        address.city != null && 
        address.state != null) {
      parts.add('${address.district!}, ${address.city} - ${address.state}');
    }
    
    // CEP
    if (address.zipCode.isNotEmpty) {
      parts.add('CEP: ${address.zipCode}');
    }
    
    return parts.isNotEmpty ? parts.join('\n') : 'Endereço não informado';
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
          maxWidth: DSSize.width(400),
          maxHeight: DSSize.height(600),
        ),
        child: Padding(
          padding: EdgeInsets.all(DSSize.width(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ════════════════════════════════════════════════════════════════
              // TÍTULO
              // ════════════════════════════════════════════════════════════════
              Text(
                isOpening
                    ? 'Confirmar abertura do período'
                    : 'Confirmar fechamento do período',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),

              DSSizedBoxSpacing.vertical(20),

              // ════════════════════════════════════════════════════════════════
              // CONTEÚDO - RESUMO DAS INFORMAÇÕES
              // ════════════════════════════════════════════════════════════════
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isOpening && openDto != null) ...[
                        // MODO ABRIR
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Período',
                          value:
                              '${_formatDate(openDto!.startDate)} até ${_formatDate(openDto!.endDate)}',
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.access_time,
                          label: 'Horário',
                          value: '${_formatTime(openDto!.startTime)} às ${_formatTime(openDto!.endTime)}',
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_view_week,
                          label: 'Dias da semana',
                          value: _formatWeekdays(openDto!.weekdays),
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.attach_money,
                          label: 'Valor por hora',
                          value: 'R\$ ${openDto!.pricePerHour.toStringAsFixed(2).replaceAll('.', ',')}',
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.location_on,
                          label: 'Endereço',
                          value: _formatAddress(openDto!),
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.radio_button_checked,
                          label: 'Raio de atuação',
                          value: '${openDto!.raioAtuacao.toStringAsFixed(1)} km',
                        ),
                      ] else if (!isOpening && closeDto != null) ...[
                        // MODO FECHAR
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Período',
                          value:
                              '${_formatDate(closeDto!.startDate)} até ${_formatDate(closeDto!.endDate)}',
                        ),
                        DSSizedBoxSpacing.vertical(12),
                        _buildInfoRow(
                          context,
                          icon: Icons.access_time,
                          label: 'Horário',
                          value: _isAllHours(closeDto!.startTime, closeDto!.endTime)
                              ? 'Todos os horários'
                              : '${_formatTime(closeDto!.startTime)} às ${_formatTime(closeDto!.endTime)}',
                        ),
                        if (closeDto!.blockReason.isNotEmpty) ...[
                          DSSizedBoxSpacing.vertical(12),
                          _buildInfoRow(
                            context,
                            icon: Icons.info_outline,
                            label: 'Motivo',
                            value: closeDto!.blockReason,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              DSSizedBoxSpacing.vertical(24),

              // ════════════════════════════════════════════════════════════════
              // BOTÕES DE AÇÃO
              // ════════════════════════════════════════════════════════════════
              Row(
                children: [
                  // Botão Cancelar
                  Expanded(
                    child: DialogButton.text(
                      text: 'Cancelar',
                      foregroundColor: colorScheme.error,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),

                  DSSizedBoxSpacing.horizontal(12),

                  // Botão Confirmar
                  Expanded(
                    child: DialogButton.primary(
                      text: 'Confirmar',
                      backgroundColor: colorScheme.onPrimaryContainer,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói uma linha de informação com ícone, label e valor
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícone
        Icon(
          icon,
          size: DSSize.width(20),
          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),

        DSSizedBoxSpacing.horizontal(12),

        // Label e Valor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              DSSizedBoxSpacing.vertical(4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
