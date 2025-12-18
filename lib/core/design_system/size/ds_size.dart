import 'package:flutter/material.dart';

// Utilizado para definir o tamanho do width ou height de acordo com o tamanho da tela.
// Pode ser utilizado em qualquer widget que receba width ou height para definir sua altura ou largura.
// Utilizar o DSSize.width() para o width. Passando o valor desejado por parâmetro.
// Utilizar o DSSize.height() para o height. Passando o valor desejado por parâmetro.
class DSSize {
  static const double _figmaWidth = 375;
  static const double _figmaHeight = 812;

  static final double _width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  static final double _height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;

  static final double _pixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static double width(double valor) => valor * _width / _figmaWidth / _pixelRatio;

  static double height(double valor) => valor * _height / _figmaHeight / _pixelRatio;
}