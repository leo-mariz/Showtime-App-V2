
import 'package:app/features/profile/presentation/widgets/terms_base_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class ArtistsTermsOfUseScreen extends StatelessWidget {
  const ArtistsTermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TermsBaseWidget(
      title: 'Termos de Uso - Artistas', 
      content: 
      '''      
      1. Aceitação dos Termos
      
        Ao se cadastrar como artista no Showtime Aplicativo, você declara que leu, entendeu e concorda com os termos e condições aqui descritos. Caso não concorde, não deverá utilizar o Aplicativo.

      2. Cadastro e Elegibilidade
      
        2.1. Para utilizar o Aplicativo como artista , você deve fornecer informações precisas e atualizadas, como nome completo, CPF/CNPJ, endereço, e-mail, telefone e quaisquer dados adicionais exigidos.
      
        2.2. O cadastro está disponível apenas para pessoas maiores de 18 anos e com plena capacidade jurídica.
      
      3. Propósito do aplicativo
      
        3.1. O aplicativo permite que artistas (músicos, fotógrafos, comediantes , palhaços, entre outros) divulguem seus serviços e se conectem a potenciais clientes. Todos os videos e fotos divulgados pelos artistas no app não devem conter imagens de terceiros que não tenham autorizado a sua divulgação.
      
        3.2. O artista entende que não é funcionário do aplicativo , que é um trabalhador autônomo e portanto ele é integralmente responsável pela qualidade, execução e entrega dos serviços oferecidos, sendo o único responsável por eventuais danos morais, físicos ou materiais causados.
      
      4. Taxas e Pagamentos
      
        4.1. O aplicativo cobrará uma comissão ou taxa de serviço pelas transações realizadas através da plataforma, cuja porcentagem será previamente informada e que inicialmente está estabelecida em 10% .Essa percentagem poderá ser modificada a qualquer momento de acordo com a política comercial que convier ao aplicativo , eventuais alterações serão previamente informadas aos artistas e não incidirão sobre apresentações já contratadas .
      
        4.2. Os artistas ficarão responsáveis pelo pagamento dos impostos que incidirem sobre seus cachês de acordo com a legislação em vigor. Eventuais retenções de impostos que forem exigidas por lei serão aplicadas de acordo com a tabela que estiver vigente.
        
        4.3. Quando uma apresentação for contratada em uma cidade diferente da que reside o artista, ele poderá exigir que o anfitrião forneça o transfer e a hospedagem. As partes deverão combinar tudo por mensagens dentro do App para caso haja algum problema possamos interceder e resolver a questão. Nesse caso, o anfitrião será responsável por fazer as reservas e todos os pagamentos, não sendo permitido o envio de dinheiro para os artistas. Nas apresentações realizadas dentro da cidade onde está baseado o artista não serão permitidas nenhuma cobrança extra por transfer ou hospedagem. O aplicativo não se responsabiliza por eventuais acidentes ou roubos que possam ocorrer durante o deslocamento do artista, uma vez que ele tem livre escolha de escolher o meio de transporte mais adequado. Recomendamos que antes de aceitar o pedido de apresentações verifiquem se o local é considerado seguro, principalmente no horário de retorno. Também não nos responsabilizamos por acidentes no local da apresentação, uma vez que os artistas não são funcionários do App.
        
        4.4. Após um show ser contratado serão fornecidas senhas para o anfitrião e o artista. O artista deverá fornecer a senha recebida na chegada ao local do evento contratado e o anfitrião por sua vez irá fornecer uma senha ao artista que deverá digitá-la no App Showtime somente quando for iniciar sua apresentação. A não digitação da senha poderá acarretar atraso no recebimento do seu cachê.
      
      5. Obrigações do artista
      
        5.1. Executar suas apresentações conforme os termos acordados com o cliente, de forma ética, profissional e dentro do prazo combinado. O tempo gasto para a montagem e desmontagem dos equipamentos necessários para a realização da apresentação contratada não contam como tempo dela. Todos os equipamentos deverão ser desmontados e levados do local logo após o término da apresentação.
        
        5.2. Garantir que todo o conteúdo publicado no aplicativo, como imagens, descrições e portfólio, esteja em conformidade com a legislação vigente e não infrinja direitos de terceiros.
        
        5.3. Manter suas informações de cadastro atualizadas. O uso indevido do aplicativo por terceiros será de responsabilidade do artista, a senha de acesso é pessoal e não deverá ser fornecida a terceiros.
        
        5.4. Não trocar de números de celulares, email, skype ou qualquer forma de contato externa do aplicativo. Toda a comunicação entre os anfitriões e os artistas deverá ser feita por troca de mensagens dentro do App. Tentativas de burlar essa regra poderão ser penalizadas com suspensão e até mesmo a exclusão dele.
        
      6. Propriedade Intelectual
        
        6.1. O artista concede ao aplicativo permissão de exibir, divulgar e promover os serviços descritos em seu perfil e nas apresentações contratadas através de imagens e vídeos em redes sociais, internet e demais canais que o aplicativo julgar conveniente. O artista está ciente que o contratante poderá avaliar a apresentação do artista após ela ser finalizada e consente que a nota de avaliação esteja disponível para todos os usuários do aplicativo.
        
        6.2. Todo o conteúdo disponibilizado pelo artista é de sua exclusiva responsabilidade, devendo este garantir que possui os direitos necessários para utilizá-lo. Os vídeos e fotos das apresentações dos artistas que forem carregados no aplicativo não deverão conter imagens de terceiros sem que eles tenham previamente autorizado a divulgação.
        
      7. Proteção de Dados
      
        7.1. O Aplicativo tratará os dados pessoais do artista em conformidade com a Lei Geral de Proteção de Dados (LGPD).
        
        7.2. O artista pode solicitar a exclusão de seus dados a qualquer momento, mediante solicitação formal.
        
      8. Rescisão e Exclusão de Conta
      
        8.1. O Aplicativo se reserva o direito de suspender ou excluir a conta do artista que viole estes Termos de Uso ou a legislação aplicável.
        8.2. O artista pode solicitar a exclusão de sua conta a qualquer momento, sem ônus.
      
      9. Limitação de Responsabilidade
      
        O Aplicativo não se responsabiliza por danos decorrentes de:
        a) Serviços prestados de forma inadequada pelo artista;
        b) Cancelamentos, atrasos ou problemas nas transações entre artistas e clientes: O contratante poderá solicitar o cancelamento ou reagendamento da apresentação, nesses casos a política será:
        
      10. Cancelamentos:
        
        a) Cancelamentos feitos até 30 dias para a hora do evento: o artista não receberá nenhuma compensação.
        b) Cancelamentos feitos com menos de 30 dias até 15 dias para a hora do evento: o artista receberá 40% do valor pago pela apresentação.
        c) Cancelamentos feitos com menos de 15 dias para a hora do evento: o artista irá receber 90% do valor pago pela apresentação.
        
        Em casos de força maior, como por exemplo, incêndio no local da apresentação que impeça o evento, tempestade que impeça o deslocamento dos artistas, morte de parentes próximos do anfitrião (pais, filhos, cônjuges) com menos de 30 dias para o evento, o contratante poderá solicitar o cancelamento do evento ou o seu reagendamento sem que nenhum pagamento seja devido aos artistas. Em caso de doença, acidente, ou qualquer problema que impeça o artista se apresentar ele deverá de imediato avisar ao contratante e ao aplicativo Showtime que poderá indicar um substituto desde que o contratante esteja de acordo, nesse caso o pagamento será efetuado diretamente ao artista substituto.
        
      11. Disposições Gerais
        
        11.1. Este Termo pode ser atualizado a qualquer momento, com aviso prévio aos usuários.
      
        11.2. Eventuais conflitos serão resolvidos no foro da comarca da cidade do Rio de Janeiro salvo disposição legal em contrário.
        
        Em caso de dúvidas, entre em contato pelo suporte disponível no aplicativo Showtime ou email suporte@showtime.app.br.
      ''',
    );
  }
}


