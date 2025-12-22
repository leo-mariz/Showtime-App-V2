import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget para campos sensíveis que mostra dados mascarados quando não está em edição
class MaskedSensitiveField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String Function(String) maskFunction; // Função que aplica máscara para visualização
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isEditing;
  final VoidCallback? onEditTap;

  const MaskedSensitiveField({
    super.key,
    required this.label,
    required this.controller,
    required this.maskFunction,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isEditing = false,
    this.onEditTap,
  });

  @override
  State<MaskedSensitiveField> createState() => _MaskedSensitiveFieldState();
}

class _MaskedSensitiveFieldState extends State<MaskedSensitiveField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool get _shouldFloat => _isFocused || widget.controller.text.isNotEmpty;
  bool get _isEditMode => widget.isEditing || _isFocused;

  String _getMaskedValue() {
    if (widget.controller.text.isEmpty) return '';
    return widget.maskFunction(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onPrimary;
    final double labelFontSize = calculateFontSize(12);
    final double labelTop = _shouldFloat ? -DSSize.height(12) : DSSize.height(18);
    final double labelLeft = _shouldFloat ? DSSize.width(2) : DSSize.width(12);
    final double labelPaddingH = DSSize.width(2);
    final double labelPaddingV = DSSize.height(2);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: DSSize.height(6)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Campo editável ou visualização mascarada
          GestureDetector(
            onTap: !_isEditMode && widget.onEditTap != null
                ? widget.onEditTap
                : null,
            child: AbsorbPointer(
              absorbing: !_isEditMode,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                enabled: _isEditMode,
                inputFormatters: widget.inputFormatters,
                cursorColor: textColor,
                style: textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: _isEditMode ? null : 'Toque para editar',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: onSurfaceContainerColor.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: surfaceContainerColor.withValues(alpha: (0.95 * 255)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(16)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(16)),
                    borderSide: BorderSide(color: surfaceContainerColor),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(16)),
                    borderSide: BorderSide(color: surfaceContainerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(16)),
                    borderSide: BorderSide(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DSSize.width(16),
                    vertical: DSSize.height(18),
                  ),
                  suffixIcon: !_isEditMode && widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: DSSize.width(20),
                            color: colorScheme.onPrimaryContainer,
                          ),
                          onPressed: widget.onEditTap,
                        )
                      : null,
                  labelText: null,
                ),
              ),
            ),
          ),
          // Overlay com valor mascarado quando não está editando
          if (!_isEditMode && widget.controller.text.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onEditTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSize.width(16),
                    vertical: DSSize.height(18),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getMaskedValue(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: onSurfaceContainerColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          // Label flutuante
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            left: labelLeft,
            top: labelTop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: labelPaddingH,
                vertical: labelPaddingV,
              ),
              decoration: BoxDecoration(
                color: _shouldFloat ? colorScheme.onPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(DSSize.width(6)),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _shouldFloat
                      ? colorScheme.primary
                      : onSurfaceContainerColor,
                  fontWeight: _shouldFloat ? FontWeight.normal : FontWeight.bold,
                  fontSize: labelFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

