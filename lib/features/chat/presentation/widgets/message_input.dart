import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/shared/widgets/circular_progress_indicator.dart';
import 'package:flutter/material.dart';

/// Widget para input de mensagem no chat
/// 
/// Campo de texto com botão de envio
class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final surfaceContainerColor = colorScheme.surfaceContainerHighest;
    final onSurfaceContainerColor = colorScheme.onSurfaceVariant;
    final textColor = colorScheme.onSurface;
    final primaryColor = colorScheme.onPrimaryContainer;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSPadding.horizontal(16),
        vertical: DSPadding.vertical(12),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Campo de texto
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: onSurfaceContainerColor,
                  ),
                  filled: true,
                  fillColor: surfaceContainerColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DSPadding.horizontal(16),
                    vertical: DSPadding.vertical(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(24)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(24)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSSize.width(24)),
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 1,
                    ),
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
                onSubmitted: (_) {
                  if (widget.controller.text.trim().isNotEmpty) {
                    widget.onSend();
                  }
                },
              ),
            ),
            DSSizedBoxSpacing.horizontal(8),
            // Botão de envio
            Container(
              width: DSSize.width(44),
              height: DSSize.height(44),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ||
                          widget.controller.text.trim().isEmpty
                      ? null
                      : widget.onSend,
                  borderRadius: BorderRadius.circular(DSSize.width(22)),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: DSSize.width(20),
                            height: DSSize.height(20),
                            child: CustomLoadingIndicator(
                              strokeWidth: 2,
                              color: colorScheme.surface,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            size: DSSize.width(20),
                            color: widget.controller.text.trim().isEmpty
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.surface,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
