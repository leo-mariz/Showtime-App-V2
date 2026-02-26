import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/enums/contract_status_enum.dart';
import 'package:app/core/enums/showtime_payment_status_enum.dart';
import 'package:app/core/enums/invoice_status_enum.dart';
import 'package:app/core/shared/extensions/contract_deadline_extension.dart';
import 'package:app/core/shared/widgets/custom_badge.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractCard extends StatelessWidget {
  final ContractEntity contract;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final bool isArtist;
  
  // Botões de ação a serem exibidos (opcional)
  // Se 1 botão: ocupa toda a linha
  // Se 2+ botões: divide em linhas, 2 por linha
  final List<Widget>? actionButtons;

  const ContractCard({
    super.key,
    required this.contract,
    required this.onTap,
    this.onViewDetails,
    this.isArtist = false,
    this.actionButtons,
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

  /// CircleAvatar com foto (snapshot do contrato) ou inicial do nome.
  Widget _buildAvatar(
    BuildContext context, {
    required String? photoUrl,
    required String displayName,
    required ColorScheme colorScheme,
    required TextTheme? textTheme,
    required Color onPrimary,
  }) {
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: DSSize.width(20),
      backgroundColor: colorScheme.surfaceContainerHighest,
      backgroundImage: hasPhoto ? CachedNetworkImageProvider(photoUrl.trim()) : null,
      child: hasPhoto
          ? null
          : Text(
              displayName.trim().isNotEmpty ? displayName[0].toUpperCase() : 'A',
              style: textTheme?.bodyMedium?.copyWith(color: onPrimary),
            ),
    );
  }

  /// Exibe endereço no formato "Bairro, Cidade" (ex: Leblon, Rio de Janeiro).
  String _formatAddressShort(AddressInfoEntity address) {
    final district = address.district?.trim();
    final city = address.city?.trim();
    if ((district != null && district.isNotEmpty) && (city != null && city.isNotEmpty)) {
      return '$district, $city';
    }
    if (city != null && city.isNotEmpty) return city;
    if (district != null && district.isNotEmpty) return district;
    return address.title;
  }

  /// Constrói o indicador de prazo para aceitar
  Widget _buildDeadlineIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final isExpired = contract.isAcceptDeadlineExpired;
    final isCritical = contract.isDeadlineCritical;
    final isNear = contract.isDeadlineNear;
    
    // Cor baseada no estado do prazo
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    if (isExpired) {
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      icon = Icons.error_outline_rounded;
    } else if (isCritical) {
      backgroundColor = colorScheme.errorContainer.withOpacity(0.3);
      textColor = colorScheme.error;
      icon = Icons.warning_amber_rounded;
    } else if (isNear) {
      backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.3);
      textColor = colorScheme.onTertiaryContainer;
      icon = Icons.access_time_rounded;
    } else {
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.2);
      textColor = colorScheme.onPrimaryContainer;
      icon = Icons.schedule_rounded;
    }
    
    return Container(
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: isExpired || isCritical
            ? Border.all(color: colorScheme.error.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: DSSize.width(18),
            color: textColor,
          ),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              contract.formattedAcceptDeadline ?? 'Prazo não disponível',
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isExpired || isCritical ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// True quando um deadline expirou e não devemos mostrar botões (aceite ou pagamento).
  bool get _isDeadlineExpiredNoActions =>
      (contract.isPending && contract.isAcceptDeadlineExpired) ||
      (contract.isPaymentPending && contract.isPaymentDeadlineExpired);

  /// Bloco único quando o prazo expirou: indica expirado + cancelado automaticamente (sem botões).
  Widget _buildExpiredCanceledMessage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPayment = contract.isPaymentPending && contract.isPaymentDeadlineExpired;
    final message = isPayment
        ? 'Prazo de pagamento expirado. Este contrato foi cancelado automaticamente.'
        : 'Prazo para aceitar expirado. Este contrato foi cancelado automaticamente.';
    return Container(
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: Border.all(color: colorScheme.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: DSSize.width(18),
            color: colorScheme.onErrorContainer,
          ),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de prazo para o cliente (data/hora em que o artista pode aceitar)
  Widget _buildClientDeadlineIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final text = contract.formattedAcceptDeadlineForClient ?? 'Prazo não disponível';
    return Container(
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
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de prazo de pagamento: para o cliente "Você tem até X para pagar";
  /// para o artista "O anfitrião tem até X para pagar".
  Widget _buildPaymentDeadlineIndicator(BuildContext context, {String? textOverride}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCritical = contract.isPaymentDeadlineCritical;
    final isNear = contract.isPaymentDeadlineNear;
    Color backgroundColor;
    Color textColor;
    IconData icon;
    if (isCritical) {
      backgroundColor = colorScheme.errorContainer.withOpacity(0.3);
      textColor = colorScheme.error;
      icon = Icons.warning_amber_rounded;
    } else if (isNear) {
      backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.3);
      textColor = colorScheme.onTertiaryContainer;
      icon = Icons.access_time_rounded;
    } else {
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.2);
      textColor = colorScheme.onPrimaryContainer;
      icon = Icons.schedule_rounded;
    }
    final text = textOverride ?? contract.formattedPaymentDeadline ?? 'Prazo não disponível';
    return Container(
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DSSize.width(8)),
        border: isCritical || isNear
            ? Border.all(color: colorScheme.error.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: DSSize.width(18), color: textColor),
          DSSizedBoxSpacing.horizontal(8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isCritical || isNear ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Organiza os botões de ação
  // Se 1 botão: ocupa toda a linha
  // Se 2+ botões: divide em linhas, 2 por linha
  Widget? _buildActionButtonsSection() {
    if (actionButtons == null || actionButtons!.isEmpty) {
      return null;
    }

    if (actionButtons!.length == 1) {
      // Um botão: ocupa toda a linha
      return actionButtons!.first;
    }

    // Múltiplos botões: divide em linhas de 2
    final rows = <Widget>[];
    for (int i = 0; i < actionButtons!.length; i += 2) {
      if (i + 1 < actionButtons!.length) {
        // Dois botões na mesma linha
        rows.add(
          Row(
            children: [
              Expanded(child: actionButtons![i]),
          DSSizedBoxSpacing.horizontal(12),
              Expanded(child: actionButtons![i + 1]),
            ],
          ),
        );
        if (i + 2 < actionButtons!.length) {
          rows.add(DSSizedBoxSpacing.vertical(12));
        }
      } else {
        // Um botão sozinho na última linha
        rows.add(actionButtons![i]);
      }
    }

    return Column(
      children: rows,
    );
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
                  ContractStatusBadge(status: contract.status, isArtist: isArtist),
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
                  _buildAvatar(
                    context,
                    photoUrl: isArtist ? contract.clientPhotoUrl : contract.contractorPhotoUrl,
                    displayName: isArtist
                        ? (contract.nameClient ?? 'A')
                        : (contract.contractorName ?? 'A'),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onPrimary: onPrimary,
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
                        DSSizedBoxSpacing.vertical(4),  
                        if (isArtist) ...[
                          Text(
                            'Anfitrião',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                          DSSizedBoxSpacing.vertical(4),    
                        ] else ...[
                          Text(
                            contract.isGroupContract ?
                            'Conjunto' : 'Artista',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                          DSSizedBoxSpacing.vertical(4),    
                        ],
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


              if (isArtist) ...[
                DSSizedBoxSpacing.vertical(12),
                Row(
                  children: [
                    Text("Solicitado para:"),
                    DSSizedBoxSpacing.horizontal(8),
                    CustomBadge(value: 
                      contract.isGroupContract
                        ? 'Conjunto'
                        : 'Individual',
                      valueStyle: textTheme.bodySmall?.copyWith(
                      ),
                      icon: contract.isGroupContract ? Icons.group_rounded : Icons.person_rounded,
                      
                      ),
                    

                ],)
              ],
              
              
              
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
                      _formatAddressShort(contract.address),
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

              // Repasse e Nota Fiscal (artista, contrato completed)
              if (isArtist && contract.status == ContractStatusEnum.completed) ...[
                DSSizedBoxSpacing.vertical(12),
                Container(
                  padding: EdgeInsets.all(DSSize.width(12)),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(DSSize.width(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor do repasse',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatCurrency(contract.value * 0.9),
                            style: textTheme.bodyMedium?.copyWith(
                              color: onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status repasse',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                          Text(
                            contract.showtimePaymentStatus?.displayName ?? '—',
                            style: textTheme.bodySmall?.copyWith(
                              color: onPrimary,
                            ),
                          ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Nota Fiscal',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                          Text(
                            contract.invoiceStatus?.displayName ?? '—',
                            style: textTheme.bodySmall?.copyWith(
                              color: onPrimary,
                            ),
                          ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(8),
                      Text(
                        'Os pagamentos são realizados em até 72h após a realização do evento.',
                        style: textTheme.bodySmall?.copyWith(
                          color: onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Cancelado com reembolso em análise (artista e anfitrião)
              if (contract.status == ContractStatusEnum.canceled &&
                  contract.analyseRefund == true) ...[
                DSSizedBoxSpacing.vertical(12),
                Container(
                  padding: EdgeInsets.all(DSSize.width(12)),
                  decoration: BoxDecoration(
                    color: colorScheme.onTertiaryContainer,
                    borderRadius: BorderRadius.circular(DSSize.width(8)),
                    border: Border.all(
                      color: colorScheme.tertiary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        size: DSSize.width(20),
                        color: colorScheme.onPrimary,
                      ),
                      DSSizedBoxSpacing.horizontal(10),
                      Expanded(
                        child: Text(
                          'Reembolso em análise.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Prazo expirado: só mensagem, sem botões
              if (_isDeadlineExpiredNoActions) ...[
                DSSizedBoxSpacing.vertical(12),
                _buildExpiredCanceledMessage(context),
              ] else ...[
                // Indicador de prazo para aceitar (pendente, quando ainda não expirou)
                if (contract.isPending && contract.acceptDeadline != null) ...[
                  DSSizedBoxSpacing.vertical(12),
                  isArtist
                      ? _buildDeadlineIndicator(context)
                      : _buildClientDeadlineIndicator(context),
                ],
                // Indicador de prazo de pagamento: cliente = "Você tem até X para pagar"; artista = "O anfitrião tem até X para pagar"
                if (contract.isPaymentPending && contract.paymentDueDate != null && !contract.isPaymentDeadlineExpired) ...[
                  DSSizedBoxSpacing.vertical(12),
                  _buildPaymentDeadlineIndicator(
                    context,
                    textOverride: isArtist ? contract.formattedPaymentDeadlineForArtist : null,
                  ),
                ],
                // Botões de ação (não exibidos quando deadline expirado)
                if (_buildActionButtonsSection() != null) ...[
                  DSSizedBoxSpacing.vertical(16),
                  _buildActionButtonsSection()!,
                ],
              ],
            ],
          ),
    );
  }
}

