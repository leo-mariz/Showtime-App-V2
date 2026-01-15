import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class EventTypeSelectionScreen extends StatelessWidget {
  final List<String> eventTypes;
  final String? selectedEventType;
  final ValueChanged<String> onEventTypeSelected;

  const EventTypeSelectionScreen({
    super.key,
    required this.eventTypes,
    this.selectedEventType,
    required this.onEventTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Ordenar lista alfabeticamente
    final sortedEventTypes = List<String>.from(eventTypes)..sort();

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Tipo de Evento',
      showAppBarBackButton: true,
      child: ListView.builder(
        itemCount: sortedEventTypes.length,
        itemBuilder: (context, index) {
          final eventType = sortedEventTypes[index];
          final isSelected = eventType == selectedEventType;

          return Padding(
            padding: EdgeInsets.only(bottom: DSSize.height(0)),
            child: CustomCard(
              onTap: () {
                onEventTypeSelected(eventType);
                AutoRouter.of(context).pop(eventType);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      eventType,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.onPrimaryContainer,
                      size: DSSize.width(24),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

