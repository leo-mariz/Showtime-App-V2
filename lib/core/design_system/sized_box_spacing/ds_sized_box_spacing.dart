import 'package:flutter/material.dart';

// Alternativa para substiituir o SizedBox do Flutter, com a diferença de que este utiliza o tamanho da tela para calcular o tamanho do widget.
// Utilizar o DSSizedBoxSpacing.horizontal() para substituir o SizedBox com width. Passando o valor desejado por parâmetro.
// Utilizar o DSSizedBoxSpacing.vertical() para substituir o SizedBox com height. Passando o valor desejado por parâmetro.
class DSSizedBoxSpacing {
  static const double _figmaWidth = 375;
  static const double _figmaHeight = 812;

  static final double _width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  static final double _height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;

  static final double _pixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static SizedBox horizontal(double valor) => SizedBox(
        width: _calcularHorizontal(valor),
      );

  static SizedBox vertical(double valor) => SizedBox(
        height: _calcularVertical(valor),
      );

  static double _calcularHorizontal(double valor) =>
      valor * _width / _figmaWidth / _pixelRatio;

  static double _calcularVertical(double valor) =>
      valor * _height / _figmaHeight / _pixelRatio;
}
