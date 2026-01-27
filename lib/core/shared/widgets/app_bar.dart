import 'package:app/core/shared/widgets/leading_button.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? titleColor;
  final bool showBackButton;
  final VoidCallback? onBackButtonTap;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.showBackButton = true,
    this.onBackButtonTap,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: onPrimaryContainer,
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: titleColor ?? onPrimaryContainer,
      ),
      leading: showBackButton
          ? CustomLeadingButton(
              onTap: onBackButtonTap ?? () => Navigator.of(context).maybePop(),
              color: onPrimaryContainer,
            )
          : null,
      automaticallyImplyLeading: false,
      title: title != null ? Text(title!) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(DSSize.height(44));
}
