import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget da Tab Agenda
/// 
/// Visualização de horários em formato de timeline
/// SOMENTE LEITURA (sem edição)
/// 
/// Widget de apresentação puro que recebe dados por parâmetros
class AgendaViewWidget extends StatefulWidget {
  /// Lista de dias com disponibilidade
  final List<AvailabilityDayEntity> days;
  
  /// Indica se está carregando
  final bool isLoading;

  const AgendaViewWidget({
    super.key,
    required this.days,
    required this.isLoading,
  });

  @override
  State<AgendaViewWidget> createState() => _AgendaViewWidgetState();
}

class _AgendaViewWidgetState extends State<AgendaViewWidget> {
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = false;

  String _formatDateToId(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header com seleção de data
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Navegação de data
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(
                          Duration(days: _isWeekView ? 7 : 1),
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEEE', 'pt_BR').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            DateFormat('dd \'de\' MMMM, yyyy', 'pt_BR')
                                .format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          Duration(days: _isWeekView ? 7 : 1),
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Toggle visão
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Dia'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Semana'),
                    icon: Icon(Icons.view_week),
                  ),
                ],
                selected: {_isWeekView},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isWeekView = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Timeline
        Expanded(
          child: Builder(
            builder: (context) {
              if (widget.isLoading && widget.days.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.days.isNotEmpty) {
                // Buscar o dia específico
                final dayId = _formatDateToId(_selectedDate);
                final dayIndex = widget.days.indexWhere((d) => d.documentId == dayId);
                
                if (dayIndex == -1) {
                  return _buildEmptyState();
                }
                
                final day = widget.days[dayIndex];
                
                if (_isWeekView) {
                  return _buildWeekView();
                } else {
                  return _buildDayTimeline(day);
                }
              }

              return _buildEmptyState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sem disponibilidade neste dia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Não há horários configurados para esta data.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTimeline(day) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumo do dia
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  label: 'Disponíveis',
                  count: _countAvailableSlots(day),
                ),
                _buildSummaryItem(
                  icon: Icons.block,
                  color: Colors.red,
                  label: 'Bloqueados',
                  count: _countBlockedSlots(day),
                ),
                _buildSummaryItem(
                  icon: Icons.event,
                  color: Colors.blue,
                  label: 'Shows',
                  count: _countBookedSlots(day),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Availabilities (cada uma com seu endereço e slots)
        ...day.availabilities.map((availability) => _buildAddressTimeline(availability.address)),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  int _countAvailableSlots(day) {
    return day.availabilities
        .expand((av) => av.slots)
        .where((s) => s.isAvailable)
        .length;
  }

  int _countBlockedSlots(day) {
    return day.availabilities
        .expand((av) => av.slots)
        .where((s) => s.isBlocked)
        .length;
  }

  int _countBookedSlots(day) {
    return day.availabilities
        .expand((av) => av.slots)
        .where((s) => s.isBooked)
        .length;
  }

  Widget _buildAddressTimeline(address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do endereço
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.endereco.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Raio: ${address.raioAtuacao}km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Timeline de slots
            ...address.slots.map((slot) => _buildTimelineSlot(slot)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSlot(slot) {
    Color color;
    IconData icon;
    String status;

    if (slot.isAvailable) {
      color = Colors.green;
      icon = Icons.check_circle;
      status = 'Disponível';
    } else if (slot.isBlocked) {
      color = Colors.red;
      icon = Icons.block;
      status = 'Bloqueado';
    } else {
      color = Colors.blue;
      icon = Icons.event;
      status = 'Show Confirmado';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador visual
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Conteúdo
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (slot.valorHora != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${slot.valorHora!.toStringAsFixed(2)}/hora',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (slot.blockReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Motivo: ${slot.blockReason}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Visão Semanal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Em desenvolvimento',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
