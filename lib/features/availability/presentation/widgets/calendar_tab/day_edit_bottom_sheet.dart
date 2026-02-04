import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/availability/time_slot_entity.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/options_modal.dart';
import 'package:app/features/availability/presentation/widgets/calendar_tab/edit_address_radius_modal.dart';
import 'package:app/features/availability/presentation/widgets/calendar_tab/edit_slot_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Enum para ações do slot
enum SlotAction { edit, delete }

/// Bottom sheet de edição de dia
/// 
/// Exibe disponibilidades reais e permite edição
class DayEditBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final AvailabilityDayEntity? availability; // Disponibilidade do dia (pode ser null)
  final VoidCallback onClose;
  final Function(bool isActive)? onToggleStatus; // Callback para ativar/desativar
  final VoidCallback? onAddAvailability; // Callback para adicionar disponibilidade ao dia
  final Function(AddressInfoEntity address, double radius)? onUpdateAddressRadius; // Callback para atualizar endereço e raio
  final Function(String startTime, String endTime, double pricePerHour)? onAddSlot; // Callback para adicionar slot
  final Function(String slotId, String? startTime, String? endTime, double? pricePerHour)? onUpdateSlot; // Callback para atualizar slot
  final Function(String slotId)? onDeleteSlot; // Callback para deletar slot

  const DayEditBottomSheet({
    super.key,
    required this.selectedDate,
    this.availability,
    required this.onClose,
    this.onToggleStatus,
    this.onAddAvailability,
    this.onUpdateAddressRadius,
    this.onAddSlot,
    this.onUpdateSlot,
    this.onDeleteSlot,
  });

  @override
  State<DayEditBottomSheet> createState() => _DayEditBottomSheetState();
}

