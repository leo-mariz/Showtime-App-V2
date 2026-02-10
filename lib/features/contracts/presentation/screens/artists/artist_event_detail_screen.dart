import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/extensions/contract_deadline_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/card_action_button.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/event_location_map.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
// import 'package:app/core/shared/widgets/informative_banner.dart';
import 'package:app/features/contracts/presentation/widgets/cancel_contract_dialog.dart';
import 'package:app/features/contracts/presentation/widgets/confirm_show_modal.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:app/features/contracts/presentation/widgets/navigation_options_modal.dart';
import 'package:app/features/contracts/presentation/widgets/rating_section.dart';
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
  late ContractEntity _contract;
  
  @override
  void initState() {
    super.initState();
    _contract = widget.contract;
  }
  
  ContractEntity get contract => _contract;

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
        } else if (state is CancelContractSuccess) {
          context.showSuccess('Contrato cancelado com sucesso!');
          // Voltar para a tela anterior e sinalizar que precisa recarregar
          if (mounted) {
            context.router.pop(true);
          }
        } else if (state is CancelContractFailure) {
          context.showError(state.error);
        } else if (state is ConfirmShowSuccess) {
          context.showSuccess('Show confirmado com sucesso!');
          // Voltar para a tela anterior e sinalizar que precisa recarregar
          if (mounted) {
            context.router.pop(true);
          }
        } else if (state is ConfirmShowFailure) {
          context.showError(state.error);
        } else if (state is RateClientSuccess) {
          context.showSuccess('Avaliação enviada com sucesso!');
          // Recarregar o contrato para atualizar a UI
          if (_contract.uid != null && _contract.uid!.isNotEmpty) {
            context.read<ContractsBloc>().add(
              GetContractEvent(contractUid: _contract.uid!),
            );
          }
        } else if (state is RateClientFailure) {
          context.showError(state.error);
        } else if (state is GetContractSuccess) {
          // Atualizar o contrato local quando recarregado
          setState(() {
            _contract = state.contract;
          });
        }
      },
      child: BlocBuilder<ContractsBloc, ContractsState>(
        builder: (context, state) {
          final isAccepting = state is AcceptContractLoading;
          final isRejecting = state is RejectContractLoading;
          final isCanceling = state is CancelContractLoading;
          final isAnyLoading = isAccepting || isRejecting || isCanceling;

          return BasePage(
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
                      ContractStatusBadge(status: _status, isArtist: true),
                    ],
                  ),

                  // Indicador quando a solicitação é para um conjunto
                  if (_contract.isGroupContract && _contract.nameGroup != null && _contract.nameGroup!.isNotEmpty) ...[
                    DSSizedBoxSpacing.vertical(12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DSSize.width(12),
                        vertical: DSSize.width(8),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(DSSize.width(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: DSSize.width(20),
                            color: colorScheme.onPrimaryContainer,
                          ),
                          DSSizedBoxSpacing.horizontal(8),
                          Expanded(
                            child: Text(
                              'Solicitação para o conjunto ${_contract.nameGroup}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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

                  // Prazo para aceitar (apenas quando pendente)
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
                              _contract.formattedAcceptDeadline ?? 'Prazo não disponível',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Prazo para o anfitrião pagar (quando aguardando pagamento)
                  if (_status == ContractStatusEnum.paymentPending &&
                      _contract.paymentDueDate != null &&
                      !_contract.isPaymentDeadlineExpired) ...[
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
                              _contract.formattedPaymentDeadlineForArtist ?? 'Prazo não disponível',
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
                  
                  // Informações do endereço (sem título)
                  // Mostrar endereço completo apenas quando evento estiver confirmado
                  // Caso contrário, mostrar apenas bairro e cidade
                  Builder(
                    builder: (context) {
                      final isConfirmed = _status == ContractStatusEnum.paid ||
                          _status == ContractStatusEnum.completed;
                      
                      return Padding(
                        padding: EdgeInsets.only(left: DSSize.width(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isConfirmed)
                              // Endereço completo (quando confirmado)
                              ...[
                                if (_contract.address.street != null && _contract.address.street!.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: DSSize.width(18),
                                        color: onSurfaceVariant,
                                      ),
                                      DSSizedBoxSpacing.horizontal(16),
                                      if (_contract.address.district != null && _contract.address.district!.isNotEmpty)
                                        Text(
                                          '${_contract.address.district!},',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: onPrimary,
                                          ),
                                        ),
                                      if (_contract.address.district != null && _contract.address.district!.isNotEmpty)
                                        DSSizedBoxSpacing.horizontal(16),
                                      Text(
                                        '${_contract.address.street}${_contract.address.number != null ? ", ${_contract.address.number}" : ""}',
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
                                    if (_contract.address.city != null && _contract.address.state != null)
                                      Text(
                                        '${_contract.address.city} - ${_contract.address.state}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    DSSizedBoxSpacing.horizontal(16),
                                    if (_contract.address.zipCode.isNotEmpty)
                                      Text(
                                        'CEP: ${_contract.address.zipCode}',
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
                                      if (_contract.address.district != null && _contract.address.district!.isNotEmpty)
                                        Text(
                                          _contract.address.district!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: onPrimary,
                                          ),
                                        ),
                                      if (_contract.address.district != null && _contract.address.district!.isNotEmpty)
                                        DSSizedBoxSpacing.horizontal(8),
                                      if (_contract.address.city != null && _contract.address.state != null)
                                        Text(
                                          '${_contract.address.city} - ${_contract.address.state}',
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
                    address: _contract.address,
                    height: 250,
                    showExactLocation: _status == ContractStatusEnum.paid ||
                        _status == ContractStatusEnum.completed,
                    seed: _contract.uid, // Usar UID do contrato como seed para localização consistente
                  ),

                  // Botão "Como chegar" (apenas quando PAID)
                  if (_status == ContractStatusEnum.paid) ...[
                    DSSizedBoxSpacing.vertical(16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final address = _contract.address;
                          if (address.latitude != null && address.longitude != null) {
                            // Monta o endereço completo para exibir no modal
                            final addressParts = <String>[];
                            if (address.street != null && address.street!.isNotEmpty) {
                              addressParts.add(address.street!);
                              if (address.number != null && address.number!.isNotEmpty) {
                                addressParts.add(address.number!);
                              }
                            }
                            if (address.district != null && address.district!.isNotEmpty) {
                              addressParts.add(address.district!);
                            }
                            if (address.city != null && address.state != null) {
                              addressParts.add('${address.city} - ${address.state}');
                            }
                            
                            NavigationOptionsModal.show(
                              context: context,
                              latitude: address.latitude!,
                              longitude: address.longitude!,
                              addressLabel: addressParts.isNotEmpty 
                                  ? addressParts.join(', ')
                                  : null,
                            );
                          } else {
                            context.showError('Localização não disponível');
                          }
                        },
                        icon: Icon(Icons.directions_rounded),
                        label: Text('Como chegar'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: DSSize.width(16),
                            vertical: DSSize.height(12),
                          ),
                          backgroundColor: colorScheme.onPrimaryContainer,
                        ),
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
                    child: _buildInfoRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Valor Total',
                      value: _formatCurrency(_contract.value),
                      textTheme: textTheme,
                      onSurfaceVariant: onSurfaceVariant,
                      onPrimary: onPrimary,
                      isHighlighted: true,
                    ),
                  ),

                  DSSizedBoxSpacing.vertical(16),


                  // Seção de Avaliação (quando completado)
                  if (_status == ContractStatusEnum.completed) ...[
                    _buildSectionTitle('Avaliação', textTheme, onPrimary),
                    DSSizedBoxSpacing.vertical(12),
                    BlocBuilder<ContractsBloc, ContractsState>(
                      builder: (context, state) {
                        final isLoading = state is RateClientLoading;
                        final hasAlreadyRated = _contract.rateByArtist != null;
                        final existingRating = _contract.rateByArtist?.rating.toInt();
                        final existingComment = _contract.rateByArtist?.comment;
                        
                        return RatingSection(
                          personName: _contract.nameClient ?? 'Anfitrião',
                          isRatingArtist: false,
                          isLoading: isLoading,
                          hasAlreadyRated: hasAlreadyRated,
                          existingRating: existingRating,
                          existingComment: existingComment,
                          onSubmit: _contract.uid != null && _contract.uid!.isNotEmpty
                              ? (rating, comment) {
                                  context.read<ContractsBloc>().add(
                                    RateClientEvent(
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

                  
                  // Confirmação do Show (quando pago)
                  if (_status == ContractStatusEnum.paid) ...[
                    
                    Divider(),
                    DSSizedBoxSpacing.vertical(16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'O Show irá começar?',
                        onPressed: isAnyLoading ? null : () => _handleConfirmShow(context),
                        icon: Icons.check_circle_rounded,
                        iconOnLeft: true,
                        height: DSSize.height(48),
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(16),

                    // InformativeBanner(
                    //   message: 'Após a finalização do show, peça ao cliente o código de confirmação e confirme o evento realizado.',
                    //   icon: Icons.info_outline_rounded,
                    // ),
                  ],

                  DSSizedBoxSpacing.vertical(8),

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
                            _status == ContractStatusEnum.completed ||
                            _status == ContractStatusEnum.canceled) ...[
                    // REJECTED, CONFIRMED, COMPLETED, CANCELED -> Sem botões (já está cancelado ou finalizado)
                  ] else ...[
                    // PAYMENT_PENDING, PAID -> Botões de ajuda e cancelamento
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
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
                          BlocBuilder<ContractsBloc, ContractsState>(
                            builder: (context, state) {
                              final isCanceling = state is CancelContractLoading;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: isAnyLoading || isCanceling ? null : () => _handleCancelRequest(context),
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
                        ],
                      ),
                    ),
                  ],
                  // Resto -> Sem botões

                  DSSizedBoxSpacing.vertical(16),
                ],
              ),
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
              (_contract.nameClient ?? 'A')[0].toUpperCase(),
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
                  _contract.nameClient ?? 'Anfitrião',
                  style: textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DSSizedBoxSpacing.vertical(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Anfitrião',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    if (_contract.clientRatingCount != null && _contract.clientRatingCount! > 0) ...[
                      Text(
                        _contract.clientRating?.toStringAsFixed(2) ?? '0',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(2),
                      Icon(
                        Icons.star_rounded,
                        size: DSSize.width(16),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ] else ...[
                      Text(
                        'Sem avaliações',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ]
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
    if (_contract.uid == null || _contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    context.read<ContractsBloc>().add(
      AcceptContractEvent(contractUid: _contract.uid!),
    );
  }

  void _handleReject(BuildContext context) {
    if (_contract.uid == null || _contract.uid!.isEmpty) {
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
                RejectContractEvent(contractUid: _contract.uid!),
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

  void _handleCancelRequest(BuildContext context) async {
    final confirmed = await CancelContractDialog.show(
      context: context,
      isLoading: false,
    );

    if (confirmed == true && _contract.uid != null && _contract.uid!.isNotEmpty) {
      context.read<ContractsBloc>().add(
        CancelContractEvent(
          contractUid: _contract.uid!,
          canceledBy: 'ARTIST',
        ),
      );
    }
  }

  void _handleConfirmShow(BuildContext context) async {
    if (_contract.uid == null || _contract.uid!.isEmpty) {
      context.showError('Erro: Contrato sem identificador');
      return;
    }

    await ConfirmShowModal.show(
      context: context,
      contractUid: _contract.uid!,
    );
  }

}

