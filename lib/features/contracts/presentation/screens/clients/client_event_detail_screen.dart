import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/widgets/cancel_contract_dialog.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class ClientEventDetailScreen extends StatelessWidget {
  final ContractEntity contract;

  const ClientEventDetailScreen({
    super.key,
    required this.contract,
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

  ContractStatusEnum get _status => contract.status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;
    final primaryContainer = colorScheme.primaryContainer;

    return BlocListener<ContractsBloc, ContractsState>(
      listener: (context, state) {
        if (state is MakePaymentFailure) {
          context.showError(state.error);
        } else if (state is CancelContractSuccess) {
          context.showSuccess('Contrato cancelado com sucesso!');
          // Voltar para a tela anterior e sinalizar que precisa recarregar
          context.router.pop(true);
        } else if (state is CancelContractFailure) {
          context.showError(state.error);
        }
      },
      child: BasePage(
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
              contract.eventType?.name ?? 'Evento',
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
              value: _formatDate(contract.date),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Horário de Início',
              value: _formatTime(contract.time),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.timer_rounded,
              label: 'Duração',
              value: _formatDuration(contract.duration),
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
              value: '${contract.address.district}, ${contract.address.city} - ${contract.address.state}',
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(4),
            Padding(
              padding: EdgeInsets.only(left: DSSize.width(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contract.address.street != null && contract.address.street!.isNotEmpty)
                    Text(
                      '${contract.address.street}${contract.address.number != null ? ", ${contract.address.number}" : ""}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  if (contract.address.zipCode.isNotEmpty)
                    Text(
                      'CEP: ${contract.address.zipCode}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

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
                    value: _formatCurrency(contract.value),
                    textTheme: textTheme,
                    onSurfaceVariant: onSurfaceVariant,
                    onPrimary: onPrimary,
                    isHighlighted: true,
                  ),
                  DSSizedBoxSpacing.vertical(12),
                  _buildInfoRow(
                    icon: Icons.payment_rounded,
                    label: 'Status do Pagamento',
                    value: _getPaymentStatusLabel(contract.status),
                    textTheme: textTheme,
                    onSurfaceVariant: onSurfaceVariant,
                    onPrimary: onPrimary,
                  ),
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(32),

            // Botões de Ação
            if (_status == ContractStatusEnum.paymentPending) ...[
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Realizar Pagamento',
                  onPressed: () => _handlePayment(context),
                  icon: Icons.payment_rounded,
                  iconOnRight: true,
                  height: DSSize.height(48),
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            if (_status != ContractStatusEnum.completed && 
                _status != ContractStatusEnum.rejected &&
                _status != ContractStatusEnum.canceled) ...[
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<ContractsBloc, ContractsState>(
                  builder: (context, state) {
                    final isCanceling = state is CancelContractLoading;
                    return CustomButton(
                      label: 'Cancelar Evento',
                      onPressed: isCanceling ? null : () => _handleCancelRequest(context),
                      filled: true,
                      backgroundColor: colorScheme.error,
                      textColor: colorScheme.onError,
                      height: DSSize.height(48),
                      isLoading: isCanceling,
                    );
                  },
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
            ],

            DSSizedBoxSpacing.vertical(16),
          ],
        ),
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
              (contract.contractorName ?? 'A')[0].toUpperCase(),
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
                  contract.contractorName ?? 'Artista',
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

  String _getPaymentStatusLabel(ContractStatusEnum status) {
    return status.name;
  }

  void _handleCancelRequest(BuildContext context) async {
    final confirmed = await CancelContractDialog.show(
      context: context,
      isLoading: false,
    );

    if (confirmed == true && contract.uid != null && contract.uid!.isNotEmpty) {
      context.read<ContractsBloc>().add(
        CancelContractEvent(
          contractUid: contract.uid!,
          canceledBy: 'CLIENT',
        ),
      );
    }
  }

  void _handlePayment(BuildContext context) {
    if (contract.linkPayment == null || contract.linkPayment!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link de pagamento não disponível. Entre em contato com o suporte.'),
        ),
      );
      return;
    }

    context.read<ContractsBloc>().add(
          MakePaymentEvent(linkPayment: contract.linkPayment!, contractUid: contract.uid!),
        );
  }
}

