import 'package:app/core/design_system/size/ds_size.dart';
import 'package:flutter/material.dart';

class CustomMessageField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;

  const CustomMessageField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.readOnly = false,
  });

  @override
  CustomMessageFieldState createState() => CustomMessageFieldState();
}

class CustomMessageFieldState extends State<CustomMessageField> {
  late TextEditingController _controller;
  // ignore: unused_field
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _charCount = widget.initialValue?.length ?? 0;
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          minLines: 6,
          maxLines: 6, // Permite múltiplas linhas
          maxLength: 1000, // Limita a 1000 caracteres
          onChanged: widget.onChanged,
          validator: widget.validator,
          cursorColor: textColor,
          readOnly: widget.readOnly,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSurfaceContainerColor),
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: surfaceContainerColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSSize.width(15)),
              borderSide: BorderSide(color: surfaceContainerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSSize.width(15)),
              borderSide: BorderSide(color: textColor),
            ),
          ),
        ),
        // SizedBox(height: 5),
        // Text(
        //   '$_charCount/1000 caracteres',
        //   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onSurfaceContainerColor),
        // ),
      ],
    );
  }
}