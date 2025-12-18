
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:flutter/material.dart';

// Placeholder genérico para páginas em desenvolvimento
class PlaceholderPage extends StatelessWidget {
  final String pageName;

  const PlaceholderPage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarTitle: pageName,
      child: Center(
          child: Text(
            '🎭✨ '
            'Seja muito bem-vindo ao ShowTime!'
            'Estamos no início desta grande jornada, em fase de cadastro de artistas.'
            'O palco ainda está sendo montado e novas funcionalidades chegarão em breve!'
            'Ficamos muito felizes em ter você conosco nesse começo.'
            'Prepare-se para brilhar e construir essa história junto com a gente!'
            '🌟🎶',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
  }
}
