import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget for selecting the search date.
///
/// Displays the selected date and allows changing it on tap.
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hoje';
    } else if (selectedDay == tomorrow) {
      return 'Amanhã';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return GestureDetector(
      onTap: onDateTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DSSize.width(12),
          vertical: DSSize.height(8),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.05),
          border: Border.all(
            color: onPrimary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(DSSize.width(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _formatDate(selectedDate),
                style: textTheme.bodySmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DSSizedBoxSpacing.horizontal(4),
            Icon(
              Icons.calendar_today,
              color: onPrimary,
              size: DSSize.width(16),
            ),
          ],
        ),
      ),
    );
  }
}
