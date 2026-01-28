import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/shared/extensions/contract_deadline_extension.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
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
              
              // Indicador de prazo para aceitar (apenas para artista com contrato pendente)
              if (isArtist && contract.isPending && contract.acceptDeadline != null) ...[
                DSSizedBoxSpacing.vertical(12),
                _buildDeadlineIndicator(context),
              ],
              
              // Botões de ação (se fornecidos)
              if (_buildActionButtonsSection() != null) ...[
                DSSizedBoxSpacing.vertical(16),
                _buildActionButtonsSection()!,
              ],
            ],
          ),
    );
  }
}

