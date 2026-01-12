import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:flutter/material.dart';

class ContractStatusBadge extends StatelessWidget {
  final ContractStatusEnum status;
  final bool isArtist;

  const ContractStatusBadge({
    super.key,
    required this.status,
    required this.isArtist,
  });

  Color _getStatusColor(ContractStatusEnum status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (status) {
      case ContractStatusEnum.pending:
        return Colors.orange;
      case ContractStatusEnum.rejected:
        return Colors.red;
      case ContractStatusEnum.paymentPending:
        return Colors.orange;
      case ContractStatusEnum.paymentExpired:
        return colorScheme.onError;
      case ContractStatusEnum.paymentRefused:
        return colorScheme.error;
      case ContractStatusEnum.paymentFailed:
        return colorScheme.error;
      case ContractStatusEnum.paid:
        return Colors.green;
      case ContractStatusEnum.completed:
        return Colors.blue;
      case ContractStatusEnum.rated:
        return Colors.blue;
      case ContractStatusEnum.canceled:
        return Colors.red;
    }
  }

  String _getStatusLabel(ContractStatusEnum status, bool isArtist) {
    switch (status) {
      case ContractStatusEnum.pending:
        return 'Solicitada';
      case ContractStatusEnum.rejected:
        return 'Recusada';
      case ContractStatusEnum.paymentPending:
        return 'Aguardando Pagamento do Anfitrião';
      case ContractStatusEnum.paymentExpired:
        return isArtist ? 'Aguardando Pagamento do Anfitrião' : 'Pagamento Expirado';
      case ContractStatusEnum.paymentRefused:
        return isArtist ? 'Aguardando Pagamento do Anfitrião' : 'Pagamento Recusado';
      case ContractStatusEnum.paymentFailed:
        return isArtist ? 'Aguardando Pagamento do Anfitrião' : 'Pagamento Falhou';
      case ContractStatusEnum.paid:
        return 'Pago';
      case ContractStatusEnum.completed:
        return 'Realizado';
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
            _getStatusLabel(status, isArtist),
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

