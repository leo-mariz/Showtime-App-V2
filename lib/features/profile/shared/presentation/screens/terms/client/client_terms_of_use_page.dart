
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
      content: _termsContent,
    );
  }
}

const String _termsContent = r'''
  TERMOS DE USO DO APLICATIVO SHOWTIME

  1. Disposições Gerais

  1.1. O aplicativo Showtime é uma plataforma digital de intermediação de serviços que visa aproximar artistas e contratantes para facilitar a contratação de apresentações. O Showtime não presta serviços artísticos diretamente e não se responsabiliza pelos atos ou prejuízos morais, físicos ou materiais causados pelos artistas. Para utilizar os serviços, o usuário deve ser maior de 18 anos, manter uma conta ativa e fornecer dados pessoais como nome, endereço, CPF, e-mail e celular. O tratamento de dados será realizado em conformidade com a legislação vigente.

  1.2. O uso do aplicativo implica a aceitação integral dos presentes Termos de Uso, incluindo eventuais termos suplementares que venham a ser criados. É concedida ao usuário uma licença não transferível para acesso ao aplicativo. A senha é de uso pessoal e não deve ser fornecida a terceiros; o uso indevido da conta por terceiros será de responsabilidade do titular.

  ---

  2. Interrupção e Modificações nos Serviços

  2.1. O Showtime reserva-se o direito de interromper ou modificar os serviços prestados pelo aplicativo a qualquer momento e por qualquer motivo, sem que o usuário tenha direito a pleitear indenização ou ressarcimento em decorrência dessa interrupção ou modificação.

  ---

  3. Atualizações dos Termos de Uso

  3.1. Termos suplementares poderão ser introduzidos e integrarão este documento. Em caso de conflito, os termos suplementares prevalecerão sobre as versões anteriores.

  ---

  4. Limitações de Responsabilidade

  4.1. O usuário reconhece que o Showtime não é fornecedor direto de serviços nem representante dos artistas, que não possuem vínculo empregatício com a plataforma. O Showtime não se responsabiliza por condutas, atos ou omissões dos artistas cadastrados, sendo estes os únicos responsáveis pelas consequências de suas ações.

  4.2. Em caso de condutas inadequadas de artistas, o Showtime poderá aplicar sanções como suspensão ou exclusão da plataforma.

  ---

  5. Uso Indevido e Propriedade Intelectual

  5.1. É proibido modificar, reproduzir, vender ou explorar o aplicativo sem autorização expressa do Showtime.

  5.2. É vedada a realização de engenharia reversa, tentativa de acesso não autorizado ou uso das logomarcas sem permissão.

  ---

  6. Suspensão e Exclusão de Contas

  6.1. O Showtime poderá suspender ou excluir contas que violem os Termos de Uso ou apresentem conduta inadequada. Não é permitida a troca de números de celular, e-mail, Skype ou qualquer forma de contato externo fora do aplicativo; toda a comunicação entre anfitriões e artistas deve ser feita exclusivamente por mensagens dentro do App. Tentativas de burlar essa regra poderão ser penalizadas com suspensão ou exclusão da conta.

  ---

  7. Comunicação

  7.1. O usuário concorda em receber mensagens via SMS, WhatsApp ou e-mail com o objetivo de facilitar o funcionamento dos serviços.

  ---

  8. Garantias e Limitações de Uso

  8.1. O Showtime não garante o funcionamento de seus serviços em todos os dispositivos. Eventuais dificuldades devem ser informadas à equipe para análise e resolução.

  ---

  9. Pagamentos

  9.1. O Showtime disponibiliza uma plataforma de pagamento independente para as transações. A responsabilidade por falhas ou problemas relacionados a pagamentos é exclusivamente da operadora de pagamentos.

  9.2. Não armazenamos dados de cartão de crédito.

  9.3. Quando uma apresentação for contratada em cidade diferente da de residência do artista, este poderá exigir que o anfitrião forneça transfer e hospedagem. As partes devem combinar todos os detalhes por mensagens dentro do App, para que, em caso de problema, a plataforma possa interceder. Caso o anfitrião concorde com as despesas, ficará responsável por realizar as reservas e todos os pagamentos; não é permitido o envio de dinheiro diretamente aos artistas. Em apresentações realizadas na mesma cidade em que o artista está baseado, não serão permitidas cobranças extras por transfer ou hospedagem.

  ---

  10. Cancelamentos

  Os cancelamentos estão sujeitos à seguinte política de reembolsos, que poderá ser modificada mediante aviso prévio:

  a) Até 30 (trinta) dias antes do evento: reembolso integral, sem multa.

  b) Menos de 30 (trinta) até 15 (quinze) dias antes do evento: multa de 50% sobre o valor pago.

  c) Menos de 15 (quinze) dias antes do evento: multa de 100% sobre o valor pago.

  Em casos de força maior, como tempestades, incêndio no local da apresentação ou falecimento de parente próximo (pais, filhos, cônjuge) do contratante ou do artista, até 30 (trinta) dias antes do evento, será feito o reembolso integral.

  Em caso de cancelamento ou falta do artista à apresentação, todos os valores pagos serão devolvidos em até 72 (setenta e duas) horas úteis após o cancelamento.

  ---

  11. Direitos e Obrigações dos Artistas

  11.1. O artista poderá recusar ou interromper a apresentação caso o local seja inseguro, insalubre, não possua banheiro ou água potável, ou na ocorrência de conduta desrespeitosa do público, desde que tenha advertido previamente os espectadores sobre a possibilidade de interrupção.

  11.2. O tempo para montagem e desmontagem dos equipamentos necessários à apresentação contratada não conta como tempo da apresentação. Todos os equipamentos devem ser desmontados e retirados do local pelos artistas logo após o término da apresentação.

  Os artistas contratados devem levar seus instrumentos e equipamentos para as apresentações, com exceção dos pianistas; neste caso, o piano já deve estar no local do show. Equipamentos de iluminação podem ser fornecidos pelo anfitrião. Não é permitida a utilização de artefatos pirotécnicos nas apresentações; artistas que descumprirem essa regra poderão ser banidos do aplicativo.

  Artistas individuais são responsáveis por levar equipamentos de sonorização quando necessário (microfones e caixas de som portáteis). Conjuntos musicais devem levar sonorização, microfones e caixas portáteis quando a apresentação for em locais menores; em eventos em locais amplos que exijam equipamentos maiores, estes devem ser fornecidos pelo anfitrião, que deverá contratar empresa especializada. Danos aos equipamentos em decorrência de problemas na rede elétrica não são de responsabilidade do aplicativo, que apenas intermedeia a contratação dos serviços.

  11.3. Após a contratação de um show, será gerada uma palavra-chave de confirmação. No dia do evento, ao chegar ao local, o artista deve solicitar essa palavra-chave ao anfitrião. O anfitrião informará a palavra-chave ao artista no momento da chegada. O artista deverá digitá-la no aplicativo Showtime ao iniciar a apresentação. O show só será considerado realizado após essa confirmação no App. A não digitação da palavra-chave no momento adequado poderá acarretar atraso no recebimento do cachê.

  ---

  12. Provas em Caso de Conflito

  12.1. O usuário concorda que mensagens trocadas pelo aplicativo, por WhatsApp, SMS ou e-mail, poderão ser utilizadas como meio de prova, nos termos do artigo 190 do Código de Processo Civil.

  ---

  13. Disposições Finais

  13.1. Ao utilizar o aplicativo, o usuário declara que leu e concorda com os termos acima descritos.

  ---

  14. Atualizações

  14.1. Estes termos poderão ser alterados a qualquer momento, com aviso prévio, passando as alterações a vigorar após sua publicação no aplicativo.

  ---

  Em caso de dúvidas, entre em contato pelo suporte disponível no aplicativo Showtime ou pelo e-mail suporte@showtime.app.br.
''';
