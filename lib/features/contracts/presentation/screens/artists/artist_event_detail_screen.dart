import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/card_action_button.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/event_location_map.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class ArtistEventDetailScreen extends StatefulWidget {
  final ContractEntity contract;

  const ArtistEventDetailScreen({
    super.key,
    required this.contract,
  });

  @override
  State<ArtistEventDetailScreen> createState() => _ArtistEventDetailScreenState();
}

class _ArtistEventDetailScreenState extends State<ArtistEventDetailScreen> {
  ContractEntity get contract => widget.contract;

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
        if (state is AcceptContractSuccess) {
          context.showSuccess('Solicitação aceita com sucesso!');
          // Voltar para a tela anterior e sinalizar que precisa recarregar
          if (mounted) {
            context.router.pop(true);
          }
        } else if (state is AcceptContractFailure) {
          context.showError(state.error);
        } else if (state is RejectContractSuccess) {
          context.showSuccess('Solicitação rejeitada com sucesso!');
          // Voltar para a tela anterior e sinalizar que precisa recarregar
          if (mounted) {
            context.router.pop(true);
          }
        } else if (state is RejectContractFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<ContractsBloc, ContractsState>(
        builder: (context, state) {
          final isAccepting = state is AcceptContractLoading;
          final isRejecting = state is RejectContractLoading;
          final isAnyLoading = isAccepting || isRejecting;

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
                    contract.eventType?.name ?? 'Evento',
                    style: textTheme.headlineSmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  DSSizedBoxSpacing.vertical(24),

                  // Informações do Artista
                  _buildSectionTitle('Solicitante', textTheme, onPrimary),
                  DSSizedBoxSpacing.vertical(12),
                  _buildContractorInfo(context, colorScheme, textTheme, onPrimary),

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
                  
                  // Informações do endereço (sem título)
                  // Mostrar endereço completo apenas quando evento estiver confirmado
                  // Caso contrário, mostrar apenas bairro e cidade
                  Builder(
                    builder: (context) {
                      final isConfirmed = _status == ContractStatusEnum.confirmed ||
                          _status == ContractStatusEnum.completed;
                      
                      return Padding(
                        padding: EdgeInsets.only(left: DSSize.width(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isConfirmed)
                              // Endereço completo (quando confirmado)
                              ...[
                                if (contract.address.street != null && contract.address.street!.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: DSSize.width(18),
                                        color: onSurfaceVariant,
                                      ),
                                      DSSizedBoxSpacing.horizontal(16),
                                      if (contract.address.district != null && contract.address.district!.isNotEmpty)
                                        Text(
                                          '${contract.address.district!},',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: onPrimary,
                                          ),
                                        ),
                                      if (contract.address.district != null && contract.address.district!.isNotEmpty)
                                        DSSizedBoxSpacing.horizontal(16),
                                      Text(
                                        '${contract.address.street}${contract.address.number != null ? ", ${contract.address.number}" : ""}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                DSSizedBoxSpacing.vertical(4),
                                Row(
                                  children: [
                                    DSSizedBoxSpacing.horizontal(32),
                                    if (contract.address.city != null && contract.address.state != null)
                                      Text(
                                        '${contract.address.city} - ${contract.address.state}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    DSSizedBoxSpacing.horizontal(16),
                                    if (contract.address.zipCode.isNotEmpty)
                                      Text(
                                        'CEP: ${contract.address.zipCode}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ]
                            else
                              // Apenas bairro e cidade (quando não confirmado)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: DSSize.width(18),
                                        color: onSurfaceVariant,
                                      ),
                                      DSSizedBoxSpacing.horizontal(16),
                                      if (contract.address.district != null && contract.address.district!.isNotEmpty)
                                        Text(
                                          contract.address.district!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: onPrimary,
                                          ),
                                        ),
                                      if (contract.address.district != null && contract.address.district!.isNotEmpty)
                                        DSSizedBoxSpacing.horizontal(8),
                                      if (contract.address.city != null && contract.address.state != null)
                                        Text(
                                          '${contract.address.city} - ${contract.address.state}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: onPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  DSSizedBoxSpacing.vertical(8),
                                  Text(
                                    'Será informada uma localização aproximada até que o evento seja confirmado.',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                                  )
                                ]
                              )
                          ],
                        ),
                      );
                    },
                  ),
                  
                  DSSizedBoxSpacing.vertical(16),
                  
                  // Mapa com a localização do evento
                  // Mostrar localização exata apenas quando o evento está confirmado ou completado
                  // Nos demais casos, mostrar localização aproximada para privacidade
                  EventLocationMap(
                    address: contract.address,
                    height: 250,
                    showExactLocation: _status == ContractStatusEnum.confirmed ||
                        _status == ContractStatusEnum.completed,
                    seed: contract.uid, // Usar UID do contrato como seed para localização consistente
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
                    child: _buildInfoRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Valor Total',
                      value: _formatCurrency(contract.value),
                      textTheme: textTheme,
                      onSurfaceVariant: onSurfaceVariant,
                      onPrimary: onPrimary,
                      isHighlighted: true,
                    ),
                  ),

                  DSSizedBoxSpacing.vertical(32),

                  // Botões baseados no status
                  if (_status == ContractStatusEnum.pending) ...[
                    // PENDING -> Botões Aceitar e Rejeitar
                    Row(
                      children: [
                        Expanded(
                          child: CardActionButton(
                            label: 'Rejeitar',
                            onPressed: isAnyLoading ? null : () => _handleReject(context),
                            buttonType: CardActionButtonType.cancel,
                            icon: Icons.close_rounded,
                            height: DSSize.height(48),
                            isLoading: isRejecting,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(12),
                        Expanded(
                          child: CardActionButton(
                            label: 'Aceitar',
                            onPressed: isAnyLoading ? null : () => _handleAccept(context),
                            icon: Icons.check_rounded,
                            buttonType: CardActionButtonType.default_,
                            height: DSSize.height(48),
                            isLoading: isAccepting,
                          ),
                        ),
                      ],
                    ),
                  ] else if (_status == ContractStatusEnum.rejected ||
                            _status == ContractStatusEnum.confirmed ||
                            _status == ContractStatusEnum.completed ||
                            _status == ContractStatusEnum.canceled) ...[
                    // REJECTED, CONFIRMED, COMPLETED, CANCELED -> Botão Cancelar
                    CustomButton(
                      label: 'Cancelar',
                      onPressed: () => _handleCancelRequest(context),
                      filled: true,
                      backgroundColor: colorScheme.error,
                      textColor: colorScheme.onError,
                      height: DSSize.height(48),
                    ),
                  ],
                  // Resto -> Sem botões

                  DSSizedBoxSpacing.vertical(16),
                ],
              ),
            ),
          );
        },
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

  Widget _buildContractorInfo(
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
              (contract.nameClient ?? 'A')[0].toUpperCase(),
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
                  contract.nameClient ?? 'Anfitrião',
                  style: textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                Text(
                  'Anfitrião',
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

  void _handleAccept(BuildContext context) {
    if (contract.uid == null || contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    context.read<ContractsBloc>().add(
      AcceptContractEvent(contractUid: contract.uid!),
    );
  }

  void _handleReject(BuildContext context) {
    if (contract.uid == null || contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rejeitar Solicitação',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja rejeitar esta solicitação? Esta ação não pode ser desfeita.',
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
              context.read<ContractsBloc>().add(
                RejectContractEvent(contractUid: contract.uid!),
              );
            },
            child: Text(
              'Sim, rejeitar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
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

}

