import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/event/event_entity.dart';
import 'package:app/core/enums/event_status_enum.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_card.dart';
import 'package:app/features/contracts/presentation/widgets/contract_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractCard extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final bool isArtist;

  const ContractCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onCancel,
    this.onViewDetails,
    this.isArtist = false,
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

  EventStatusEnum get _status {
    final statusUpper = event.status.toUpperCase();
    return EventStatusEnum.values.firstWhere(
      (e) => e.name == statusUpper,
      orElse: () => EventStatusEnum.pending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;

    final date = event.date ?? DateTime.now();
    final dateFormatted = DateFormat('dd/MM/yyyy').format(date);
    final timeFormatted = event.time;

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
                event.eventType?.name ?? 'Evento',
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
                        ? (event.nameContractor ?? 'A')
                        : (event.nameArtist ?? 'A'))[0].toUpperCase(),
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
                            ? (event.nameContractor ?? 'Anfitrião')
                            : (event.nameArtist ?? 'Artista'),
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
                        '$timeFormatted • ${_formatDuration(event.duration)}',
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
                      event.address?.title ?? 'Endereço não informado',
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
                      _formatCurrency(event.value),
                      style: textTheme.titleMedium?.copyWith(
                        color: onPrimaryContainer,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ações baseadas no status
              // if (_status == EventStatusEnum.pending) ...[
              //   DSSizedBoxSpacing.vertical(16),
              //   CustomButton(
              //     label: 'Cancelar Solicitação',
              //     onPressed: onCancel,
              //     filled: true,
              //     backgroundColor: colorScheme.onError,
              //     textColor: colorScheme.onPrimary,
              //   ),
              // ],
              
              if (_status == EventStatusEnum.accepted || _status == EventStatusEnum.pending) ...[
                DSSizedBoxSpacing.vertical(16),
                CustomButton(
                  label: 'Ver Detalhes',
                  onPressed: onViewDetails ?? onTap,
                  icon: Icons.arrow_forward_rounded,
                  iconOnRight: true,
                  height: DSSize.height(40),
                  buttonType: CustomButtonType.cancel,
                ),
              ],
            ],
          ),
    );
  }
}

