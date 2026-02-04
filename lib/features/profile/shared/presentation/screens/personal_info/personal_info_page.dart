import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/features/profile/shared/presentation/widgets/fields/non_editable_field.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/users/presentation/bloc/events/users_events.dart';
import 'package:app/core/users/presentation/bloc/states/users_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  void initState() {
    super.initState();
    // Buscar dados do usuário ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleGetUserData();
    });
  }

  void _handleGetUserData({bool forceRefresh = false}) {
    final usersBloc = context.read<UsersBloc>();
    final currentState = usersBloc.state;
    print('currentState: $currentState');
    // Buscar apenas se não tiver dados carregados ou se forçado a atualizar
    if (forceRefresh || currentState is! GetUserDataSuccess) {
      print('GetUserDataEvent');
      usersBloc.add(GetUserDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<UsersBloc>(),
      child: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is GetUserDataFailure) {
            context.showError(state.error);
          }
        },
        child: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, usersState) {
            final user = usersState is GetUserDataSuccess
                ? usersState.user
                : null;

            if (user == null) {
              return BasePage(
                showAppBar: true,
                appBarTitle: 'Informações Pessoais',
                showAppBarBackButton: true,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            // Verificar se é CNPJ: primeiro pelo flag, depois pela presença de dados
            final isCnpj = user.isCnpj == true ||
                (user.isCnpj != false && user.cnpjUser != null);
            final hasCnpjData = user.cnpjUser != null;
            final hasCpfData = user.cpfUser != null;

            return BasePage(
              showAppBar: true,
              appBarTitle: 'Informações Pessoais',
              showAppBarBackButton: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSizedBoxSpacing.vertical(16),
                    NonEditableField(
                      title: 'E-mail',
                      value: user.email,
                    ),
                    if (isCnpj && hasCnpjData)
                      Column(
                        children: [
                          if (user.cnpjUser?.companyName != null && 
                              user.cnpjUser!.companyName!.isNotEmpty)
                            NonEditableField(
                              title: 'Nome da Empresa',
                              value: user.cnpjUser!.companyName!,
                            ),
                          if (user.cnpjUser?.fantasyName != null && 
                              user.cnpjUser!.fantasyName!.isNotEmpty)
                            NonEditableField(
                              title: 'Nome Fantasia',
                              value: user.cnpjUser!.fantasyName!,
                            ),
                          if (user.cnpjUser?.cnpj != null && 
                              user.cnpjUser!.cnpj!.isNotEmpty)
                            NonEditableField(
                              title: 'CNPJ',
                              value: user.cnpjUser!.cnpj!,
                            ),
                          if (user.cnpjUser?.stateRegistration != null && 
                              user.cnpjUser!.stateRegistration!.isNotEmpty)
                            NonEditableField(
                              title: 'Inscrição Estadual',
                              value: user.cnpjUser!.stateRegistration!,
                            ),
                        ],
                      ),
                    if (!isCnpj && hasCpfData)
                      Column(
                        children: [
                          if (user.cpfUser?.cpf != null && 
                              user.cpfUser!.cpf!.isNotEmpty)
                            NonEditableField(
                              title: 'CPF',
                              value: user.cpfUser!.cpf!,
                            ),
                          if (user.cpfUser?.firstName != null && 
                              user.cpfUser!.firstName!.isNotEmpty)
                            NonEditableField(
                              title: 'Nome',
                              value: user.cpfUser!.firstName!,
                            ),
                          if (user.cpfUser?.lastName != null && 
                              user.cpfUser!.lastName!.isNotEmpty)
                            NonEditableField(
                              title: 'Sobrenome',
                              value: user.cpfUser!.lastName!,
                            ),
                          if (user.cpfUser?.birthDate != null && 
                              user.cpfUser!.birthDate!.isNotEmpty)
                            NonEditableField(
                              title: 'Data de Nascimento',
                              value: user.cpfUser!.birthDate!,
                            ),
                          if (user.cpfUser?.gender != null && 
                              user.cpfUser!.gender!.isNotEmpty)
                            NonEditableField(
                              title: 'Gênero',
                              value: user.cpfUser!.gender!,
                            ),
                        ],
                      ),
                    // Se não houver dados nem de CPF nem de CNPJ
                    if (!hasCnpjData && !hasCpfData)
                      Padding(
                        padding: EdgeInsets.only(top: DSSize.height(16)),
                        child: Text(
                          'Nenhuma informação pessoal cadastrada',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
