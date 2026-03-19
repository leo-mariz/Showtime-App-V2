import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/utils/legal_document_text_formatter.dart';
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
    final formatted = formatLegalDocumentForDisplay(content);
    return BasePage(
      showAppBar: true,
      appBarTitle: title,
      showAppBarBackButton: true,
      child: SingleChildScrollView(
          child: Text(
            formatted,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ),
    );
  }
}