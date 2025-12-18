import 'package:flutter/material.dart';

// Utilizado para definir o tamanho do width ou height de acordo com o tamanho da tela.
// Pode ser utilizado em Padding, Margin, SizedBox(quando este possuir um child, caso contrário utilizar o DSSizedBoxSpacing), Container, etc.
// Utilizar o DSPadding.horizontal() para o width. Passando o valor desejado por parâmetro.
// Utilizar o DSPadding.vertical() para o height. Passando o valor desejado por parâmetro.
class DSPadding {
  static const double _figmaWidth = 375;
  static const double _figmaHeight = 812;

  static final double _width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  static final double _height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;

  static final double _pixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static double horizontal(double valor) => valor * _width / _figmaWidth / _pixelRatio;

  static double vertical(double valor) => valor * _height / _figmaHeight / _pixelRatio;
}