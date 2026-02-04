import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/selectable_row.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/availability/presentation/widgets/radius_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal para editar endereço base e raio de atuação
class EditAddressRadiusModal extends StatefulWidget {
  final AddressInfoEntity? initialAddress;
  final double initialRadius;

  const EditAddressRadiusModal({
    super.key,
    this.initialAddress,
    required this.initialRadius,
  });

  /// Exibe o modal de edição
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    AddressInfoEntity? initialAddress,
    required double initialRadius,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAddressRadiusModal(
        initialAddress: initialAddress,
        initialRadius: initialRadius,
      ),
    );
  }

  @override
  State<EditAddressRadiusModal> createState() => _EditAddressRadiusModalState();
}

class _EditAddressRadiusModalState extends State<EditAddressRadiusModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _radiusController = TextEditingController();

  AddressInfoEntity? _selectedAddress;
  double _radiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
    _radiusKm = widget.initialRadius;
    _radiusController.text = _radiusKm.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final result = await AddressesModal.show(
      context: context,
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  /// Verifica se houve mudanças nos campos
  bool _hasChanges() {
    // Comparar endereço (usando operador == do dart_mappable)
    final addressChanged = _selectedAddress != widget.initialAddress;
    
    // Comparar raio (com tolerância para ponto flutuante)
    final radiusChanged = (_radiusKm - widget.initialRadius).abs() > 0.01;
    
    return addressChanged || radiusChanged;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAddress == null) {
      context.showError('Selecione um endereço');
      return;
    }

    // Retorna os dados editados
    Navigator.of(context).pop({
      'address': _selectedAddress,
      'radiusKm': _radiusKm,
    });
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DSSize.width(20)),
          child: Form(
            key: _formKey,
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
                  'Editar endereço e raio',
                  style: TextStyle(
                    fontSize: calculateFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                DSSizedBoxSpacing.vertical(24),

                // Endereço
                SelectableRow(
                  label: 'Endereço base',
                  value: _selectedAddress?.title ?? 'Selecione',
                  onTap: _selectAddress,
                ),

                DSSizedBoxSpacing.vertical(16),

                // Mapa com raio (apenas se endereço selecionado)
                if (_selectedAddress != null) ...[
                  Text(
                    'Raio de atuação',
                    style: textTheme.bodyMedium,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  RadiusMapWidget(
                    address: _selectedAddress!,
                    radiusKm: _radiusKm,
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  Text(
                    'Raio (km)',
                    style: textTheme.bodyMedium,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Row(
                    children: [
                      // Slider
                      Expanded(
                        flex: 4,
                        child: Slider(
                          value: _radiusKm,
                          min: 0.1,
                          max: 200.0,
                          divisions: 1999, // Permite incrementos de 0.1 (100 metros)
                          label: _radiusKm >= 1
                              ? '${_radiusKm.toStringAsFixed(1)} km'
                              : '${(_radiusKm * 1000).toStringAsFixed(0)} m',
                          onChanged: (value) {
                            setState(() {
                              _radiusKm = value;
                              _radiusController.text = value.toStringAsFixed(1);
                            });
                          },
                        ),
                      ),
                      DSSizedBoxSpacing.horizontal(16),
                      // Campo de texto
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(DSSize.width(12)),
                          border: Border.all(
                            color: colorScheme.outline,
                          ),
                        ),
                        child: TextFormField(
                          controller: _radiusController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: TextStyle(
                            fontSize: calculateFontSize(14),
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) {
                            final num = double.tryParse(value.replaceAll(',', '.'));
                            if (num != null && num >= 0.1 && num <= 200) {
                              setState(() {
                                _radiusKm = num;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            final num = double.tryParse(value.replaceAll(',', '.'));
                            if (num == null || num < 0.1 || num > 200) {
                              return 'Entre 0.1 e 200';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  DSSizedBoxSpacing.vertical(24),
                ],

                // Botões
                Row(
                  children: [
                    
                    Expanded(
                      child: CustomButton(
                        label: 'Salvar',
                        onPressed: _hasChanges() ? _onSave : null,
                        backgroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),

                DSSizedBoxSpacing.vertical(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