class _DayEditBottomSheetState extends State<DayEditBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  /// Verifica se o dia tem disponibilidade ativa
  bool get _hasAvailability => widget.availability != null;
  
  /// Verifica se a disponibilidade está ativa
  bool get _isActive => widget.availability?.isActive ?? false;
  
  /// Obtém a lista de slots de disponibilidade
  List<dynamic> get _availabilitySlots => 
      widget.availability?.slots ?? [];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: DSSize.height(12)),
            width: DSSize.width(40),
            height: DSSize.height(4),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DSSize.width(2)),
            ),
          ),
          
          SizedBox(height: DSSize.height(24)),
          
          // Header com data, TabBar e botão fechar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(20)),
            child: Row(
              children: [
                // Badge de data
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSize.width(16),
                    vertical: DSSize.height(8),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(DSSize.width(20)),
                  ),
                  child: Text(
                    DateFormat('d \'de\' MMMM', 'pt_BR').format(widget.selectedDate),
                    style: TextStyle(
                      fontSize: calculateFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primaryContainer,
                    ),
                  ),
                ),
                
                SizedBox(width: DSSize.width(12)),
                
                // TabBar (centralizada na row)
                Expanded(
                  child: Container(
                    height: DSSize.height(32),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(DSSize.width(25)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: colorScheme.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(DSSize.width(25)),
                      ),
                      labelColor: colorScheme.primaryContainer,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Disponibilidade'),
                        Tab(text: 'Shows'),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          
          SizedBox(height: DSSize.height(16)),

          // Layout: Card Disponível (esquerda) + TabBarView (direita)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(20)),
            child: SizedBox(
              height: DSSize.height(280),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de toggle disponível (esquerda)
                  _buildAvailabilityToggleCard(colorScheme),
                  
                  SizedBox(width: DSSize.width(12)),
                  
                  // TabBarView (direita) - alterna entre cards
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Disponibilidade
                        _buildAvailabilityCard(colorScheme),
                          
                        // Tab 2: Shows
                        _buildShowsCard(colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: DSSize.height(24)),
        ],
      ),
    );
  }

  /// Card de toggle Disponível/Indisponível (esquerda)
  Widget _buildAvailabilityToggleCard(ColorScheme colorScheme) {
    return Container(
      width: DSSize.width(120),
      constraints: BoxConstraints(
        maxHeight: DSSize.height(280),
      ),
      padding: EdgeInsets.all(DSSize.width(12)),
      decoration: BoxDecoration(
        color: colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header com título e bolinha
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Disponível',
                      style: TextStyle(
                        fontSize: calculateFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: DSSize.width(4)),
                  Container(
                    width: DSSize.width(6),
                    height: DSSize.width(6),
                    decoration: BoxDecoration(
                      color: colorScheme.onSecondaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),
          
          // Switch customizado com ícones
          Center(
            child: GestureDetector(
              onTap: () => widget.onToggleStatus?.call(!_isActive),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: DSSize.width(80),
                height: DSSize.height(36),
                padding: EdgeInsets.all(DSSize.width(2)),
                decoration: BoxDecoration(
                  color: _isActive 
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.error.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(DSSize.width(18)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ícones de fundo (X e ✓) - centralizados
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Icon(
                            Icons.close,
                            size: DSSize.width(16),
                            color: _isActive
                                ? colorScheme.primaryContainer.withOpacity(0.5)
                                : colorScheme.error,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.check,
                            size: DSSize.width(16),
                            color: _isActive
                                ? colorScheme.primaryContainer
                                : colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    // Thumb (bolinha) animada
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _isActive 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: Container(
                        width: DSSize.width(32),
                        height: DSSize.height(32),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isActive ? Icons.check : Icons.close,
                            size: DSSize.width(18),
                            color: _isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card de Disponibilidade (endereço + raio + slots)
  Widget _buildAvailabilityCard(ColorScheme colorScheme) {
    // Se não tem disponibilidade, mostrar mensagem
    if (!_hasAvailability || _availabilitySlots.isEmpty) {
      return _buildEmptyAvailabilityCard(colorScheme);
    }
    
    // Acessar propriedades diretamente do AvailabilityDayEntity
    final availability = widget.availability!;
    final address = availability.endereco?.title.isNotEmpty ?? false 
        ? availability.endereco?.title 
        : (availability.endereco?.street ?? 'Sem endereço');
    final radius = availability.raioAtuacao;
    final slots = availability.slots;

    return Container(
      padding: EdgeInsets.all(DSSize.width(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Endereço + Raio + Ícone de edição
            Row(
              children: [
                // Endereço
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: DSSize.width(18),
                            color: colorScheme.onPrimaryContainer,
                          ),
                          SizedBox(width: DSSize.width(6)),
                          Flexible(
                            child: Text(
                              address ?? 'Sem endereço',
                              style: TextStyle(
                                fontSize: calculateFontSize(15),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Raio
                          Icon(
                            Icons.radio_button_checked,
                            size: DSSize.width(18),
                            color: colorScheme.onTertiaryContainer,
                          ),
                          SizedBox(width: DSSize.width(4)),
                          Text(
                            '${radius?.toStringAsFixed(0) ?? '0'} km',
                            style: TextStyle(
                              fontSize: calculateFontSize(12),
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Ícone de edição
                GestureDetector(
                  onTap: () async {
                    final result = await EditAddressRadiusModal.show(
                      context: context,
                      initialAddress: availability.endereco,
                      initialRadius: radius ?? 0,
                    );

                    if (result != null && widget.onUpdateAddressRadius != null) {
                      widget.onUpdateAddressRadius!(
                        result['address'] as AddressInfoEntity,
                        result['radiusKm'] as double,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(DSSize.width(4)),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: DSSize.width(16),
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: DSSize.height(12)),
            
            // Divider
            Divider(
              color: colorScheme.outline.withOpacity(0.2),
              thickness: 1,
            ),
            
            SizedBox(height: DSSize.height(8)),
            
            // Lista de slots (dados reais) - ordenados por horário de início
            if (slots?.isNotEmpty ?? false)
              ..._sortSlotsByStartTime(slots!).map((slot) => Padding(
                padding: EdgeInsets.only(bottom: DSSize.height(8)),
                child: _buildTimeSlotCard(
                  colorScheme,
                  slotId: slot.slotId,
                  startTime: slot.startTime,
                  endTime: slot.endTime,
                  price: slot.valorHora ?? 0.0,
                ),
              )),
            
            // Mensagem se não há slots
            if (slots?.isEmpty ?? true)
              Padding(
                padding: EdgeInsets.symmetric(vertical: DSSize.height(16)),
                child: Center(
                  child: Text(
                    'Nenhum horário cadastrado',
                    style: TextStyle(
                      fontSize: calculateFontSize(13),
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            
            // Botão de adicionar novo slot
            SizedBox(height: DSSize.height(8)),
            _buildAddSlotButton(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Exibe o modal de opções do slot (Editar/Excluir)
  Future<void> _showSlotOptionsModal({
    required String slotId,
    required String startTime,
    required String endTime,
    required double price,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onError = colorScheme.onError;
    final error = colorScheme.error;
    await OptionsModal.show(
      context: context,
      title: 'Opções',
      actions: [
        OptionsModalAction(label: 'Editar', icon: Icons.edit, onPressed: () => _showEditSlotModal(context, slotId, startTime, endTime, price)),
        OptionsModalAction(label: 'Excluir', icon: Icons.delete, backgroundColor: error, textColor: onError, iconColor: onError, onPressed: () => _showDeleteSlotModal(context, slotId, startTime, endTime, price)),
      ],
    );
  }

  Future<void> _showEditSlotModal(BuildContext context, String slotId, String startTime, String endTime, double price) async {    // Abrir modal de edição
      final result = await EditSlotModal.show(
        context: context,
        startTime: startTime,
        endTime: endTime,
        pricePerHour: price,
      );

      if (result != null && widget.onUpdateSlot != null) {
        widget.onUpdateSlot!(
          slotId,
          result['startTime'] as String?,
          result['endTime'] as String?,
          result['pricePerHour'] as double?,
        );
      }
  }


  Future<void> _showDeleteSlotModal(BuildContext context, String slotId, String startTime, String endTime, double price) async {
    final confirmed = await ConfirmationDialog.show(
            context: context,
            title: 'Confirmar exclusão',
            message: 'Deseja realmente excluir o horário $startTime - $endTime?',
            confirmText: 'Excluir',
            cancelText: 'Cancelar',
            confirmButtonColor: Theme.of(context).colorScheme.error,
            confirmButtonTextColor: Theme.of(context).colorScheme.onError,
          );

      // Só excluir se o usuário confirmou
      if (confirmed == true && widget.onDeleteSlot != null) {
        widget.onDeleteSlot!(slotId);
      }
    }

  /// Botão de adicionar novo slot
  Widget _buildAddSlotButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () async {
        final result = await EditSlotModal.show(
          context: context,
          // Sem parâmetros = modo criar
        );

        if (result != null && widget.onAddSlot != null) {
          widget.onAddSlot!(
            result['startTime'] as String,
            result['endTime'] as String,
            result['pricePerHour'] as double,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: DSSize.height(12),
          horizontal: DSSize.width(10),
        ),
        decoration: BoxDecoration(
          color: colorScheme.onPrimaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DSSize.width(10)),
          border: Border.all(
            color: colorScheme.onPrimaryContainer.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: DSSize.width(18),
              color: colorScheme.onPrimaryContainer,
            ),
            SizedBox(width: DSSize.width(8)),
            Text(
              'Adicionar horário',
              style: TextStyle(
                fontSize: calculateFontSize(13),
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de slot de tempo
  Widget _buildTimeSlotCard(
    ColorScheme colorScheme, {
    required String slotId,
    required String startTime,
    required String endTime,
    required double price,
  }) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(DSSize.width(10)),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DSSize.width(10)),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Ícone de horário
              Container(
                padding: EdgeInsets.all(DSSize.width(6)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: DSSize.width(14),
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              
              SizedBox(width: DSSize.width(10)),
              
              // Horário e preço
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Horário
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: calculateFontSize(13),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    
                    SizedBox(height: DSSize.height(2)),
                    
                    // Preço
                    Text(
                      'R\$ ${price.toStringAsFixed(0)}/h',
                      style: TextStyle(
                        fontSize: calculateFontSize(12),
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Espaço para o ícone de edição
              SizedBox(width: DSSize.width(28)),
            ],
          ),
        ),
        
        // Menu de opções (3 pontinhos) no canto superior direito
        Positioned(
          top: DSSize.height(6),
          right: DSSize.width(6),
          child: GestureDetector(
            onTap: () => _showSlotOptionsModal(
              slotId: slotId,
              startTime: startTime,
              endTime: endTime,
              price: price,
            ),
            child: Container(
              padding: EdgeInsets.all(DSSize.width(6)),
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_vert,
                size: DSSize.width(16),
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Card vazio quando não há disponibilidade
  Widget _buildEmptyAvailabilityCard(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(DSSize.width(24)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: DSSize.width(48),
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: DSSize.height(16)),
            Text(
              'Sem disponibilidade',
              style: TextStyle(
                fontSize: calculateFontSize(16),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: DSSize.height(8)),
            Text(
              'Adicione disponibilidade para este dia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: calculateFontSize(13),
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            
            // Botão para adicionar disponibilidade
            DSSizedBoxSpacing.vertical(16),
            GestureDetector(
              onTap: widget.onAddAvailability,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DSSize.width(20),
                  vertical: DSSize.height(12),
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(DSSize.width(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: DSSize.width(16),
                      color: colorScheme.primaryContainer,
                    ),
                    DSSizedBoxSpacing.horizontal(8),
                    Text(
                      'Adicionar',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de Shows
  Widget _buildShowsCard(ColorScheme colorScheme) {

    // Dados mockados
    final mockShows = [
      {
        'eventType': 'Casamento',
        'hostName': 'João Silva',
        'neighborhood': 'Centro',
        'totalValue': 1500.0,
      },
      {
        'eventType': 'Aniversário',
        'hostName': 'Maria Santos',
        'neighborhood': 'Zona Sul',
        'totalValue': 2000.0,
      },
      {
        'eventType': 'Corporativo',
        'hostName': 'Tech Corp',
        'neighborhood': 'Barra',
        'totalValue': 3500.0,
      },
    ];

    return Container(
      padding: EdgeInsets.all(DSSize.width(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: mockShows.map((show) {
            return Padding(
              padding: EdgeInsets.only(bottom: DSSize.height(8)),
              child: _buildShowCard(
                colorScheme,
                eventType: show['eventType'] as String,
                hostName: show['hostName'] as String,
                neighborhood: show['neighborhood'] as String,
                totalValue: show['totalValue'] as double,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShowCard(
    ColorScheme colorScheme, {
    required String eventType,
    required String hostName,
    required String neighborhood,
    required double totalValue,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navegar para tela do show
      },
      child: Container(
        padding: EdgeInsets.all(DSSize.width(10)),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(DSSize.width(10)),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tipo de evento
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: DSSize.width(16),
                  color: Colors.amber.shade600,
                ),
                SizedBox(width: DSSize.width(6)),
                Text(
                  eventType,
                  style: TextStyle(
                    fontSize: calculateFontSize(13),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: DSSize.height(8)),
            
            // Nome do anfitrião
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: DSSize.width(14),
                  color: colorScheme.onPrimaryContainer,
                ),
                SizedBox(width: DSSize.width(6)),
                Expanded(
                  child: Text(
                    hostName,
                    style: TextStyle(
                      fontSize: calculateFontSize(12),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: DSSize.height(6)),
            
            // Bairro
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: DSSize.width(14),
                  color: Colors.red.shade400,
                ),
                SizedBox(width: DSSize.width(6)),
                Text(
                  neighborhood,
                  style: TextStyle(
                    fontSize: calculateFontSize(11),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: DSSize.height(8)),
            
            // Valor total (destaque)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DSSize.width(8),
                vertical: DSSize.height(4),
              ),
              decoration: BoxDecoration(
                color: colorScheme.onSecondaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DSSize.width(6)),
              ),
              child: Text(
                'R\$ ${totalValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: calculateFontSize(13),
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ordena slots por horário de início (startTime)
  List<TimeSlot> _sortSlotsByStartTime(List<TimeSlot> slots) {
    final sorted = List<TimeSlot>.from(slots);
    sorted.sort((a, b) {
      // Comparar horários no formato "HH:mm"
      final aParts = a.startTime.split(':');
      final bParts = b.startTime.split(':');
      final aMinutes = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bMinutes = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return aMinutes.compareTo(bMinutes);
    });
    return sorted;
  }
}
