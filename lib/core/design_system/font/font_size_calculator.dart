import 'package:flutter/material.dart';

double calculateFontSize(double fontSize) {
  // Obtendo a largura física da tela em pixels.
  final physicalSizeWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
   // Obtendo a proporção de pixels do dispositivo.
  final devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

// A largura lógica da tela, que é a largura em pixels lógicos, pode ser calculada dividindo a largura física pela proporção de pixels do dispositivo.
  final double logicalWidth = physicalSizeWidth / devicePixelRatio; 

  // Define um fator de escala com base na largura lógica da tela.
  double scaleFactor;

  if (logicalWidth < 380) {
    scaleFactor = 0.8; // Diminui o tamanho da fonte em 20%.
  } else if (logicalWidth < 800) {
    scaleFactor = 1.0; // Mantém o tamanho da fonte original.
  } else {
    scaleFactor = 1.2; // Aumenta o tamanho da fonte em 20%.
  }

  return fontSize * scaleFactor;
}