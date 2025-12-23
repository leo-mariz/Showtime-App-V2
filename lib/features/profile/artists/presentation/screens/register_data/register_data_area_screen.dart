
import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage(deferredLoading: true)
class RegisterDataAreaScreen extends StatelessWidget {
  const RegisterDataAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final router = AutoRouter.of(context);

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Dados Cadastrais',
      showAppBarBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opção: Dados Profissionais 
            ArtistAreaOptionCard(
              title: 'Documentos',
              description: 'Faça o envio dos seus documentos.',
              icon: Icons.document_scanner,
              iconColor: onPrimaryContainer,
              onTap: () {
                router.push(const DocumentsRoute());
              },
            ),

            DSSizedBoxSpacing.vertical(8),

            // Opção: Apresentações
            ArtistAreaOptionCard(
              title: 'Dados Bancários',
              description: 'Adicione seus dados bancários para receber pagamentos.',
              icon: Icons.payments,
              iconColor: onPrimaryContainer,
              onTap: () {
                router.push(const BankAccountRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}

