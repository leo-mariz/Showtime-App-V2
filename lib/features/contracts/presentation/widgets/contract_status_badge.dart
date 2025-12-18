import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/enums/event_status_enum.dart';
import 'package:flutter/material.dart';

class ContractStatusBadge extends StatelessWidget {
  final EventStatusEnum status;

  const ContractStatusBadge({
    super.key,
    required this.status,
  });

  Color _getStatusColor(EventStatusEnum status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (status) {
      case EventStatusEnum.pending:
        return Colors.orange;
      case EventStatusEnum.accepted:
        return Colors.green;
      case EventStatusEnum.rejected:
        return Colors.red;
      case EventStatusEnum.finished:
        return colorScheme.primary;
      case EventStatusEnum.canceled:
        return Colors.red;
      case EventStatusEnum.paid:
        return Colors.green;
      case EventStatusEnum.pendingPayment:
        return Colors.orange;
    }
  }

  String _getStatusLabel(EventStatusEnum status) {
    switch (status) {
      case EventStatusEnum.pending:
        return 'Solicitada';
      case EventStatusEnum.accepted:
        return 'Aceita';
      case EventStatusEnum.rejected:
        return 'Recusada';
      case EventStatusEnum.finished:
        return 'Finalizada';
      case EventStatusEnum.canceled:
        return 'Cancelada';
      case EventStatusEnum.paid:
        return 'Pago';
      case EventStatusEnum.pendingPayment:
        return 'Pendente de Pagamento';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _getStatusColor(status, context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(12),
        vertical: DSSize.height(6),
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: DSSize.width(8),
            height: DSSize.width(8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: DSSize.width(6)),
          Text(
            _getStatusLabel(status),
            style: textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: DSSize.width(12),
            ),
          ),
        ],
      ),
    );
  }
}

