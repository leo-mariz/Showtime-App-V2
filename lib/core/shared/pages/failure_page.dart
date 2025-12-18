import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';


class FailurePage extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const FailurePage({super.key, required this.onRetry, required this.message});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
