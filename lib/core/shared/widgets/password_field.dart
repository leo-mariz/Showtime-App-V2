import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomPasswordField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  CustomPasswordFieldState createState() => CustomPasswordFieldState();
}

class CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onPrimary;

    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: textColor),
      validator: widget.validator,
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: onSurfaceContainerColor),
        filled: true,
        fillColor: surfaceContainerColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          borderSide: BorderSide(color: surfaceContainerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSSize.width(16)),
          borderSide: BorderSide(color: textColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: textColor,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}