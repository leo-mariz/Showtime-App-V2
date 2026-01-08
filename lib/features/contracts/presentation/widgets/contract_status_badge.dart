import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:flutter/material.dart';

class ContractStatusBadge extends StatelessWidget {
  final ContractStatusEnum status;

  const ContractStatusBadge({
    super.key,
    required this.status,
  });

  Color _getStatusColor(ContractStatusEnum status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (status) {
      case ContractStatusEnum.pending:
        return Colors.orange;
      case ContractStatusEnum.accepted:
        return Colors.green;
      case ContractStatusEnum.rejected:
        return Colors.red;
      case ContractStatusEnum.paymentPending:
        return Colors.orange;
      case ContractStatusEnum.paymentExpired:
        return Colors.red;
      case ContractStatusEnum.paymentRefused:
        return Colors.red;
      case ContractStatusEnum.paymentFailed:
        return Colors.red;
      case ContractStatusEnum.paid:
        return Colors.green;
      case ContractStatusEnum.confirmed:
        return Colors.blue;
      case ContractStatusEnum.completed:
        return colorScheme.primary;
      case ContractStatusEnum.rated:
        return Colors.purple;
      case ContractStatusEnum.canceled:
        return Colors.red;
    }
  }

  String _getStatusLabel(ContractStatusEnum status) {
    switch (status) {
      case ContractStatusEnum.pending:
        return 'Solicitada';
      case ContractStatusEnum.accepted:
        return 'Aceita';
      case ContractStatusEnum.rejected:
        return 'Recusada';
      case ContractStatusEnum.paymentPending:
        return 'Aguardando Pagamento';
      case ContractStatusEnum.paymentExpired:
        return 'Pagamento Expirado';
      case ContractStatusEnum.paymentRefused:
        return 'Pagamento Recusado';
      case ContractStatusEnum.paymentFailed:
        return 'Pagamento Falhou';
      case ContractStatusEnum.paid:
        return 'Pago';
      case ContractStatusEnum.confirmed:
        return 'Confirmado';
      case ContractStatusEnum.completed:
        return 'Finalizado';
      case ContractStatusEnum.rated:
        return 'Avaliado';
      case ContractStatusEnum.canceled:
        return 'Cancelado';
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

