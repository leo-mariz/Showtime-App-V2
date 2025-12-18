import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ConnectionErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 12),
            Text(
              'Sem conexão com a internet',
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