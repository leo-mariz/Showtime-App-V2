import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/extensions/contract_deadline_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/event_location_map.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:app/features/contracts/presentation/widgets/cancel_contract_dialog.dart';
import 'package:app/features/contracts/presentation/widgets/confirmation_code_card.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:app/features/contracts/presentation/widgets/rating_section.dart';
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class ClientEventDetailScreen extends StatefulWidget {
  final ContractEntity contract;

  const ClientEventDetailScreen({
    super.key,
    required this.contract,
  });

  @override
  State<ClientEventDetailScreen> createState() => _ClientEventDetailScreenState();
}

class _ClientEventDetailScreenState extends State<ClientEventDetailScreen> {
  late ContractEntity _contract;

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
  }

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

  ContractStatusEnum get _status => _contract.status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimary = colorScheme.onPrimary;
    final primaryContainer = colorScheme.primaryContainer;
    final isGroup = _contract.isGroupContract;

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
        } else if (state is RateArtistSuccess) {
          context.showSuccess('Avaliação enviada com sucesso!');
          // Recarregar o contrato para atualizar a UI
          if (_contract.uid != null && _contract.uid!.isNotEmpty) {
            context.read<ContractsBloc>().add(
              GetContractEvent(contractUid: _contract.uid!),
            );
          }
        } else if (state is RateArtistFailure) {
          context.showError(state.error);
        } else if (state is GetContractSuccess) {
          // Atualizar o contrato local quando recarregado
          setState(() {
            _contract = state.contract;
          });
        } else if (state is VerifyPaymentSuccess) {
          context.showSuccess('O pagamento foi identificado com sucesso!');
          // Recarregar o contrato após verificar pagamento
          if (_contract.uid != null && _contract.uid!.isNotEmpty) {
            context.read<ContractsBloc>().add(
              GetContractEvent(contractUid: _contract.uid!),
            );
          }
        } else if (state is VerifyPaymentFailure) {
          context.showError(state.error);
          // Recarregar o contrato após verificar pagamento
          if (_contract.uid != null && _contract.uid!.isNotEmpty) {
            context.read<ContractsBloc>().add(
              GetContractEvent(contractUid: _contract.uid!),
            );
          }
        }
      },
      child: BasePage(
        showAppBar: true,
        showAppBarBackButton: true,
        appBarTitle: 'Detalhes do Evento',
        child: GestureDetector(
          onTap: () {
            // Fechar teclado ao tocar em qualquer lugar da tela
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                ContractStatusBadge(status: _status, isArtist: false),
              ],
            ),

            DSSizedBoxSpacing.vertical(24),

            // Tipo de Evento
            Text(
              _contract.eventType?.name ?? 'Evento',
              style: textTheme.headlineSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            DSSizedBoxSpacing.vertical(24),

            // Informações do Artista
            _buildSectionTitle('Solicitado para', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildArtistInfo(context, colorScheme, textTheme, onPrimary, isGroup: isGroup),

            DSSizedBoxSpacing.vertical(24),

            // Código de Confirmação (quando pago)
            if (_status == ContractStatusEnum.paid && _contract.keyCode != null && _contract.keyCode!.isNotEmpty) ...[
              _buildSectionTitle('Código de Confirmação', textTheme, onPrimary),
              DSSizedBoxSpacing.vertical(12),
              ConfirmationCodeCard(confirmationCode: _contract.keyCode!),
              DSSizedBoxSpacing.vertical(24),
            ],


            

            // Data e Hora
            _buildSectionTitle('Data e Hora', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Data',
              value: _formatDate(_contract.date),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Horário de Início',
              value: _formatTime(_contract.time),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.timer_rounded,
              label: 'Duração',
              value: _formatDuration(_contract.duration),
              textTheme: textTheme,
              onSurfaceVariant: onSurfaceVariant,
              onPrimary: onPrimary,
            ),

            // Prazo para o artista responder (apenas quando pendente)
            if (_status == ContractStatusEnum.pending &&
                _contract.acceptDeadline != null) ...[
              DSSizedBoxSpacing.vertical(12),
              Container(
                padding: EdgeInsets.all(DSSize.width(12)),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DSSize.width(8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: DSSize.width(18),
                      color: colorScheme.onPrimaryContainer,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Expanded(
                      child: Text(
                        _contract.formattedAcceptDeadlineForClient ?? 'Prazo não disponível',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            DSSizedBoxSpacing.vertical(24),

            // Localização
            _buildSectionTitle('Localização', textTheme, onPrimary),
            DSSizedBoxSpacing.vertical(12),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              label: 'Endereço',
              value: '${_contract.address.district}, ${_contract.address.city} - ${_contract.address.state}',
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
                  if (_contract.address.street != null && _contract.address.street!.isNotEmpty)
                    Text(
                      '${_contract.address.street}${_contract.address.number != null ? ", ${_contract.address.number}" : ""}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  if (_contract.address.zipCode.isNotEmpty)
                    Text(
                      'CEP: ${_contract.address.zipCode}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            DSSizedBoxSpacing.vertical(16),
                  
            // Mapa com a localização do evento
            // Mostrar localização exata apenas quando o evento está confirmado ou completado
            // Nos demais casos, mostrar localização aproximada para privacidade
            EventLocationMap(
              address: _contract.address,
              height: 250,
              showExactLocation: true,
              seed: _contract.uid, // Usar UID do contrato como seed para localização consistente
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
                    value: _formatCurrency(_contract.value),
                    textTheme: textTheme,
                    onSurfaceVariant: onSurfaceVariant,
                    onPrimary: onPrimary,
                    isHighlighted: true,
                  ),
                  DSSizedBoxSpacing.vertical(12),
                  _buildInfoRow(
                    icon: Icons.payment_rounded,
                    label: 'Status do Pagamento',
                    value: _getPaymentStatusLabel(_contract.status),
                    textTheme: textTheme,
                    onSurfaceVariant: onSurfaceVariant,
                    onPrimary: onPrimary,
                  ),
                ],
              ),
            ),

            DSSizedBoxSpacing.vertical(24),

            // Seção de Avaliação (quando completado)
            if (_status == ContractStatusEnum.completed) ...[
              _buildSectionTitle('Avaliação', textTheme, onPrimary),
              DSSizedBoxSpacing.vertical(12),
              BlocBuilder<ContractsBloc, ContractsState>(
                builder: (context, state) {
                  final isLoading = state is RateArtistLoading;
                  final hasAlreadyRated = _contract.rateByClient != null;
                  final existingRating = _contract.rateByClient?.rating.toInt();
                  final existingComment = _contract.rateByClient?.comment;
                  
                  return RatingSection(
                    personName: _contract.contractorName ?? 'Artista',
                    isRatingArtist: true,
                    isLoading: isLoading,
                    hasAlreadyRated: hasAlreadyRated,
                    existingRating: existingRating,
                    existingComment: existingComment,
                    onSubmit: _contract.uid != null && _contract.uid!.isNotEmpty
                        ? (rating, comment) {
                            context.read<ContractsBloc>().add(
                              RateArtistEvent(
                                contractUid: _contract.uid!,
                                rating: rating.toDouble(),
                                comment: comment,
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
              DSSizedBoxSpacing.vertical(24),
            ],

            // Botões de Ação
            if (_status == ContractStatusEnum.paymentPending) ...[
              BlocBuilder<ContractsBloc, ContractsState>(
                builder: (context, state) {
                  final isVerifying = state is VerifyPaymentLoading;
                  final shouldShowVerifyButton = _contract.isPaying == true;
                  
                  return SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: shouldShowVerifyButton ? 'Verificar Pagamento' : 'Realizar Pagamento',
                      onPressed: shouldShowVerifyButton 
                          ? () => _handleVerifyPayment(context)
                          : () => _handlePayment(context),
                      icon: shouldShowVerifyButton 
                          ? Icons.check_circle_rounded 
                          : Icons.payment_rounded,
                      iconOnRight: true,
                      height: DSSize.height(48),
                      isLoading: isVerifying,
                    ),
                  );
                },
              ),
              DSSizedBoxSpacing.vertical(16),
            ],
            if (_status != ContractStatusEnum.completed && 
                _status != ContractStatusEnum.rejected &&
                _status != ContractStatusEnum.canceled) ...[
              // Botões de ajuda e cancelamento
              Align(
                alignment: Alignment.centerRight,
                child: BlocBuilder<ContractsBloc, ContractsState>(
                  builder: (context, state) {
                    final isCanceling = state is CancelContractLoading;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.router.push(SupportRoute(contract: _contract));
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: DSSize.width(12),
                              vertical: DSSize.height(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Precisa de ajuda?',
                            style: textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                              color: onPrimary,
                            ),
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(8),
                        TextButton(
                          onPressed: isCanceling ? null : () => _handleCancelRequest(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: DSSize.width(12),
                              vertical: DSSize.height(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cancelar',
                            style: textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                        if (isCanceling)
                          Padding(
                            padding: EdgeInsets.only(left: DSSize.width(8)),
                            child: SizedBox(
                              width: DSSize.width(16),
                              height: DSSize.width(16),
                              child: CustomLoadingIndicator(
                                strokeWidth: 2,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                      ],
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
    {bool isGroup = false}
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
              (_contract.contractorName ?? 'A')[0].toUpperCase(),
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
                   (_contract.contractorName ?? 'Artista'),
                  style: textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                Text(
                  isGroup ? 'Conjunto' : 'Artista',
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
    if (status == ContractStatusEnum.paymentPending) {
      return 'Aguardando pagamento';
    } else if (status == ContractStatusEnum.paid) {
      return 'Pago';
    } else if (status == ContractStatusEnum.completed) {
      return 'Pago';
    } else if (status == ContractStatusEnum.rejected) {
      return 'Rejeitado';
    } else if (status == ContractStatusEnum.canceled) {
      return 'Cancelado';
    } else if (status == ContractStatusEnum.paymentExpired) {
      return 'Pagamento expirado';
    } else if (status == ContractStatusEnum.paymentRefused) {
      return 'Pagamento recusado';
    } else if (status == ContractStatusEnum.paymentFailed) {
      return 'Pagamento falhou';
    } else{
      return "Pendente";
    }
  }

  void _handleCancelRequest(BuildContext context) async {
    final confirmed = await CancelContractDialog.show(
      context: context,
      isLoading: false,
    );

    if (confirmed == true && _contract.uid != null && _contract.uid!.isNotEmpty) {
      context.read<ContractsBloc>().add(
        CancelContractEvent(
          contractUid: _contract.uid!,
          canceledBy: 'CLIENT',
        ),
      );
    }
  }

  void _handlePayment(BuildContext context) {
    if (_contract.linkPayment == null || _contract.linkPayment!.isEmpty) {
      context.showError('Link de pagamento não disponível. Entre em contato com o suporte.');
      return;
    }

    context.read<ContractsBloc>().add(
          MakePaymentEvent(linkPayment: _contract.linkPayment!, contractUid: _contract.uid!),
        );
  }

  void _handleVerifyPayment(BuildContext context) {
    if (_contract.uid == null || _contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    context.read<ContractsBloc>().add(
      VerifyPaymentEvent(contractUid: _contract.uid!),
    );
  }
}

