import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/addresses/presentation/widgets/address_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Modal para seleção de endereços
/// 
/// Exibe lista de endereços e permite selecionar um
class AddressesModal extends StatefulWidget {
  final AddressInfoEntity? selectedAddress;
  final Function(AddressInfoEntity)? onAddressSelected;

  const AddressesModal({
    super.key,
    this.selectedAddress,
    this.onAddressSelected,
  });

  /// Exibe o modal de endereços
  static Future<AddressInfoEntity?> show({
    required BuildContext context,
    AddressInfoEntity? selectedAddress,
  }) {
    return showModalBottomSheet<AddressInfoEntity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressesModal(
        selectedAddress: selectedAddress,
        onAddressSelected: (address) => Navigator.of(context).pop(address),
      ),
    );
  }

  @override
  State<AddressesModal> createState() => _AddressesModalState();
}

class _AddressesModalState extends State<AddressesModal> {
  // Mock data - será substituído por dados reais depois
  List<AddressInfoEntity> _addresses = [
    AddressInfoEntity(
      title: 'Casa',
      zipCode: '01310-100',
      street: 'Avenida Paulista',
      number: '1578',
      district: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      isPrimary: true,
    ),
    AddressInfoEntity(
      title: 'Trabalho',
      zipCode: '04547-130',
      street: 'Rua Funchal',
      number: '263',
      district: 'Vila Olímpia',
      city: 'São Paulo',
      state: 'SP',
      isPrimary: false,
    ),
  ];

  void _deleteAddress(String addressTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Excluir Endereço',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          content: Text('Você realmente deseja excluir o endereço "$addressTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _addresses.removeWhere((addr) => addr.title == addressTitle);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Endereço excluído com sucesso')),
                );
              },
              child: Text(
                'Excluir',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onEditAddress(AddressInfoEntity address) {
    AutoRouter.of(context).push(
      AddressFormRoute(existingAddress: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerHighest = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    // Ordena endereços: principal primeiro
    final sortedAddresses = List<AddressInfoEntity>.from(_addresses);
    sortedAddresses.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return 0;
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSize.width(20)),
          topRight: Radius.circular(DSSize.width(20)),
        ),
      ),
      child: Stack(
        children: [
          // Gradiente transparente no topo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    surfaceContainerHighest,
                    surfaceContainerHighest,
                  ],
                  stops: const [0.0, 0.08, 0.08, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DSSize.width(20)),
                  topRight: Radius.circular(DSSize.width(20)),
                ),
              ),
            ),
          ),
          // Conteúdo do modal com fundo sólido a partir do handle
          DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.8,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(DSSize.width(20)),
                    topRight: Radius.circular(DSSize.width(20)),
                  ),
                ),
                child: Column(
                  children: [
                    // Espaço transparente acima do handle
                    SizedBox(height: DSSize.height(12)),
                    // Handle bar
                    Container(
                      width: DSSize.width(40),
                      height: DSSize.height(4),
                      margin: EdgeInsets.only(
                        bottom: DSSize.height(16),
                      ),
                      decoration: BoxDecoration(
                        color: onPrimary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(DSSize.width(2)),
                      ),
                    ),
                    // Título
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meus Endereços',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: onPrimary,
                                ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: onPrimary),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    // Conteúdo
                    Expanded(
                      child: sortedAddresses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: DSSize.width(80),
                                    color: onPrimaryContainer,
                                  ),
                                  DSSizedBoxSpacing.vertical(16),
                                  Text(
                                    'Você ainda não possui endereços cadastrados.',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                              itemCount: sortedAddresses.length,
                              itemBuilder: (context, index) {
                                final address = sortedAddresses[index];
                                final isSelected = widget.selectedAddress?.title == address.title &&
                                    widget.selectedAddress?.zipCode == address.zipCode;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: DSSize.height(12)),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onAddressSelected?.call(address);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(DSSize.width(8)),
                                      ),
                                      child: AddressCard(
                                        title: address.title,
                                        street: address.street ?? '',
                                        district: address.district ?? '',
                                        number: address.number ?? '',
                                        complement: address.complement,
                                        onEdit: () {
                                          _onEditAddress(address);
                                        },
                                        onDelete: () => _deleteAddress(address.title),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Botão para adicionar novo endereço
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                    child: CustomButton(
                      label: 'Adicionar Endereço',
                      onPressed: () {
                        AutoRouter.of(context).push(
                          AddressFormRoute(),
                        );
                      },
                      icon: Icons.add,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(64),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

