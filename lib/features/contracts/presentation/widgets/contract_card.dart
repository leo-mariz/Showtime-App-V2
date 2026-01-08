import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractCard extends StatelessWidget {
  final ContractEntity contract;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final bool isArtist;
  
  // Callbacks para ações específicas
  final VoidCallback? onAccept; // Artista: aceitar solicitação
  final VoidCallback? onReject; // Artista: recusar solicitação
  final VoidCallback? onMakePayment; // Cliente: realizar pagamento
  final VoidCallback? onGeneratePayment; // Cliente: gerar pagamento
  final VoidCallback? onRetryPayment; // Cliente: tentar novamente pagamento

  const ContractCard({
    super.key,
    required this.contract,
    required this.onTap,
    this.onCancel,
    this.onViewDetails,
    this.isArtist = false,
    this.onAccept,
    this.onReject,
    this.onMakePayment,
    this.onGeneratePayment,
    this.onRetryPayment,
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

  ContractStatusEnum get _status => contract.status;

  // Retorna os botões a serem exibidos baseado no status e tipo de usuário
  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    if (isArtist) {
      // Lógica para Artista
      if (_status == ContractStatusEnum.pending) {
        // PENDING → Aceitar e Recusar
        buttons.addAll([
          Expanded(
            child: CustomButton(
              label: 'Recusar',
              onPressed: onReject,
              icon: Icons.close_rounded,
              iconOnLeft: true,
              buttonType: CustomButtonType.cancel,
              height: DSSize.height(40),
            ),
          ),
          DSSizedBoxSpacing.horizontal(12),
          Expanded(
            child: CustomButton(
              label: 'Aceitar',
              onPressed: onAccept,
              icon: Icons.check_rounded,
              iconOnLeft: true,
              height: DSSize.height(40),
            ),
          ),
        ]);
      }
      // Removido: botão de cancelar para outros status não finalizados
    } else {
      // Lógica para Cliente
      if (_status == ContractStatusEnum.accepted) {
        // Accepted → Realizar Pagamento
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Realizar Pagamento',
              onPressed: onMakePayment,
              icon: Icons.payment_rounded,
              iconOnLeft: true,
              height: DSSize.height(40),
            ),
          ),
        );
      } else if (_status == ContractStatusEnum.paymentExpired) {
        // paymentExpired → Gerar Pagamento
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Gerar Pagamento',
              onPressed: onGeneratePayment,
              icon: Icons.refresh_rounded,
              iconOnLeft: true,
              height: DSSize.height(40),
            ),
          ),
        );
      } else if (_status == ContractStatusEnum.paymentRefused ||
          _status == ContractStatusEnum.paymentFailed) {
        // paymentRefused ou paymentFailed → Tentar Novamente
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Tentar Novamente',
              onPressed: onRetryPayment,
              icon: Icons.refresh_rounded,
              iconOnLeft: true,
              height: DSSize.height(40),
            ),
          ),
        );
      }
      // Removido: botão de cancelar para outros status
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;

    final date = contract.date;
    final dateFormatted = DateFormat('dd/MM/yyyy').format(date);
    final timeFormatted = contract.time;

    return CustomCard(
      margin: EdgeInsets.only(bottom: DSSize.height(16)),
      onTap: onTap,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status e Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContractStatusBadge(status: _status),
                  Text(
                    dateFormatted,
                    style: textTheme.bodyLarge?.copyWith(
                      color: onPrimaryContainer,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(8),
              
              // Tipo de Evento
              Text(
                contract.eventType?.name ?? 'Evento',
                style: textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  // fontWeight: FontWeight.w600,
                ),
              ),
              
              DSSizedBoxSpacing.vertical(8),
              
              // Informações do Artista ou Anfitrião
              Row(
                children: [
                  CircleAvatar(
                    radius: DSSize.width(20),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Text(
                      (isArtist 
                        ? (contract.nameClient ?? 'A')
                        : (contract.contractorName ?? 'A'))[0].toUpperCase(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPrimary,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArtist 
                            ? (contract.nameClient ?? 'Anfitrião')
                            : (contract.contractorName ?? 'Artista'),
                          style: textTheme.bodyLarge?.copyWith(
                            color: onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isArtist ? 'Anfitrião' : 'Artista',
                          style: textTheme.bodySmall?.copyWith(
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(8),
              
                  // Informações do Evento
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: DSSize.width(16),
                        color: onPrimary,
                      ),
                      DSSizedBoxSpacing.horizontal(6),
                      Text(
                        '$timeFormatted • ${_formatDuration(contract.duration)}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              
              
              DSSizedBoxSpacing.vertical(16),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: DSSize.width(16),
                    color: onPrimary,
                  ),
                  DSSizedBoxSpacing.horizontal(6),
                  Expanded(
                    child: Text(
                      contract.address.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(12),
              
              // Valor Total
              Container(
                padding: EdgeInsets.all(DSSize.width(12)),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DSSize.width(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valor Total',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPrimary,
                      ),
                    ),
                    Text(
                      _formatCurrency(contract.value),
                      style: textTheme.titleMedium?.copyWith(
                        color: onPrimaryContainer,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ações baseadas no status e tipo de usuário
              if (_buildActionButtons(context).isNotEmpty) ...[
                DSSizedBoxSpacing.vertical(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildActionButtons(context),
                ),
              ],
            ],
          ),
    );
  }
}

