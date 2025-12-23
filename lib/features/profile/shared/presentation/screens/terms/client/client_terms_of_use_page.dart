import 'package:app/features/profile/shared/presentation/widgets/terms_base_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class ClientTermsOfUseScreen extends StatelessWidget {
  const ClientTermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TermsBaseWidget(
      title: 'Termos de Uso - Anfitriões', 
      content: 
      '''
      1. Disposições Gerais

        1.1. O aplicativo Showtime é uma plataforma digital de intermediação de serviços que visa aproximar artistas e contratantes para facilitar a contratação deles . O Showtime não presta serviços artísticos diretamente e não se responsabiliza pelos atos ou prejuízos morais , físicos ou materiais, causados pelos artistas. Para utilizar os serviços você precisa ser maior de 18 anos , manter uma conta de usuário e fornecer alguns dados pessoais como nome , endereço , cpf , email e celular , o tratamento de dados será feito de acordo com a legislação em vigor.

        1.2. O uso do aplicativo implica a aceitação integral dos termos de uso aqui descritos, incluindo possíveis termos suplementares que venham a ser criados. Você irá receber uma licença não transferível para acesso ao aplicativo , sua senha será pessoal e não deverá ser fornecida a terceiros, o uso indevido da conta por terceiros será responsabilidade do usuário.

      2. Interrupção e Modificações nos Serviços

        2.1. O Showtime reserva-se o direito de interromper ou modificar os serviços prestados pelo aplicativo, a qualquer momento e por qualquer motivo, sem que o usuário tenha direito de pleitear qualquer prejuízo ou indenização em decorrência dessa interrupção.

      3. Atualizações dos Termos de Uso

        3.1. Termos suplementares poderão ser introduzidos e integrarão este documento. Em caso de conflito, os termos suplementares prevalecerão sobre versões anteriores.

      4. Limitações de Responsabilidade

        4.1. Você reconhece que o Showtime não é um fornecedor direto de serviços, nem representante dos artistas que não são funcionários do aplicativo, portanto ele não se responsabiliza por condutas, atos ou omissões dos artistas cadastrados, sendo eles os únicos responsáveis pelas consequências de suas ações.

        4.2. Em caso de condutas inadequadas de artistas, o Showtime poderá aplicar sanções como suspensão ou exclusão da plataforma.

      5. Uso Indevido e Propriedade Intelectual

        5.1. É proibido modificar, reproduzir, vender ou explorar o aplicativo sem autorização expressa do Showtime.

        5.2. É vedada a realização de engenharia reversa, tentativa de acesso não autorizado ou uso das logomarcas sem permissão.

      6. Suspensão e Exclusão de Contas

        6.1. O Showtime poderá suspender ou excluir contas que violem os termos de uso ou apresentem conduta inadequada. Não é permitido a troca de números de celulares, email, Skype ou qualquer forma de contato externa do aplicativo, toda a comunicação entre anfitriões e os artistas deverão ser feitas por troca de mensagens dentro do App, tentativas de burlar essa regra poderão ser penalizadas com suspensão e até mesmo a exclusão dele.

      7. Comunicação

        7.1. O usuário concorda em receber mensagens via SMS, WhatsApp ou e-mail com o objetivo de facilitar o funcionamento dos serviços.

      8. Garantias e Limitações de Uso

        8.1. O Showtime não garante a funcionalidade de seus serviços em todos os dispositivos, eventuais dificuldades deverão ser informadas para análise e resolução.

      9. Pagamentos

        9.1. O Showtime disponibilizará uma plataforma de pagamento independente para as transações. A responsabilidade por falhas ou problemas relacionados é exclusivamente da operadora de pagamentos.

        9.2. Não armazenamos dados de cartão de crédito.

        9.3. Quando uma apresentação for contratada em uma cidade diferente da que reside o artista, ele poderá exigir que o anfitrião forneça o transfer e a hospedagem, as partes deverão combinar tudo por mensagens dentro do App para caso haja algum problema possamos interceder e resolver a questão, caso o anfitrião concorde com as despesas ele ficará responsável por fazer as reservas e todos os pagamentos, não sendo permitido o envio de dinheiro para os artistas. Nas apresentações realizadas dentro da cidade onde está baseado o artista não serão permitidas nenhuma cobrança extra por transfer ou hospedagem.

      10. Cancelamentos

        10.1. Cancelamentos estarão sujeitos à seguinte política de reembolsos, que poderá vir a ser modificada mediante prévio aviso:

        a) Até 30 dias antes do evento: multa de 10% sobre o valor pago.

        b) Menos de 30 até 15 dias antes do evento: multa de 50% do valor pago.

        c) Menos de 15 dias antes do evento: multa de 100% do valor pago.

        10.2. Em casos de força maior, como tempestades, incêndio no local da apresentação ou falecimento de parente próximo (pais, filhos, cônjuge) do contratante ou do artista (até 30 dias antes do evento), será feito o reembolso integral.

        10.3. Em caso do artista cancelar ou faltar a sua apresentação todos os valores pagos serão devolvidos em até 72h úteis após o cancelamento.

      11. Direitos e Obrigações dos Artistas

        11.1. O artista poderá recusar ou interromper a apresentação caso o local seja inseguro, insalubre, não possua banheiro ou água potável, ou se houver conduta desrespeitosa do público, desde que ele tenha advertido os espectadores sobre a possibilidade da interrupção previamente.

        11.2. O tempo para a montagem e desmontagem dos equipamentos necessários para a realização da apresentação contratada não contam como tempo dela, todos os equipamentos deverão ser desmontados e levados do local pelos artistas logo após o término da apresentação.

        11.3. Após um show ser contratado serão fornecidas senhas para o anfitrião e ao artista. O artista deverá fornecer a senha recebida ao chegar no local do evento contratado e o anfitrião por sua vez irá fornecer uma senha ao artista que deverá digitá-la no App Showtime somente quando for iniciar sua apresentação, a não digitação da senha poderá acarretar atraso no recebimento do seu cachê.

      12. Provas em Caso de Conflito

        12.1. O usuário concorda que mensagens trocadas com o aplicativo, por WhatsApp, SMS ou e-mail, poderão ser utilizadas como meio de prova, conforme o artigo 190 do Código de Processo Civil.

      13. Disposições Finais

        13.1. Ao utilizar o aplicativo, o usuário declara que leu e concorda com os termos acima descritos.

      14. Atualizações

        14.1. Estes termos poderão ser alterados a qualquer momento, com aviso prévio, e as alterações passarão a vigorar após sua publicação no aplicativo.

      Em caso de dúvidas, entre em contato pelo suporte disponível no aplicativo Showtime ou email suporte@showtime.app.br.
      ''',
    );
  }
}


