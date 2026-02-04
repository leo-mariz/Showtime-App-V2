import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodFilterSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const PeriodFilterSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Selecione';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: endDate ?? DateTime.now(),
    );

    if (picked != null) {
      // Validar que a data inicial não seja posterior à data final
      if (endDate != null && picked.isAfter(endDate!)) {
        context.showError('A data inicial não pode ser posterior à data final');
        return;
      }

      // Validar que o período não exceda 3 meses
      if (endDate != null) {
        final difference = endDate!.difference(picked);
        if (difference.inDays > 90) {
          context.showError('O período não pode exceder 3 meses');
          return;
        }
      }

      onStartDateChanged(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Validar que a data final não seja anterior à data inicial
      if (startDate != null && picked.isBefore(startDate!)) {
        context.showError('A data final não pode ser anterior à data inicial');
        return;
      }

      // Validar que o período não exceda 3 meses
      if (startDate != null) {
        final difference = picked.difference(startDate!);
        if (difference.inDays > 90) {
          context.showError('O período não pode exceder 3 meses');
          return;
        }
      }

      onEndDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar por Período',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.date_range,
                size: DSSize.width(20),
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  context,
                  label: 'Data Início',
                  date: startDate,
                  onTap: () => _selectStartDate(context),
                ),
              ),
              DSSizedBoxSpacing.horizontal(12),
              Expanded(
                child: _buildDateField(
                  context,
                  label: 'Data Fim',
                  date: endDate,
                  onTap: () => _selectEndDate(context),
                ),
              ),
            ],
          ),
          DSSizedBoxSpacing.vertical(8),
          Text(
            'Período máximo: 3 meses',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DSSize.width(12)),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.05),
          border: Border.all(
            color: colorScheme.onSurfaceVariant.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(DSSize.width(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            DSSizedBoxSpacing.vertical(4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: DSSize.width(16),
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

