import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:app/core/services/mercado_pago_service.dart';

/// Enum para status do pagamento via Deep Link
enum PaymentDeepLinkStatus {
  success,
  failure,
  pending,
}

/// Callback para quando um Deep Link de pagamento é recebido
typedef PaymentDeepLinkCallback = void Function(
  PaymentDeepLinkStatus status,
  Map<String, String> queryParams,
);

/// Serviço para gerenciar Deep Links do aplicativo
/// Principalmente usado para retorno do fluxo de pagamento do Mercado Pago
class DeepLinkService {
  static const String _scheme = 'myapp'; // ⚠️ ALTERAR para o scheme do seu app

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  PaymentDeepLinkCallback? _paymentCallback;
  final MercadoPagoService _mercadoPagoService;

  DeepLinkService({
    MercadoPagoService? mercadoPagoService,
  }) : _mercadoPagoService = mercadoPagoService ?? MercadoPagoService();

  /// Inicializa o listener de Deep Links
  /// 
  /// [onPaymentReturn] - Callback chamado quando retorna do pagamento
  /// 
  /// Deve ser chamado no initState do widget principal ou no main.dart
  void initialize({
    required PaymentDeepLinkCallback onPaymentReturn,
  }) {
    _paymentCallback = onPaymentReturn;
    
    // Escuta Deep Links enquanto o app está aberto
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('❌ Erro ao escutar Deep Link: $err');
      },
    );

    // Verifica se o app foi aberto via Deep Link
    _checkInitialLink();
    
    debugPrint('✅ DeepLinkService inicializado');
  }

  /// Verifica se o app foi aberto via Deep Link (cold start)
  Future<void> _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar Deep Link inicial: $e');
    }
  }

  /// Processa o Deep Link recebido
  void _handleDeepLink(Uri uri) {
    debugPrint('🔗 Deep Link recebido: $uri');

    // Verifica se é do nosso app
    if (uri.scheme != _scheme) {
      debugPrint('⚠️ Deep Link de outro app ignorado: ${uri.scheme}');
      return;
    }

    // Fecha Safari View Controller se iOS
    if (Platform.isIOS) {
      _mercadoPagoService.closeCheckoutIOS();
    }

    // Processa Deep Links de pagamento
    if (_isPaymentDeepLink(uri)) {
      _handlePaymentDeepLink(uri);
    }
  }

  /// Verifica se é um Deep Link de retorno de pagamento
  bool _isPaymentDeepLink(Uri uri) {
    return uri.host == 'success' || 
           uri.host == 'failure' || 
           uri.host == 'pending';
  }

  /// Processa Deep Link de pagamento
  void _handlePaymentDeepLink(Uri uri) {
    PaymentDeepLinkStatus? status;

    switch (uri.host) {
      case 'success':
        status = PaymentDeepLinkStatus.success;
        debugPrint('✅ Pagamento aprovado');
        break;
      case 'failure':
        status = PaymentDeepLinkStatus.failure;
        debugPrint('❌ Pagamento rejeitado');
        break;
      case 'pending':
        status = PaymentDeepLinkStatus.pending;
        debugPrint('⏳ Pagamento pendente');
        break;
      default:
        debugPrint('⚠️ Status de pagamento desconhecido: ${uri.host}');
        return;
    }

    // Extrai query parameters (ex: payment_id, external_reference)
    final queryParams = uri.queryParameters;
    
    debugPrint('📦 Query Params: $queryParams');

    // Chama callback
    if (_paymentCallback != null) {
      _paymentCallback!(status, queryParams);
    }
  }

  /// Retorna o scheme configurado
  String get scheme => _scheme;

  /// Retorna as URLs de retorno para configurar na preferência do Mercado Pago
  Map<String, String> get backUrls => {
    'success': '$_scheme://success',
    'failure': '$_scheme://failure',
    'pending': '$_scheme://pending',
  };

  /// Desabilita o listener
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _paymentCallback = null;
    debugPrint('🛑 DeepLinkService desabilitado');
  }
}

