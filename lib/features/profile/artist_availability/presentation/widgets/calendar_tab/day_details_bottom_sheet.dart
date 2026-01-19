import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/availability_bloc.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/events/availability_events.dart';
import 'package:app/features/profile/artist_availability/presentation/bloc/states/availability_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Bottom sheet mostrando detalhes de um dia
/// 
/// Permite editar ou deletar disponibilidade do dia
class DayDetailsBottomSheet extends StatefulWidget {    
  final DateTime selectedDate;

  const DayDetailsBottomSheet({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DayDetailsBottomSheet> createState() => _DayDetailsBottomSheetState();
}

class _DayDetailsBottomSheetState extends State<DayDetailsBottomSheet> {
  @override
  void initState() {
    super.initState();
    _loadDayDetails();
  }

  void _loadDayDetails() {
    // Buscar todas as disponibilidades
    context.read<AvailabilityBloc>().add(
      GetAvailabilityEvent(GetAvailabilityDto(
        forceRemote: true,
      )),
    );
  }

  String _formatDateToId(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<AvailabilityBloc, AvailabilityState>(
          builder: (context, state) {
            if (state is AvailabilityLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AvailabilityLoadedState) {
              // Buscar o dia específico da lista
              final dayId = _formatDateToId(widget.selectedDate);
              final day = state.days.firstWhere(
                (d) => d.documentId == dayId,
                orElse: () => null as AvailabilityDayEntity,
              );
              
              if (day == null) {
                return _buildEmptyState();
              }
              
              return _buildDayDetails(day, scrollController);
            }

            if (state is AvailabilityErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Sem disponibilidade neste dia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Você ainda não configurou disponibilidade para esta data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Abrir formulário de criar
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Disponibilidade'),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetails(AvailabilityDayEntity day, ScrollController scrollController) {
    final dateFormat = DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR');
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(widget.selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (day.isOverridden)
                  Chip(
                    label: const Text('Customizado'),
                    avatar: const Icon(Icons.star, size: 16),
                    backgroundColor: Colors.purple.shade100,
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Lista de endereços e slots
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: day.addresses.length,
              itemBuilder: (context, index) {
                final address = day.addresses[index];
                return _buildAddressCard(address);
              },
            ),
          ),
          
          // Ações
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleEdit(day),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleDelete(day),
                    icon: const Icon(Icons.delete),
                    label: const Text('Remover'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Endereço
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.endereco.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Raio: ${address.raioAtuacao}km',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            
            // Slots
            ...address.slots.map((slot) => _buildSlotItem(slot)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotItem(slot) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    if (slot.isAvailable) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
      statusText = 'Disponível';
    } else if (slot.isBlocked) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.block;
      statusText = 'Bloqueado';
    } else {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      icon = Icons.event;
      statusText = 'Reservado';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${slot.startTime} - ${slot.endTime}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (slot.valorHora != null) ...[
            const SizedBox(height: 4),
            Text(
              'R\$ ${slot.valorHora!.toStringAsFixed(2)}/h',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ],
          if (slot.blockReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Motivo: ${slot.blockReason}',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleEdit(AvailabilityDayEntity day) {
    // TODO: Implementar edição
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edição em desenvolvimento')),
    );
  }

  void _handleDelete(AvailabilityDayEntity day) {
    // TODO: Implementar deleção
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text(
          'Deseja realmente remover a disponibilidade deste dia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleção em desenvolvimento')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
