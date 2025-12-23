import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

class LoginHistoryEntry {
  final String device;
  final String location;
  final DateTime dateTime;
  final String status; // Ex: "Sucesso", "Falha", "Desconhecido"
  final bool isCurrentSession;

  LoginHistoryEntry({
    required this.device,
    required this.location,
    required this.dateTime,
    required this.status,
    this.isCurrentSession = false,
  });
}

@RoutePage(deferredLoading: true)
class LoginHistoryPage extends StatelessWidget {
  const LoginHistoryPage({super.key});

  // Simulação de dados
  List<LoginHistoryEntry> get _mockHistory => [
        LoginHistoryEntry(
          device: "iPhone 14 Pro",
          location: "São Paulo, Brasil",
          dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
          status: "Sucesso",
          isCurrentSession: true,
        ),
        LoginHistoryEntry(
          device: "Chrome no Windows",
          location: "Rio de Janeiro, Brasil",
          dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          status: "Sucesso",
        ),
        LoginHistoryEntry(
          device: "Safari no Mac",
          location: "Lisboa, Portugal",
          dateTime: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          status: "Falha",
        ),
        LoginHistoryEntry(
          device: "Android",
          location: "Desconhecido",
          dateTime: DateTime.now().subtract(const Duration(days: 7)),
          status: "Sucesso",
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Histórico de Login',
      showAppBarBackButton: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = _mockHistory[index];
          return Card(
            color: entry.isCurrentSession
                ? colorScheme.primary.withOpacity(0.08)
                : colorScheme.surfaceContainerHighest,
            elevation: entry.isCurrentSession ? 2 : 0,
            child: ListTile(
              leading: Icon(
                entry.status == "Sucesso"
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: entry.status == "Sucesso"
                    ? colorScheme.primary
                    : colorScheme.error,
              ),
              title: Row(
                children: [
                  Text(
                    entry.device,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: entry.isCurrentSession
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                  if (entry.isCurrentSession)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sessão atual',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorScheme.primary),
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.location,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Data: ${_formatDate(entry.dateTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Status: ${entry.status}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: entry.status == "Sucesso"
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                  ),
                ],
              ),
              trailing: entry.isCurrentSession
                  ? Icon(Icons.lock, color: colorScheme.primary)
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    // Exemplo: 12/04/2024 14:32
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }
}