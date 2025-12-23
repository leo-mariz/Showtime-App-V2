
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';

class TermsBaseWidget extends StatelessWidget {
  final String title;
  final String content;

  const TermsBaseWidget({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarTitle: title,
      showAppBarBackButton: true,
      child: SingleChildScrollView(
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ),
    );
  }
}