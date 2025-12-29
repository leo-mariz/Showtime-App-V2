import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isPasswordVisible = false;


  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _shouldFloat => _isFocused || widget.controller.text.isNotEmpty;

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
          // Usar TextFormField se houver validator, senão usar TextField
          widget.validator != null
              ? TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? !_isPasswordVisible : widget.obscureText,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  enabled: widget.enabled,
                  inputFormatters: widget.inputFormatters,
                  validator: widget.validator,
                  cursorColor: textColor,
                  style: textTheme.bodyMedium?.copyWith(
                    color: widget.enabled 
                        ? textColor 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    errorStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontSize: calculateFontSize(11),
                    ),
                    errorMaxLines: 2,
                    hintStyle: textTheme.bodyMedium?.copyWith(color: textColor),
                    filled: true,
                    suffixIcon: widget.isPassword ? IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ) 
                    : null,
                    fillColor: widget.enabled 
                        ? surfaceContainerColor
                        : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(
                        // color: colorScheme.onPrimary.withValues(alpha: 0.5 * 255),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(color: surfaceContainerColor),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(
                        color: colorScheme.surfaceContainer,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DSSize.width(16)),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DSSize.width(16),
                      vertical: DSSize.height(18),
                    ),
                    labelText: null, // Não usar o label padrão
                  ),
                )
              : TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? !_isPasswordVisible : widget.obscureText,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  enabled: widget.enabled,
                  inputFormatters: widget.inputFormatters,
                  cursorColor: textColor,
                  style: textTheme.bodyMedium?.copyWith(
                    color: widget.enabled 
                        ? textColor 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
              hintStyle: textTheme.bodyMedium?.copyWith(color: textColor),
              filled: true,
               suffixIcon: widget.isPassword ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: textColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ) 
              : null,
              fillColor: widget.enabled 
                  ? surfaceContainerColor
                  : colorScheme.surfaceContainerHighest.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSSize.width(16)),
                borderSide: BorderSide(
                  // color: colorScheme.onPrimary.withValues(alpha: 0.5 * 255),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSSize.width(16)),
                borderSide: BorderSide(color: surfaceContainerColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSSize.width(16)),
                borderSide: BorderSide(
                  color: colorScheme.surfaceContainer,
                ),
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
                    labelText: null, // Não usar o label padrão
                  ),
                ),
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
                color:
                 _shouldFloat
                    ? colorScheme.onPrimary
                    :
                     Colors.transparent,
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
