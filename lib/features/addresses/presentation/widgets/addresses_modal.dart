import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:app/core/shared/widgets/confirmation_dialog.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:app/features/addresses/presentation/widgets/address_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  List<AddressInfoEntity> _addresses = [];

  @override
  void initState() {
    super.initState();
    context.read<AddressesBloc>().add(GetAddressesEvent());
  }

  void _deleteAddress(AddressInfoEntity address) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Excluir Endereço',
          message: 'Você realmente deseja excluir o endereço "${address.title}"?',
          confirmText: 'Excluir',
          cancelText: 'Cancelar',
          confirmButtonColor: Theme.of(context).colorScheme.error,
          onConfirm: () {
            Navigator.of(context).pop();
            if (address.uid != null) {
              context.read<AddressesBloc>().add(
                DeleteAddressEvent(addressId: address.uid!),
              );
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _onEditAddress(AddressInfoEntity address) {
    AutoRouter.of(context).push(
      AddressFormRoute(existingAddress: address),
    );
  }

  void _onAddressSelected(AddressInfoEntity address) {
    if (address.uid != null) {
      if (!address.isPrimary) {
        context.read<AddressesBloc>().add(
          SetPrimaryAddressEvent(addressId: address.uid!),
        );
      }
      widget.onAddressSelected?.call(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return BlocListener<AddressesBloc, AddressesState>(
      listener: (context, state) {
        if (state is GetAddressesSuccess) {
          setState(() {
            _addresses = state.addresses;
          });
        } else if (state is AddAddressSuccess) {
          // Recarrega endereços após adicionar
          context.read<AddressesBloc>().add(GetAddressesEvent());
          context.showSuccess('Endereço adicionado com sucesso');
        } else if (state is UpdateAddressSuccess) {
          // Recarrega endereços após atualizar
          context.read<AddressesBloc>().add(GetAddressesEvent());
          context.showSuccess('Endereço atualizado com sucesso');
        } else if (state is SetPrimaryAddressSuccess) {
          // Recarrega endereços após definir primário
          context.read<AddressesBloc>().add(GetAddressesEvent());
          context.showSuccess('Endereço principal atualizado com sucesso');
        } else if (state is DeleteAddressSuccess) {
          // Recarrega endereços após deletar
          context.read<AddressesBloc>().add(GetAddressesEvent());
          context.showSuccess('Endereço excluído com sucesso');
        } else if (state is GetAddressesFailure) {
          context.showError(state.error);
        } else if (state is AddAddressFailure) {
          context.showError(state.error);
        } else if (state is UpdateAddressFailure) {
          context.showError(state.error);
        } else if (state is SetPrimaryAddressFailure) {
          context.showError(state.error);
        } else if (state is DeleteAddressFailure) {
          context.showError(state.error);
        }
      },
        child: BlocBuilder<AddressesBloc, AddressesState>(
          builder: (context, state) {
            // Ordena endereços: principal primeiro
            final sortedAddresses = List<AddressInfoEntity>.from(_addresses);
            sortedAddresses.sort((a, b) {
              if (a.isPrimary && !b.isPrimary) return -1;
              if (!a.isPrimary && b.isPrimary) return 1;
              return 0;
            });

            return Stack(
              children: [
                // Gradiente transparente no topo
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           Colors.transparent,
                //           Colors.transparent,
                //           surface,
                //           surface,
                //         ],
                //         stops: const [0.0, 0.08, 0.08, 1.0],
                //       ),
                //       borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(DSSize.width(20)),
                //         topRight: Radius.circular(DSSize.width(20)),
                //       ),
                //     ),
                //   ),
                // ),
                // Conteúdo do modal com fundo sólido a partir do handle
                DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.8,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(DSSize.width(20)),
                          topRight: Radius.circular(DSSize.width(20)),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Espaço transparente acima do handle
                          SizedBox(height: DSSize.height(8)),
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
                            child: state is GetAddressesLoading
                                ? const Center(child: CustomLoadingIndicator())
                                : sortedAddresses.isEmpty
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
                                          final isSelected = address.isPrimary;

                                          return Padding(
                                            padding: EdgeInsets.only(bottom: DSSize.height(12)),
                                            child: GestureDetector(
                                              onTap: () {
                                                _onAddressSelected(address);
                                              },
                                              child: AddressCard(
                                                title: address.title,
                                                street: address.street ?? '',
                                                district: address.district ?? '',
                                                number: address.number ?? '',
                                                complement: address.complement,
                                                isSelected: isSelected,
                                                onEdit: () {
                                                  _onEditAddress(address);
                                                },
                                                onDelete: () => _deleteAddress(address),
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
            
          );
        },
      ),
    );
  }
}

