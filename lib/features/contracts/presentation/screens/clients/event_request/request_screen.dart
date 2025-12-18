import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_date_picker_dialog.dart';
import 'package:app/core/shared/widgets/info_row.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/core/shared/widgets/wheel_picker_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage(deferredLoading: true)
class RequestScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedAddress;
  final ArtistEntity artist;
  final double pricePerHour;
  final Duration minimumDuration;

  const RequestScreen({
    super.key,
    required this.selectedDate,
    required this.selectedAddress,
    required this.artist,
    required this.pricePerHour,
    required this.minimumDuration,
  });

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _eventTypeController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration? _selectedDuration;
  bool _hasAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDuration = widget.minimumDuration;
    _durationController.text = _formatDuration(widget.minimumDuration);
  }

  @override
  void dispose() {
    _eventTypeController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hoje';
    } else if (selectedDay == tomorrow) {
      return 'Amanhã';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  double get _totalValue {
    if (_selectedDuration == null) return 0.0;
    final hours = _selectedDuration!.inHours + (_selectedDuration!.inMinutes / 60);
    return hours * widget.pricePerHour;
  }

  Future<void> _selectEventType() async {
    final router = AutoRouter.of(context);
    final result = await router.push<String>(
      EventTypeSelectionRoute(
        eventTypes: [
          'Aniversário',
          'Casamento',
          'Evento Corporativo',
          'Festa',
          'Show',
          'Outro',
        ],
        selectedEventType: _eventTypeController.text.isEmpty
            ? null
            : _eventTypeController.text,
        onEventTypeSelected: (value) {
          // Callback será chamado quando o tipo for selecionado
        },
      ),
    );

    if (result != null) {
      setState(() {
        _eventTypeController.text = result;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await CustomDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final currentTime = _selectedTime ?? TimeOfDay.now();
    final hours = currentTime.hour;
    final minutes = currentTime.minute;

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione o horário',
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.time,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTime = result;
        _timeController.text = '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectDuration() async {
    final hours = _selectedDuration?.inHours ?? 0;
    final minutes = (_selectedDuration?.inMinutes ?? 0) % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => WheelPickerDialog(
        title: 'Selecione a duração',
        initialHours: hours,
        initialMinutes: minutes,
        type: WheelPickerType.duration,
        minimumDuration: widget.minimumDuration,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDuration = result;
        _durationController.text = _formatDuration(result);
      });
    }
  }

  String? _validateForm() {
    if (_eventTypeController.text.isEmpty) {
      return 'Selecione o tipo de evento';
    }
    if (_selectedDate == null) {
      return 'Selecione a data';
    }
    if (_timeController.text.isEmpty) {
      return 'Selecione o horário';
    }
    if (_durationController.text.isEmpty) {
      return 'Selecione a duração';
    }
    return null;
  }

  void _onSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
    });
    
    final error = _validateForm();
    if (error == null) {
      // TODO: Implementar envio da solicitação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso!')),
      );
      AutoRouter.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Nova Solicitação',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSSizedBoxSpacing.vertical(16),
            
            // Cabeçalho: Solicitando para
            Text(
              'Artista: ${widget.artist.artistName}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: onPrimary,
              ),
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Endereço (fixo)
            InfoRow(
              label: 'Endereço',
              value: widget.selectedAddress,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Separador
            Divider(
              color: onSurfaceVariant.withOpacity(0.2),
              thickness: 1,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Data
            SelectableRow(
              label: 'Data',
              value: _selectedDate != null ? _formatDate(_selectedDate!) : '',
              onTap: _selectDate,
              errorMessage: _hasAttemptedSubmit && _selectedDate == null ? 'Selecione a data' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Horário de início
            SelectableRow(
              label: 'Horário de início',
              value: _timeController.text,
              onTap: _selectTime,
              errorMessage: _hasAttemptedSubmit && _timeController.text.isEmpty ? 'Selecione o horário' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Duração
            SelectableRow(
              label: 'Duração',
              value: _durationController.text,
              onTap: _selectDuration,
              errorMessage: _hasAttemptedSubmit && _durationController.text.isEmpty ? 'Selecione a duração' : null,
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Tipo de evento
            SelectableRow(
              label: 'Tipo de evento',
              value: _eventTypeController.text,
              onTap: _selectEventType,
              errorMessage: _hasAttemptedSubmit && _eventTypeController.text.isEmpty ? 'Selecione o tipo de evento' : null,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Separador
            Divider(
              color: onSurfaceVariant.withOpacity(0.2),
              thickness: 1,
            ),
            
            DSSizedBoxSpacing.vertical(24),
            
            // Valor/h (fixo)
            InfoRow(
              label: 'Valor/h',
              value: 'R\$ ${widget.pricePerHour.toStringAsFixed(2)}',
            ),
            
            DSSizedBoxSpacing.vertical(16),
            
            // Total (calculado)
            InfoRow(
              label: 'Total',
              value: 'R\$ ${_totalValue.toStringAsFixed(2)}',
              isHighlighted: true,
              highlightColor: colorScheme.onPrimaryContainer,
            ),
            
            DSSizedBoxSpacing.vertical(32),
            
            // Botão de envio
            CustomButton(
              label: 'Solicitar Apresentação',
              onPressed: _onSubmit,
              icon: Icons.send,
              iconOnLeft: true,

            ),
            
            DSSizedBoxSpacing.vertical(24),
          ],
        ),
      ),
    );
  }
}





