import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/event/event_entity.dart';
import 'package:app/core/enums/event_status_enum.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class ClientEventDetailScreen extends StatelessWidget {
  final EventEntity event;

  const ClientEventDetailScreen({
    super.key,
    required this.event,
  });

  String _formatDuration(int durationInMinutes) {
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não informada';
    return DateFormat("EEEE, dd 'de' MMMM 'de' yyyy", 'pt_BR').format(date);
  }

  String _formatTime(String time) {
    return time;
  }

  EventStatusEnum get _status {
    final statusUpper = event.status.toUpperCase();
    return EventStatusEnum.values.firstWhere(
      (e) => e.name == statusUpper,
      orElse: () => EventStatusEnum.pending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;
    final primaryContainer = colorScheme.primaryContainer;

    return BasePage(
      showAppBar: true,
      showAppBarBackButton: true,
      appBarTitle: 'Detalhes do Evento',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                ContractStatusBadge(status: _status),
              ],
            ),

            DSSizedBoxSpacing.vertical(24),

            // Tipo de Evento
            Text(
              event.eventType?.name ?? 'Evento',
              style: textTheme.headlineSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            DSSizedBoxSpacing.vertical(24),

            // Informações do Artista
            _buildSectionTitle('Solicitado para', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildArtistInfo(context, colorScheme, textTheme, onPrimary),

            DSSizedBoxSpacing.vertical(24),

            // Data e Hora
            _buildSectionTitle('Data e Hora', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Data',
              value: _formatDate(event.date),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Horário de Início',
              value: _formatTime(event.time),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.timer_rounded,
              label: 'Duração',
              value: _formatDuration(event.duration),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),

            DSSizedBoxSpacing.vertical(24),

            // Localização
            _buildSectionTitle('Localização', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              label: 'Endereço',
              value: event.address?.title ?? 'Endereço não informado',
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            if (event.address != null) ...[
              DSSizedBoxSpacing.vertical(8),
              Padding(
                padding: EdgeInsets.only(left: DSSize.width(40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.address!.street != null && event.address!.street!.isNotEmpty)
                      Text(
                        '${event.address!.street}${event.address!.number != null ? ", ${event.address!.number}" : ""}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                    if (event.address!.district != null && event.address!.district!.isNotEmpty)
                      Text(
                        event.address!.district!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                    if (event.address!.city != null && event.address!.state != null)
                      Text(
                        '${event.address!.city} - ${event.address!.state}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                    if (event.address!.zipCode.isNotEmpty)
                      Text(
                        'CEP: ${event.address!.zipCode}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            DSSizedBoxSpacing.vertical(24),

            // Informações Financeiras
            _buildSectionTitle('Informações Financeiras', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            Container(
              padding: EdgeInsets.all(DSSize.width(16)),
              decoration: BoxDecoration(
                color: primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(DSSize.width(12)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.attach_money_rounded,
                    label: 'Valor Total',
                    value: _formatCurrency(event.value),
                    textTheme: textTheme,
                    onSurfaceVariant: onSurfaceVariant,
                    onPrimary: onPrimary,
                    isHighlighted: true,
                  ),
                  if (event.statusPayment.isNotEmpty) ...[
                    DSSizedBoxSpacing.vertical(12),
                    _buildInfoRow(
                      icon: Icons.payment_rounded,
                      label: 'Status do Pagamento',
                      value: _getPaymentStatusLabel(event.statusPayment),
                      textTheme: textTheme,
                      onSurfaceVariant: onSurfaceVariant,
                      onPrimary: onPrimary,
                    ),
                  ],
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(32),

            // Botões de Ação
            if (_status != EventStatusEnum.finished && _status != EventStatusEnum.rejected) ...[
              CustomButton(
                label: 'Cancelar Solicitação',
                onPressed: () => _handleCancelRequest(context),
                filled: true,
                backgroundColor: colorScheme.error,
                textColor: colorScheme.onError,
                height: DSSize.height(48),
              ),
              DSSizedBoxSpacing.vertical(16),
            ],

            if (_status == EventStatusEnum.accepted && event.statusPayment.toUpperCase() == 'PENDING') ...[
              CustomButton(
                label: 'Realizar Pagamento',
                onPressed: () => _handlePayment(context),
                icon: Icons.payment_rounded,
                iconOnRight: true,
                height: DSSize.height(48),
              ),
              DSSizedBoxSpacing.vertical(16),
            ],

            DSSizedBoxSpacing.vertical(16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, Color onPrimary) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        color: onPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildArtistInfo(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color onPrimary,
  ) {
    return Container(
      padding: EdgeInsets.all(DSSize.width(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DSSize.width(12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: DSSize.width(24),
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Text(
              (event.nameArtist ?? 'A')[0].toUpperCase(),
              style: textTheme.titleMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DSSizedBoxSpacing.horizontal(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.nameArtist ?? 'Artista',
                  style: textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                Text(
                  'Artista',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required TextTheme textTheme,
    required Color onSurfaceVariant,
    required Color onPrimary,
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: DSSize.width(20),
          color: isHighlighted ? onPrimary : onSurfaceVariant,
        ),
        DSSizedBoxSpacing.horizontal(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
              DSSizedBoxSpacing.vertical(4),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: isHighlighted ? onPrimary : onPrimary,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPaymentStatusLabel(String status) {
    final statusUpper = status.toUpperCase();
    switch (statusUpper) {
      case 'PENDING':
        return 'Pendente';
      case 'PAID':
        return 'Pago';
      case 'CANCELLED':
        return 'Cancelado';
      case 'REFUNDED':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  void _handleCancelRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Solicitação',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja cancelar esta solicitação? Esta ação não pode ser desfeita.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar lógica de cancelamento
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solicitação cancelada com sucesso'),
                ),
              );
            },
            child: Text(
              'Sim, cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    // TODO: Implementar lógica de pagamento
    if (event.linkPayment.isNotEmpty) {
      // Abrir link de pagamento
      debugPrint('Abrir link de pagamento: ${event.linkPayment}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link de pagamento não disponível'),
        ),
      );
    }
  }
}

