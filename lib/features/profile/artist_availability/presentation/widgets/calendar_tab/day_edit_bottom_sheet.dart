import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/edit_address_radius_modal.dart';
import 'package:app/features/profile/artist_availability/presentation/widgets/calendar_tab/edit_slot_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet de edição de dia (estilo Airbnb)
/// 
/// UI mockada baseada nas imagens fornecidas
class DayEditBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onClose;

  const DayEditBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onClose,
  });

  @override
  State<DayEditBottomSheet> createState() => _DayEditBottomSheetState();
}

class _DayEditBottomSheetState extends State<DayEditBottomSheet> with SingleTickerProviderStateMixin {
  bool _isAvailable = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
              onTap: () {
                setState(() {
                  _isAvailable = !_isAvailable;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: DSSize.width(80),
                height: DSSize.height(36),
                padding: EdgeInsets.all(DSSize.width(2)),
                decoration: BoxDecoration(
                  color: _isAvailable 
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
                            color: _isAvailable
                                ? colorScheme.primaryContainer.withOpacity(0.5)
                                : colorScheme.error,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.check,
                            size: DSSize.width(16),
                            color: _isAvailable
                                ? colorScheme.primaryContainer
                                : colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    // Thumb (bolinha) animada
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _isAvailable 
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
                            _isAvailable ? Icons.check : Icons.close,
                            size: DSSize.width(18),
                            color: _isAvailable
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
    // Dados mockados
    final mockAddress = 'Centro';
    final mockRadius = 5.0;
    final mockSlots = [
      {'startTime': '09:00', 'endTime': '12:00', 'price': 150.0},
      {'startTime': '14:00', 'endTime': '18:00', 'price': 200.0},
      {'startTime': '19:00', 'endTime': '23:00', 'price': 250.0},
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Endereço + Raio + Ícone de edição
            Row(
              children: [
                // Endereço
                Icon(
                  Icons.location_on,
                  size: DSSize.width(18),
                  color: colorScheme.onPrimaryContainer,
                ),
                SizedBox(width: DSSize.width(6)),
                Text(
                  mockAddress,
                  style: TextStyle(
                    fontSize: calculateFontSize(15),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                SizedBox(width: DSSize.width(12)),
                
                // Raio
                Icon(
                  Icons.radio_button_checked,
                  size: DSSize.width(14),
                  color: colorScheme.onTertiaryContainer,
                ),
                SizedBox(width: DSSize.width(4)),
                Text(
                  '${mockRadius.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: calculateFontSize(12),
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const Spacer(),
                
                // Ícone de edição
                GestureDetector(
                  onTap: () async {
                    // Mock de endereço atual (substituir por dados reais)
                    final currentAddress = AddressInfoEntity(
                      uid: '1',
                      title: mockAddress,
                      zipCode: '01000-000',
                      street: 'Rua Exemplo',
                      number: '123',
                      district: 'Centro',
                      city: 'São Paulo',
                      state: 'SP',
                      latitude: -23.550520,
                      longitude: -46.633308,
                      isPrimary: false,
                    );

                    final result = await EditAddressRadiusModal.show(
                      context: context,
                      initialAddress: currentAddress,
                      initialRadius: mockRadius,
                    );

                    if (result != null) {
                      // TODO: Atualizar o endereço e raio com os novos dados
                      print('Endereço atualizado:');
                      print('  Endereço: ${result['address'].title}');
                      print('  Raio: ${result['radiusKm']} km');
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
            
            // Lista de slots
            ...mockSlots.map((slot) => Padding(
              padding: EdgeInsets.only(bottom: DSSize.height(8)),
              child: _buildTimeSlotCard(
                colorScheme,
                startTime: slot['startTime'] as String,
                endTime: slot['endTime'] as String,
                price: slot['price'] as double,
              ),
            )),
            
            // Botão de adicionar novo slot
            SizedBox(height: DSSize.height(8)),
            _buildAddSlotButton(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Botão de adicionar novo slot
  Widget _buildAddSlotButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () async {
        final result = await EditSlotModal.show(
          context: context,
          // Sem parâmetros = modo criar
        );

        if (result != null) {
          // TODO: Adicionar novo slot
          print('Novo slot criado:');
          print('  Início: ${result['startTime']}');
          print('  Fim: ${result['endTime']}');
          print('  Valor/h: ${result['pricePerHour']}');
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
                  Icons.access_time,
                  size: DSSize.width(14),
                  color: colorScheme.onPrimaryContainer,
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
        
        // Ícone de edição no canto superior direito
        Positioned(
          top: DSSize.height(6),
          right: DSSize.width(6),
          child: GestureDetector(
            onTap: () async {
              final result = await EditSlotModal.show(
                context: context,
                startTime: startTime,
                endTime: endTime,
                pricePerHour: price,
              );

              if (result != null) {
                // TODO: Atualizar o slot com os novos dados
                print('Slot atualizado:');
                print('  Início: ${result['startTime']}');
                print('  Fim: ${result['endTime']}');
                print('  Valor/h: ${result['pricePerHour']}');
              }
            },
            child: Container(
              padding: EdgeInsets.all(DSSize.width(5)),
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                size: DSSize.width(12),
                color: colorScheme.primaryContainer,
              ),
            ),
          ),
        ),
      ],
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
}
