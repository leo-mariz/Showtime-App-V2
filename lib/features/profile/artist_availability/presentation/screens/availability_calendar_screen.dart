import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/calendar_widget.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/day_edit_bottom_sheet.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/forms/availability_form_modal.dart';
import 'package:flutter/material.dart';

/// Tela de calendário estilo Airbnb
/// UI MOCKADA para visualização e aprovação do design
class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() => _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState extends State<AvailabilityCalendarScreen> {
  DateTime? _selectedDay;
  List<DateTime>? _selectedDays; // Para seleção de período
  final GlobalKey<CalendarWidgetState> _calendarKey = GlobalKey<CalendarWidgetState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        top: true,
        child: Column(
          children: [
            // Barra de ações no topo
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DSSize.width(8),
                vertical: DSSize.height(4),
              ),
              child: Row(
                children: [
                  // Botão limpar seleção (aparece quando tem seleção múltipla)
                  if (_selectedDays != null && _selectedDays!.isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDays = null;
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        size: DSSize.width(18),
                        color: colorScheme.error,
                      ),
                      label: Text(
                        'Limpar (${_selectedDays!.length} dias)',
                        style: TextStyle(
                          fontSize: DSSize.width(13),
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Botão de informações (legenda)
                  IconButton(
                    onPressed: () {
                      _showLegendModal();
                    },
                    icon: Icon(
                      Icons.info_outline,
                      size: DSSize.width(22),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Legenda',
                  ),
                  SizedBox(width: DSSize.width(8)),
                  
                  // Botão adicionar disponibilidade
                  IconButton(
                    onPressed: () {
                      _showCreateAvailabilityModal();
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: DSSize.width(24),
                      color: colorScheme.onPrimaryContainer,
                    ),
                    tooltip: 'Adicionar disponibilidade',
                  ),
                ],
              ),
            ),
            
            // Calendário (com Expanded para ocupar espaço restante)
            Expanded(
              child: CalendarWidget(
                key: _calendarKey,
                selectedDay: _selectedDay,
                selectedDays: _selectedDays,
                onDaySelected: (day) {
                  setState(() {
                    _selectedDay = day;
                    _selectedDays = null; // Limpa seleção múltipla
                  });
                  _showDayEditSheet(day);
                },
                onDaysSelected: (days) {
                  setState(() {
                    _selectedDays = days;
                    _selectedDay = null; // Limpa seleção única
                  });
                  _showPeriodFormModal(days);
                },
                onClearSelection: () {
                  setState(() {
                    _selectedDays = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Selecionar hoje e fazer scroll até o dia
          setState(() {
            _selectedDay = DateTime.now();
            _selectedDays = null;
          });
          
          // Fazer scroll até o dia de hoje
          _calendarKey.currentState?.scrollToToday();
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        icon: Icon(Icons.arrow_upward, size: DSSize.width(20)),
        label: Text('Hoje', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSSize.width(24)),
        ),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDayEditSheet(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayEditBottomSheet(
        selectedDate: day,
        onClose: () {
          Navigator.of(context).pop();
          setState(() {
            _selectedDay = null;
          });
        },
      ),
    );
  }

  Future<void> _showPeriodFormModal(List<DateTime> days) async {
    if (days.isEmpty) return;
    
    // Ordenar datas para pegar a menor e a maior
    final sortedDays = List<DateTime>.from(days)
      ..sort((a, b) => a.compareTo(b));
    
    final startDate = sortedDays.first;
    final endDate = sortedDays.last;
    
    final result = await AvailabilityFormModal.show(
      context: context,
      initialStartDate: startDate,
      initialEndDate: endDate,
    );
    
    // Limpar seleção após fechar o modal
    setState(() {
      _selectedDays = null;
    });
    
    // Se retornou disponibilidades, processar
    if (result != null && result.isNotEmpty) {
      _handleAvailabilitiesCreated(result);
    }
  }

  Future<void> _showCreateAvailabilityModal() async {
    final result = await AvailabilityFormModal.show(
      context: context,
    );
    
    // Se retornou disponibilidades, processar
    if (result != null && result.isNotEmpty) {
      _handleAvailabilitiesCreated(result);
    }
  }

  void _handleAvailabilitiesCreated(List result) {
    // TODO: Integrar com BLoC para salvar disponibilidades
    // Por enquanto, apenas mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.length} dia(s) de disponibilidade criado(s)!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLegendModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLegendBottomSheet(),
    );
  }

  Widget _buildLegendBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      padding: EdgeInsets.all(DSSize.width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: DSSize.height(16)),
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),

          // Título
          Text(
            'Legenda',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          SizedBox(height: DSSize.height(8)),

          Text(
            'Entenda os ícones do calendário',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: DSSize.height(24)),

          // Lista de legendas
          _buildLegendItem(
            icon: Icons.check_circle,
            label: 'Intervalos disponíveis',
            description: 'Número de slots de horário livres',
            color: colorScheme.onSecondaryContainer,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.lock_outline,
            label: 'Fechado',
            description: 'Dia sem disponibilidade',
            color: colorScheme.onSurfaceVariant,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.close,
            label: 'Inativo',
            description: 'Disponibilidade desativada',
            color: colorScheme.error,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(16)),

          _buildLegendItem(
            icon: Icons.mic,
            label: 'Shows',
            description: 'Número de apresentações confirmadas',
            color: colorScheme.primary,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          SizedBox(height: DSSize.height(24)),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      children: [
        // Ícone
        Container(
          width: DSSize.width(40),
          height: DSSize.width(40),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DSSize.width(8)),
          ),
          child: Icon(
            icon,
            size: DSSize.width(20),
            color: color,
          ),
        ),

        SizedBox(width: DSSize.width(16)),

        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: DSSize.height(2)),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

