import 'package:app/core/shared/widgets/app_bar.dart';
import 'package:app/core/shared/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;
  final double verticalPadding;
  final bool showAppBar;
  final String? appBarTitle;
  final Color? appBarTitleColor;
  final bool? showAppBarBackButton;
  final List<Widget>? appBarActions;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const BasePage({
    super.key,
    required this.child,
    this.horizontalPadding = 16,
    this.verticalPadding = 12,
    this.showAppBar = false,
    this.appBarTitle,
    this.appBarTitleColor,
    this.showAppBarBackButton = false,
    this.appBarActions,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        child: Scaffold(
          appBar: showAppBar ? CustomAppBar(
            title: appBarTitle,
            titleColor: appBarTitleColor,
            showBackButton: showAppBarBackButton ?? false,
            actions: appBarActions,
          ) : null,
          backgroundColor: backgroundColor ?? Colors.transparent,
          floatingActionButton: floatingActionButton,
          body: Container(
            color: backgroundColor ?? Colors.transparent,
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DSPadding.horizontal(horizontalPadding),
                  vertical: DSPadding.vertical(verticalPadding),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}