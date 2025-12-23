import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/profile/shared/presentation/widgets/fields/non_editable_field.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(deferredLoading: true)
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  bool isEditingPhone = false;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  // Mock data
  final bool isCnpj = false; // Mock: pode ser alterado para true para testar CNPJ
  final String? companyName = null;
  final String? fantasyName = null;
  final String? cnpj = null;
  final String? stateRegistration = null;
  final String? cpf = '123.456.789-00';
  final String? firstName = 'João';
  final String? lastName = 'Silva';
  final String? birthDate = '15/03/1990';
  final String? gender = 'Masculino';

  @override
  Widget build(BuildContext context) {
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
                  if (isCnpj)
                    Column(
                      children: [
                        NonEditableField(title: 'Nome da Empresa', value: companyName ?? ''),
                        NonEditableField(title: 'Nome Fantasia', value: fantasyName ?? ''),
                        NonEditableField(title: 'CNPJ', value: cnpj ?? ''),
                      ],
                    ),
                  if (!isCnpj)
                    Column(
                      children: [
                        NonEditableField(title: 'CPF', value: cpf ?? ''),
                        NonEditableField(title: 'Nome', value: firstName ?? ''),
                        NonEditableField(title: 'Sobrenome', value: lastName ?? ''),
                        NonEditableField(title: 'Data de Nascimento', value: birthDate ?? ''),
                        NonEditableField(title: 'Gênero', value: gender ?? ''),
                      ],
                    ),
                ],
              ),
            ),
          );
  }
}
