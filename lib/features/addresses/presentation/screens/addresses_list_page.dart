import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/features/addresses/presentation/widgets/address_card.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class AddressesListPage extends StatefulWidget {
  const AddressesListPage({super.key});

  @override
  AddressesListPageState createState() => AddressesListPageState();
}

class AddressesListPageState extends State<AddressesListPage> {
  // Mock data
  List<AddressInfoEntity> _addresses = [];


  void _deleteAddress(String addressTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir Endereço', style: Theme.of(context).textTheme.titleMedium),
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
                context.showSuccess('Endereço excluído com sucesso');
              },
              child: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    
    // Ordena endereços: principal primeiro
    final sortedAddresses = List<AddressInfoEntity>.from(_addresses);
    sortedAddresses.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return 0;
    });

    if (sortedAddresses.isEmpty) {
      return BasePage(
        showAppBar: true,
        appBarTitle: 'Meus Endereços',
        showAppBarBackButton: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: DSSize.width(80), color: onPrimaryContainer),
              DSSizedBoxSpacing.vertical(16),
              Text(
                'Você ainda não possui endereços cadastrados.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              DSSizedBoxSpacing.vertical(140),
              CustomButton(
                label: 'Adicionar Endereço',
                onPressed: () {
                  AutoRouter.of(context).push(
                     AddressFormRoute(),
                  );
                },
                icon: Icons.add,
              ),
            ],
          ),
        ),
      );
    }

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Meus Endereços',
      showAppBarBackButton: true,
      child: Column(
        children: [
          DSSizedBoxSpacing.vertical(16),
          // Lista de endereços
          Expanded(
            child: sortedAddresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: DSSize.width(64),
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        DSSizedBoxSpacing.vertical(16),
                        Text(
                          'Você ainda não possui endereços cadastrados',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedAddresses.length,
                    itemBuilder: (context, index) {
                      final address = sortedAddresses[index];
                      return AddressCard(
                        title: address.title,
                        street: address.street ?? '',
                        district: address.district ?? '',
                        number: address.number ?? '',
                        complement: address.complement,
                        onEdit: () {
                          _onEditAddress(address);
                        },
                        onDelete: () => _deleteAddress(address.title),
                      );
                    },
                  ),
          ),
          DSSizedBoxSpacing.vertical(16),
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
          DSSizedBoxSpacing.vertical(16),
        ],
      ),
    );
  }
}

