import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/masked_sensitive_field.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Tela de dados bancários do artista
/// 
/// NOTA DE SEGURANÇA:
/// Dados bancários são extremamente sensíveis. Duas opções de armazenamento:
/// 
/// 1. Firestore (RECOMENDADO para este caso):
///    - Administradores precisam acessar os dados para realizar pagamentos
///    - Usar criptografia no lado do cliente antes de enviar ao Firestore
///    - Implementar regras de segurança do Firestore para limitar acesso
///    - Pros: Acessível para admin, estrutura já existente
///    - Contras: Requer criptografia adicional
/// 
/// 2. Secret Manager (Firebase Secret Manager / AWS Secrets Manager):
///    - Mais seguro, mas requer API adicional para acesso pelos administradores
///    - Pros: Máxima segurança
///    - Contras: Mais complexo, requer backend adicional para admin
/// 
/// Para este projeto, recomendamos Firestore com criptografia no cliente.
@RoutePage(deferredLoading: true)
class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _agencyController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _cpfOrCnpjController = TextEditingController();
  final TextEditingController _pixKeyController = TextEditingController();
  
  // Estado de edição para campos sensíveis
  bool _isEditingCpfCnpj = false;
  bool _isEditingAgency = false;
  bool _isEditingAccountNumber = false;
  bool _isEditingPixKey = false;
  
  // Dropdowns
  String? _selectedAccountType;
  String? _selectedPixType;
  
  // Máscaras
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );
  
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );
  
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'\d')},
  );

  // TODO: Carregar dados do artista (Bloc/Repository)
  @override
  void initState() {
    super.initState();
    // Mock data - substituir por dados reais
    // _loadBankAccountData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bankNameController.dispose();
    _agencyController.dispose();
    _accountNumberController.dispose();
    _cpfOrCnpjController.dispose();
    _pixKeyController.dispose();
    super.dispose();
  }

  String _maskCpfCnpj(String value) {
    if (value.isEmpty) return '';
    // Remove formatação
    final numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbersOnly.length <= 4) return '*' * numbersOnly.length;
    return '*' * (numbersOnly.length - 4) + numbersOnly.substring(numbersOnly.length - 4);
  }

  String _maskAccount(String value) {
    if (value.isEmpty) return '';
    final numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbersOnly.length <= 2) return '*' * numbersOnly.length;
    return '*' * (numbersOnly.length - 2) + numbersOnly.substring(numbersOnly.length - 2);
  }

  void _handleCpfCnpjChange(String value) {
    // Remove formatação atual
    String numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Aplica máscara apropriada
    if (numbersOnly.length > 11) {
      String formatted = _cnpjMask.maskText(numbersOnly);
      _cpfOrCnpjController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      String formatted = _cpfMask.maskText(numbersOnly);
      _cpfOrCnpjController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  List<TextInputFormatter>? _getPixKeyFormatters() {
    switch (_selectedPixType) {
      case 'CPF':
        return [_cpfMask];
      case 'CNPJ':
        return [_cnpjMask];
      case 'Telefone':
        return [_phoneMask];
      default:
        return null;
    }
  }

  bool _hasValidBankAccount() {
    final bankName = _bankNameController.text.trim();
    final agency = _agencyController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final accountType = _selectedAccountType;

    bool hasAnyBankField = bankName.isNotEmpty ||
        agency.isNotEmpty ||
        accountNumber.isNotEmpty ||
        accountType != null;

    if (hasAnyBankField) {
      return bankName.isNotEmpty &&
          agency.isNotEmpty &&
          accountNumber.isNotEmpty &&
          accountType != null;
    }

    return false;
  }

  bool _hasValidPix() {
    final pixType = _selectedPixType;
    final pixKey = _pixKeyController.text.trim();

    if (pixType == null || pixKey.isEmpty) return false;

    switch (pixType) {
      case 'CPF':
        return Validators.validateCPF(pixKey) == null;
      case 'CNPJ':
        return Validators.validateCNPJ(pixKey) == null;
      case 'Email':
        return Validators.validateEmail(pixKey) == null;
      case 'Telefone':
        return Validators.validatePhone(pixKey) == null;
      case 'Chave Aleatória':
        return Validators.validateIsNull(pixKey) == null;
      default:
        return false;
    }
  }

  String? _validateForm() {
    // Validação dos dados do titular (obrigatórios)
    if (_fullNameController.text.trim().isEmpty ||
        _cpfOrCnpjController.text.trim().isEmpty) {
      return 'Dados do titular são obrigatórios';
    }

    if (Validators.validateCPForCNPJ(_cpfOrCnpjController.text.trim()) != null) {
      return 'CPF/CNPJ inválido';
    }

    // Verifica se pelo menos um método de pagamento está preenchido
    bool hasValidBankAccount = _hasValidBankAccount();
    bool hasValidPix = _hasValidPix();

    if (hasValidPix || hasValidBankAccount) {
      return null;
    }

    return 'Preencha as informações de conta bancária ou chave PIX válidas';
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // TODO: Implementar salvamento (Bloc/Repository)
    // final bankAccount = BankAccountEntity(
    //   fullName: _fullNameController.text.trim(),
    //   bankName: _bankNameController.text.trim(),
    //   agency: _agencyController.text.trim(),
    //   accountNumber: _accountNumberController.text.trim(),
    //   accountType: _selectedAccountType,
    //   cpfOrCnpj: _cpfOrCnpjController.text.trim(),
    //   pixType: _selectedPixType,
    //   pixKey: _pixKeyController.text.trim(),
    // );
    // context.read<ProfileBloc>().add(SetArtistBankAccountEvent(bankAccount: bankAccount, profile: profile));
    
    // Mock: mostrar sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informações atualizadas com sucesso!')),
    );
    
    // Resetar estados de edição
    setState(() {
      _isEditingCpfCnpj = false;
      _isEditingAgency = false;
      _isEditingAccountNumber = false;
      _isEditingPixKey = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BasePage(
      showAppBar: true,
      appBarTitle: 'Dados Bancários',
      showAppBarBackButton: true,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forneça suas informações bancárias',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              DSSizedBoxSpacing.vertical(24),
              
              // Dados do Titular
              Text(
                'Dados do Titular',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
              
              CustomTextField(
                controller: _fullNameController,
                label: 'Nome do Titular',
                validator: Validators.validateIsNull,
              ),
              
              DSSizedBoxSpacing.vertical(16),
              
              MaskedSensitiveField(
                controller: _cpfOrCnpjController,
                label: 'CPF/CNPJ',
                maskFunction: _maskCpfCnpj,
                isEditing: _isEditingCpfCnpj,
                onEditTap: () {
                  setState(() {
                    _isEditingCpfCnpj = true;
                  });
                },
                onChanged: _handleCpfCnpjChange,
                validator: Validators.validateCPForCNPJ,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-/]')),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(24),
              
              // Agência e Conta
              Text(
                'Agência e Conta',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
              
              CustomTextField(
                controller: _bankNameController,
                label: 'Nome do Banco',
              ),
              
              DSSizedBoxSpacing.vertical(16),
              
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: MaskedSensitiveField(
                      controller: _agencyController,
                      label: 'Agência',
                      maskFunction: _maskAccount,
                      isEditing: _isEditingAgency,
                      onEditTap: () {
                        setState(() {
                          _isEditingAgency = true;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(16),
                  Expanded(
                    flex: 6,
                    child: MaskedSensitiveField(
                      controller: _accountNumberController,
                      label: 'Número da Conta',
                      maskFunction: _maskAccount,
                      isEditing: _isEditingAccountNumber,
                      onEditTap: () {
                        setState(() {
                          _isEditingAccountNumber = true;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(16),
              
              CustomDropdownButton(
                labelText: 'Tipo de Conta',
                itemsList: BankAccountEntityReference.accountTypes,
                selectedValue: _selectedAccountType,
                onChanged: (value) {
                  setState(() {
                    _selectedAccountType = value;
                  });
                },
              ),
              
              DSSizedBoxSpacing.vertical(24),
              
              // Chave Pix
              Text(
                'Chave Pix',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DSSizedBoxSpacing.vertical(16),
              
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: CustomDropdownButton(
                      labelText: 'Tipo',
                      itemsList: BankAccountEntityReference.pixTypes,
                      selectedValue: _selectedPixType,
                      onChanged: (value) {
                        setState(() {
                          _selectedPixType = value;
                          // Limpa a chave quando muda o tipo
                          _pixKeyController.clear();
                        });
                      },
                    ),
                  ),
                  DSSizedBoxSpacing.horizontal(16),
                  Expanded(
                    flex: 6,
                    child: MaskedSensitiveField(
                      controller: _pixKeyController,
                      label: 'Chave Pix',
                      maskFunction: _maskCpfCnpj,
                      isEditing: _isEditingPixKey,
                      onEditTap: () {
                        setState(() {
                          _isEditingPixKey = true;
                        });
                      },
                      inputFormatters: _getPixKeyFormatters(),
                      keyboardType: _selectedPixType == 'Email'
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                    ),
                  ),
                ],
              ),
              
              DSSizedBoxSpacing.vertical(48),
              
              CustomButton(
                label: 'Salvar',
                backgroundColor: colorScheme.onPrimaryContainer,
                textColor: colorScheme.primaryContainer,
                onPressed: _onSave,
              ),
              
              DSSizedBoxSpacing.vertical(24),
            ],
          ),
        ),
      ),
    );
  }
}

