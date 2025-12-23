import 'dart:async';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/services/cep_service.dart';
import 'package:app/core/config/setup_locator.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.existingAddress});
  final AddressInfoEntity? existingAddress;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController? complementController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  double latitude = 0.0;
  double longitude = 0.0;

  
  AddressInfoEntity? existingAddress;
  bool isLoadingCep = false;
  String? _currentUserId;
  final ICepService _cepService = getIt<ICepService>();
  Timer? _debounceTimer;
  String? _lastSearchedCep; // Armazena o último CEP buscado com sucesso

  @override
  void initState() {
    super.initState();
    
    // Se recebeu existingAddress com uid, busca o endereço via BLoC
    if (widget.existingAddress?.uid != null) {
      context.read<AddressesBloc>().add(
        GetAddressEvent(
          addressId: widget.existingAddress!.uid!,
        ),
      );
    } else if (widget.existingAddress != null) {
      // Se recebeu existingAddress sem uid, usa diretamente (caso legado)
      _populateForm(widget.existingAddress!);
    }
    
    // Listener para busca automática quando CEP tiver 8 dígitos
    zipController.addListener(_onCepChanged);
  }

  void _populateForm(AddressInfoEntity address) {
    existingAddress = address;
    titleController.text = address.title;
    zipController.text = address.zipCode;
    streetController.text = address.street ?? '';
    numberController.text = address.number ?? '';
    complementController?.text = address.complement ?? '';
    districtController.text = address.district ?? '';
    cityController.text = address.city ?? '';
    stateController.text = address.state ?? '';
    latitude = address.latitude ?? 0.0;
    longitude = address.longitude ?? 0.0;
    // Marca o CEP existente como já buscado para evitar busca automática
    _lastSearchedCep = address.zipCode.replaceAll(RegExp(r'[^\d]'), '');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    zipController.removeListener(_onCepChanged);
    super.dispose();
  }

  void _onCepChanged() {
    // Se estiver carregando, não faz nada
    if (isLoadingCep) return;
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final cleanCep = zipController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      // Só busca se:
      // 1. CEP tiver 8 dígitos
      // 2. Não estiver carregando
      // 3. O CEP for diferente do último buscado (evita loop)
      if (cleanCep.length == 8 && 
          !isLoadingCep && 
          cleanCep != _lastSearchedCep) {
        _locateAddressByCep();
      }
    });
  }

  Future<void> _locateAddressByCep() async {
    final zipCode = zipController.text.trim();
    final cleanCep = zipCode.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanCep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP')),
      );
      return;
    }

    if (cleanCep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP deve conter 8 dígitos')),
      );
      return;
    }

    setState(() {
      isLoadingCep = true;
    });

    try {
      final cepInfo = await _cepService.getAddressByCep(cleanCep);
      
      // Remove listener temporariamente para evitar loop ao atualizar o campo
      zipController.removeListener(_onCepChanged);
      
      setState(() {
        streetController.text = cepInfo.street ?? '';
        districtController.text = cepInfo.district ?? '';
        cityController.text = cepInfo.city ?? '';
        stateController.text = cepInfo.state ?? '';
        zipController.text = cepInfo.cep; // CEP formatado retornado pela API
        isLoadingCep = false;
        _lastSearchedCep = cleanCep; // Marca este CEP como já buscado
      });
      
      // Re-adiciona o listener após atualizar o campo
      zipController.addListener(_onCepChanged);
    } catch (e) {
      setState(() {
        isLoadingCep = false;
        // Em caso de erro, não marca como buscado, permitindo nova tentativa
      });
      
      if (mounted) {
        context.showError(
          e.toString().replaceAll('ServerException: ', ''),
        );
      }
    }
  }

  void _handleSave() {
    if (titleController.text.trim().isEmpty) {
      context.showError('Por favor, informe um título para o endereço');
      return;
    }

    if (zipController.text.trim().isEmpty) {
      context.showError('Por favor, informe o CEP');
      return;
    }

    if (numberController.text.trim().isEmpty) {
      context.showError('Por favor, informe o número');
      return;
    }

    final address = AddressInfoEntity(
      uid: existingAddress?.uid,
      title: titleController.text.trim(),
      zipCode: zipController.text.trim(),
      street: streetController.text.trim().isEmpty ? null : streetController.text.trim(),
      number: numberController.text.trim(),
      complement: complementController?.text.trim().isEmpty ?? true
          ? null
          : complementController?.text.trim(),
      district: districtController.text.trim().isEmpty ? null : districtController.text.trim(),
      city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
      state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      isPrimary: existingAddress?.isPrimary ?? false,
    );

    if (existingAddress?.uid != null && existingAddress!.uid!.isNotEmpty) {
      // Atualizar endereço existente
      context.read<AddressesBloc>().add(
        UpdateAddressEvent(
          addressId: existingAddress!.uid!,
          address: address,
        ),
      );
    } else {
      // Adicionar novo endereço
      context.read<AddressesBloc>().add(
        AddAddressEvent(
          address: address,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressesBloc, AddressesState>(
      listener: (context, state) {
        if (state is GetAddressSuccess) {
          _populateForm(state.address);
        } else if (state is GetAddressFailure) {
          context.showError(state.error);
        } else if (state is AddAddressSuccess) {
          context.showSuccess('Endereço adicionado com sucesso');
          Navigator.of(context).pop();
        } else if (state is AddAddressFailure) {
          context.showError(state.error);
        } else if (state is UpdateAddressSuccess) {
          context.showSuccess('Endereço atualizado com sucesso');
          Navigator.of(context).pop();
        } else if (state is UpdateAddressFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<AddressesBloc, AddressesState>(
        builder: (context, state) {
          final isLoading = state is GetAddressLoading ||
              state is AddAddressLoading ||
              state is UpdateAddressLoading;

          return BasePage(
            showAppBar: true,
            appBarTitle: existingAddress == null ? 'Adicionar Endereço' : 'Editar Endereço',
            showAppBarBackButton: true,
            child: state is GetAddressLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Título',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    CustomTextField(
                      controller: titleController,
                      label: 'Título do endereço',
                    ),
                    DSSizedBoxSpacing.vertical(24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Endereço',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: zipController,
                            label: 'CEP',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        if (isLoadingCep) ...[
                          DSSizedBoxSpacing.horizontal(8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Digite o CEP. Os demais campos serão preenchidos automaticamente.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.start,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    CustomTextField(
                      controller: streetController,
                      label: 'Rua',
                      enabled: false,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    CustomTextField(
                      controller: districtController,
                      label: 'Bairro',
                      enabled: false,
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                            controller: numberController,
                            label: 'Número',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(16),
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                            controller: complementController ?? TextEditingController(),
                            label: 'Complemento (opcional)',
                          ),
                        ),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: cityController,
                            label: 'Cidade',
                            enabled: false,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(16),
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                            controller: stateController,
                            label: 'Estado',
                            enabled: false,
                          ),
                        ),
                      ],
                    ),              
                    DSSizedBoxSpacing.vertical(40),
                    CustomButton(
                      label: 'Salvar',
                      textColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
