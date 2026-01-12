import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:url_launcher/url_launcher.dart';

/// Serviço para integração com Mercado Pago
/// Gerencia abertura do checkout via Custom Tabs (Android) ou Safari View Controller (iOS)
class MercadoPagoService {
  /// Abre o checkout do Mercado Pago
  /// 
  /// [initPoint] - URL do checkout retornada pela API do Mercado Pago
  /// [context] - BuildContext para temas e navegação (opcional, usado apenas no Android)
  /// [toolbarColor] - Cor da toolbar no Android (opcional, usado se context não for fornecido)
  /// 
  /// ⚠️ Importante: initPoint deve vir do backend (nunca criar no app)
  Future<void> openCheckout(
    String initPoint, {
    BuildContext? context,
    int? toolbarColor,
  }) async {
    try {
      if (Platform.isAndroid) {
        await _openCheckoutAndroid(initPoint, context: context, toolbarColor: toolbarColor);
      } else if (Platform.isIOS) {
        await _openCheckoutIOS(initPoint);
      } else {
        throw UnsupportedError('Plataforma não suportada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao abrir checkout do Mercado Pago: $e');
      rethrow;
    }
  }

  /// Abre checkout no Android usando Custom Tabs
  Future<void> _openCheckoutAndroid(
    String initPoint, {
    BuildContext? context,
    int? toolbarColor,
  }) async {
    int finalToolbarColor;
    if (context != null) {
    final theme = Theme.of(context);
      finalToolbarColor = theme.colorScheme.surface.value;
    } else if (toolbarColor != null) {
      finalToolbarColor = toolbarColor;
    } else {
      // Cor padrão (branco)
      finalToolbarColor = 0xFFFFFFFF;
    }
    
    try {
      await custom_tabs.launchUrl(
        Uri.parse(initPoint),
        customTabsOptions: custom_tabs.CustomTabsOptions(
          colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
            toolbarColor: Color(finalToolbarColor),
          ),
          // Permite compartilhar o link
          shareState: custom_tabs.CustomTabsShareState.on,
          // Esconde a URL bar quando o usuário rola
          urlBarHidingEnabled: true,
          // Mostra o título da página
          showTitle: true,
          // Botão de voltar
          closeButton: custom_tabs.CustomTabsCloseButton(
            icon: custom_tabs.CustomTabsCloseButtonIcons.back,
          ),
          // Animações suaves
          animations: const custom_tabs.CustomTabsAnimations(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ),
        ),
      );
      
      debugPrint('✅ Checkout aberto com sucesso (Android)');
    } catch (e) {
      // Exceção lançada se não houver navegador instalado
      debugPrint('❌ Erro ao abrir Custom Tab (Android): $e');
      throw Exception('Não foi possível abrir o navegador. Verifique se há um navegador instalado no dispositivo.');
    }
  }

  /// Abre checkout no iOS usando Safari View Controller
  Future<void> _openCheckoutIOS(String initPoint) async {
    final Uri url = Uri.parse(initPoint);
    
    try {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          // Habilita JavaScript (necessário para Mercado Pago)
          enableJavaScript: true,
          // Habilita DOM Storage (necessário para Mercado Pago)
          enableDomStorage: true,
        ),
      );
      
      debugPrint('✅ Checkout aberto com sucesso (iOS)');
    } catch (e) {
      debugPrint('❌ Erro ao abrir Safari View Controller (iOS): $e');
      throw Exception('Não foi possível abrir o navegador.');
    }
  }

  /// Fecha o Safari View Controller (apenas iOS)
  /// 
  /// ⚠️ No iOS, o Safari View Controller precisa ser fechado manualmente
  /// quando detectamos o retorno via Deep Link
  Future<void> closeCheckoutIOS() async {
    if (Platform.isIOS) {
      try {
        // Abre uma página em branco para fechar o Safari View Controller
        await launchUrl(Uri.parse('about:blank'));
        debugPrint('✅ Safari View Controller fechado');
      } catch (e) {
        debugPrint('❌ Erro ao fechar Safari View Controller: $e');
      }
    }
  }
}

