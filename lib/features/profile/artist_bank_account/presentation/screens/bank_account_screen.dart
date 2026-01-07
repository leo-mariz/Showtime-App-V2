import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/bank_account_bloc.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/events/bank_account_events.dart';
import 'package:app/features/profile/artist_bank_account/presentation/bloc/states/bank_account_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
/// 
/// IMPORTANTE: Esta tela requer reautenticação antes de ser acessada.
@RoutePage(deferredLoading: true)
class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hasLoadedData = false;
  
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _agencyController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _cpfOrCnpjController = TextEditingController();
  final TextEditingController _pixKeyController = TextEditingController();
  
  // Dropdowns
  String? _selectedAccountType;
  String? _selectedPixType;
  
  // Valores iniciais para comparação
  String _initialFullName = '';
  String _initialBankName = '';
  String _initialAgency = '';
  String _initialAccountNumber = '';
  String _initialCpfOrCnpj = '';
  String? _initialAccountType;
  String? _initialPixType;
  String _initialPixKey = '';
  
  // Máscaras para formatação automática
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

  @override
  void initState() {
    super.initState();
    // Adicionar listeners para detectar mudanças
    _fullNameController.addListener(_onFieldChanged);
    _bankNameController.addListener(_onFieldChanged);
    _agencyController.addListener(_onFieldChanged);
    _accountNumberController.addListener(_onFieldChanged);
    _cpfOrCnpjController.addListener(_onFieldChanged);
    _pixKeyController.addListener(_onFieldChanged);
    
    // Buscar dados bancários ao carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleGetBankAccount();
      }
    });
  }

  void _onFieldChanged() {
    setState(() {
      // Força rebuild para atualizar estado do botão
    });
  }

  void _handleGetBankAccount({bool forceRefresh = false}) {
    if (!mounted) return;
    
    final bankAccountBloc = context.read<BankAccountBloc>();
    // Sempre buscar quando forçado (após atualização)
    if (forceRefresh) {
      setState(() {
        _hasLoadedData = false; // Resetar flag para permitir recarregar
      });
      bankAccountBloc.add(GetBankAccountEvent());
    } else if (bankAccountBloc.state is GetBankAccountSuccess) {
      // Se já tem dados e não foi forçado, carregar diretamente
      final state = bankAccountBloc.state as GetBankAccountSuccess;
      _loadBankAccountData(state.bankAccount);
    } else {
      // Se não tem dados, buscar
      bankAccountBloc.add(GetBankAccountEvent());
    }
  }

  void _loadBankAccountData(BankAccountEntity? bankAccount) {
    if (_hasLoadedData) return;

    setState(() {
      _hasLoadedData = true;

      // Carregar dados do titular
      _initialFullName = bankAccount?.fullName ?? '';
      _fullNameController.text = _initialFullName;
      
      _initialCpfOrCnpj = bankAccount?.cpfOrCnpj ?? '';
      _cpfOrCnpjController.text = _initialCpfOrCnpj;

      // Carregar dados bancários
      _initialBankName = bankAccount?.bankName ?? '';
      _bankNameController.text = _initialBankName;
      
      _initialAgency = bankAccount?.agency ?? '';
      _agencyController.text = _initialAgency;
      
      _initialAccountNumber = bankAccount?.accountNumber ?? '';
      _accountNumberController.text = _initialAccountNumber;
      
      _initialAccountType = bankAccount?.accountType;
      _selectedAccountType = _initialAccountType;

      // Carregar dados PIX
      _initialPixType = bankAccount?.pixType;
      _selectedPixType = _initialPixType;
      
      _initialPixKey = bankAccount?.pixKey ?? '';
      _pixKeyController.text = _initialPixKey;
    });
  }

  /// Verifica se houve mudanças nos campos
  bool _hasChanges() {
    return _fullNameController.text.trim() != _initialFullName.trim() ||
        _cpfOrCnpjController.text.trim() != _initialCpfOrCnpj.trim() ||
        _bankNameController.text.trim() != (_initialBankName.trim()) ||
        _agencyController.text.trim() != (_initialAgency.trim()) ||
        _accountNumberController.text.trim() != (_initialAccountNumber.trim()) ||
        _selectedAccountType != _initialAccountType ||
        _selectedPixType != _initialPixType ||
        _pixKeyController.text.trim() != (_initialPixKey.trim());
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _bankNameController.removeListener(_onFieldChanged);
    _agencyController.removeListener(_onFieldChanged);
    _accountNumberController.removeListener(_onFieldChanged);
    _cpfOrCnpjController.removeListener(_onFieldChanged);
    _pixKeyController.removeListener(_onFieldChanged);
    
    _fullNameController.dispose();
    _bankNameController.dispose();
    _agencyController.dispose();
    _accountNumberController.dispose();
    _cpfOrCnpjController.dispose();
    _pixKeyController.dispose();
    super.dispose();
  }

  /// Retorna o formatter apropriado para CPF/CNPJ baseado no tamanho
  List<TextInputFormatter>? _getCpfCnpjFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        final numbersOnly = text.replaceAll(RegExp(r'[^\d]'), '');
        
        String maskedText;
        if (numbersOnly.length <= 11) {
          maskedText = _cpfMask.maskText(numbersOnly);
        } else {
          maskedText = _cnpjMask.maskText(numbersOnly);
        }
        
        return TextEditingValue(
          text: maskedText,
          selection: TextSelection.collapsed(offset: maskedText.length),
        );
      }),
    ];
  }

  /// Retorna formatters apropriados para chave PIX baseado no tipo
  List<TextInputFormatter>? _getPixKeyFormatters() {
    switch (_selectedPixType) {
      case 'CPF':
        return [_cpfMask];
      case 'CNPJ':
        return [_cnpjMask];
      case 'Telefone':
        return [_phoneMask];
      case 'Email':
        return [FilteringTextInputFormatter.deny(RegExp(r'\s'))];
      case 'Chave Aleatória':
        return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))];
      default:
        return null;
    }
  }

  /// Valida se os dados bancários estão completos
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

  /// Valida se a chave PIX está válida
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

  /// Valida o formulário completo
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
      context.showError(validationError);
      return;
    }

    // Criar entidade com os dados do formulário
    final bankAccount = BankAccountEntity(
      fullName: _fullNameController.text.trim(),
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      agency: _agencyController.text.trim().isEmpty ? null : _agencyController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty ? null : _accountNumberController.text.trim(),
      accountType: _selectedAccountType,
      cpfOrCnpj: _cpfOrCnpjController.text.trim(),
      pixType: _selectedPixType,
      pixKey: _pixKeyController.text.trim().isEmpty ? null : _pixKeyController.text.trim(),
    );

    // Disparar evento para salvar dados bancários
    context.read<BankAccountBloc>().add(
      SaveBankAccountEvent(bankAccount: bankAccount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<BankAccountBloc, BankAccountState>(
      listener: (context, state) {
        if (state is GetBankAccountLoading) {
          // Loading é tratado no BlocBuilder
        } else if (state is GetBankAccountSuccess) {
          // Carregar dados bancários
          _loadBankAccountData(state.bankAccount);
        } else if (state is GetBankAccountFailure) {
          context.showError(state.error);
        } else if (state is SaveBankAccountLoading) {
          // Loading é tratado no BlocBuilder
        } else if (state is SaveBankAccountSuccess) {
          context.showSuccess('Dados bancários salvos com sucesso!');
          // Recarregar dados atualizados e voltar
          _handleGetBankAccount(forceRefresh: true);
          AutoRouter.of(context).maybePop();
        } else if (state is SaveBankAccountFailure) {
          context.showError(state.error);
        }
      },
      child: BlocBuilder<BankAccountBloc, BankAccountState>(
        builder: (context, state) {
          final isLoading = state is SaveBankAccountLoading;
          final hasChanges = _hasChanges();
          final isLoadingInitial = state is GetBankAccountLoading;

          return BasePage(
            showAppBar: true,
            appBarTitle: 'Dados Bancários',
            showAppBarBackButton: true,
            child: isLoadingInitial
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () {
                      // Fechar teclado ao tocar em qualquer lugar da tela
                      FocusScope.of(context).unfocus();
                    },
                    behavior: HitTestBehavior.opaque,
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
                            enabled: !isLoading,
                          ),
                          
                          DSSizedBoxSpacing.vertical(16),
                          
                          CustomTextField(
                            controller: _cpfOrCnpjController,
                            label: 'CPF/CNPJ',
                            validator: Validators.validateCPForCNPJ,
                            inputFormatters: _getCpfCnpjFormatters(),
                            keyboardType: TextInputType.number,
                            enabled: !isLoading,
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
                            enabled: !isLoading,
                          ),
                          
                          DSSizedBoxSpacing.vertical(16),
                          
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: CustomTextField(
                                  controller: _agencyController,
                                  label: 'Agência',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                  enabled: !isLoading,
                                ),
                              ),
                              DSSizedBoxSpacing.horizontal(16),
                              Expanded(
                                flex: 6,
                                child: CustomTextField(
                                  controller: _accountNumberController,
                                  label: 'Número da Conta',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                  enabled: !isLoading,
                                ),
                              ),
                            ],
                          ),
                          
                          DSSizedBoxSpacing.vertical(16),
                          
                          CustomDropdownButton(
                            labelText: 'Tipo de Conta',
                            itemsList: BankAccountEntityReference.accountTypes,
                            selectedValue: _selectedAccountType,
                            onChanged: isLoading ? (_) {} : (value) {
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: CustomDropdownButton(
                                  labelText: 'Tipo',
                                  itemsList: BankAccountEntityReference.pixTypes,
                                  selectedValue: _selectedPixType,
                                  onChanged: isLoading ? (_) {} : (value) {
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
                                child: CustomTextField(
                                  controller: _pixKeyController,
                                  label: 'Chave Pix',
                                  inputFormatters: _getPixKeyFormatters(),
                                  keyboardType: _selectedPixType == 'Email'
                                      ? TextInputType.emailAddress
                                      : _selectedPixType == 'Telefone' || 
                                        _selectedPixType == 'CPF' || 
                                        _selectedPixType == 'CNPJ'
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  enabled: !isLoading,
                                  validator: (value) {
                                    if (_selectedPixType == null) {
                                      return null; // Não validar se tipo não foi selecionado
                                    }
                                    switch (_selectedPixType) {
                                      case 'CPF':
                                        return Validators.validateCPF(value?.trim());
                                      case 'CNPJ':
                                        return Validators.validateCNPJ(value?.trim());
                                      case 'Email':
                                        return Validators.validateEmail(value?.trim());
                                      case 'Telefone':
                                        return Validators.validatePhone(value?.trim());
                                      case 'Chave Aleatória':
                                        return Validators.validateIsNull(value?.trim());
                                      default:
                                        return null;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          DSSizedBoxSpacing.vertical(48),
                          
                          CustomButton(
                            label: 'Salvar',
                            backgroundColor: colorScheme.onPrimaryContainer,
                            textColor: colorScheme.primaryContainer,
                            onPressed: (hasChanges && !isLoading) ? _onSave : null,
                            isLoading: isLoading,
                          ),
                          
                          DSSizedBoxSpacing.vertical(24),
                        ],
                      ),
                    ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
