import 'package:app/features/profile/shared/presentation/widgets/terms_base_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class TermsOfPrivacyScreen extends StatelessWidget {
  const TermsOfPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TermsBaseWidget(
      title: 'Política de Privacidade', 
      content: 
      '''
      1. Coleta de Informações
      1.1. Coletamos dados como nome, endereço, CPF, e-mail e número de celular para criação de contas e execução dos serviços oferecidos.

      2. Uso das Informações
      2.1. As informações são utilizadas para:

      Facilitar a conexão entre artistas e contratantes.
      Enviar notificações relacionadas aos serviços.
      2.2. O Showtime não compartilha dados com terceiros sem autorização do usuário.
      3. Armazenamento de Dados
      3.1. Os dados dos usuários são armazenados em servidores seguros e em conformidade com a Lei Geral de Proteção de Dados (LGPD).
      3.2. Não armazenamos dados de cartão de crédito.

      4. Direitos do Usuário
      4.1. O usuário pode solicitar a exclusão de seus dados a qualquer momento.
      4.2. O Showtime disponibiliza um canal de suporte para dúvidas e solicitações.

      5. Atualizações na Política de Privacidade
      5.1. Esta política poderá ser alterada a qualquer momento, mediante aviso prévio aos usuários.

      6. Contato
      Para dúvidas ou solicitações, entre em contato pelo e-mail: suporte@showtime.com.
      '''
    );
  }
}


