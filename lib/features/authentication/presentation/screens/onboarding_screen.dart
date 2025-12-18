import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/features/authentication/presentation/widgets/progress_indicator.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/profile_selection_step.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/basic_info_step.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/terms_step.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';

@RoutePage(deferredLoading: true)
class OnboardingScreen extends StatefulWidget {
  final String email;

  const OnboardingScreen({
    super.key,
    required this.email,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controle de steps
  int _currentStep = -1; // -1 = seleção de perfil, 0 = dados, 1 = termos
  final int _totalSteps = 2; // Dados + Termos (sem contar seleção de perfil)
  
  // Estado do usuário
  bool? _isArtist;
  bool _isCnpj = false;
  
  // Form key para validação
  final _formKey = GlobalKey<FormState>();
  
  // Controllers CPF
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthdateController = TextEditingController();
  
  // Controllers CNPJ
  final _cnpjController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _fantasyNameController = TextEditingController();
  final _stateRegistrationController = TextEditingController();
  
  // Controllers compartilhados
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  // Estado CPF
  String? _selectedGender;
  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Não informar'];
  
  // Estados de termos
  bool _isTermsOfUseAccepted = false;
  bool _isPrivacyPolicyAccepted = false;
  
  // Estados de validação
  bool _showTermsError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    // Controllers CPF
    _nameController.dispose();
    _lastNameController.dispose();
    _cpfController.dispose();
    _birthdateController.dispose();
    
    // Controllers CNPJ
    _cnpjController.dispose();
    _companyNameController.dispose();
    _fantasyNameController.dispose();
    _stateRegistrationController.dispose();
    
    // Controllers compartilhados
    _emailController.dispose();
    _phoneNumberController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBasePage(
      title: _getTitle(),
      subtitle: _getSubtitle(),
      showBackButton: _currentStep < 0,
      children: [
        // Progress Indicator (só aparece após seleção de perfil)
        if (_currentStep >= 0) ...[
          ProgressIndicatorWidget(
            totalSteps: _totalSteps,
            currentStep: _currentStep,
          ),
          DSSizedBoxSpacing.vertical(16),
        ],        
        // // Conteúdo do step atual
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _buildCurrentStep(),
        ),
        
        DSSizedBoxSpacing.vertical(32),
        
        // Botões de navegação
        _buildNavigationButtons(),
      ],
    );
  }

  String _getTitle() {
    if (_currentStep == -1) return 'QUEM É VOCÊ NESSE PALCO?';
    if (_currentStep == 0) return 'DADOS PESSOAIS';
    return 'TERMOS E PRIVACIDADE';
  }

  String _getSubtitle() {
    if (_currentStep == -1) return 'Escolha seu perfil';
    if (_currentStep == 0) return 'Preencha suas informações';
    return 'Aceite os termos para continuar';
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      -1 => ProfileSelectionStep(
          key: const ValueKey('profile'),
          onProfileSelected: _handleProfileSelected,
        ),
      0 => BasicInfoStep(
          key: const ValueKey('basic-info'),
          formKey: _formKey,
          isArtist: _isArtist!,
          nameController: _nameController,
          lastNameController: _lastNameController,
          emailController: _emailController,
          phoneNumberController: _phoneNumberController,
          cpfController: _cpfController,
          birthdateController: _birthdateController,
          cnpjController: _cnpjController,
          companyNameController: _companyNameController,
          fantasyNameController: _fantasyNameController,
          stateRegistrationController: _stateRegistrationController,
          selectedGender: _selectedGender,
          genderOptions: _genderOptions,
          onDocumentTypeChanged: (isCnpj) {
            setState(() => _isCnpj = isCnpj);
          },
          onGenderChanged: (gender) {
            setState(() => _selectedGender = gender);
          },
          isCnpj: _isCnpj,
        ),
      1 => TermsStep(
          key: const ValueKey('terms'),
          isArtist: _isArtist!,
          isTermsOfUseAccepted: _isTermsOfUseAccepted,
          isPrivacyPolicyAccepted: _isPrivacyPolicyAccepted,
          onTermsOfUseChanged: (value) {
            setState(() {
              _isTermsOfUseAccepted = value;
              _showTermsError = false;
            });
          },
          onPrivacyPolicyChanged: (value) {
            setState(() {
              _isPrivacyPolicyAccepted = value;
              _showTermsError = false;
            });
          },
          showError: _showTermsError,
        ),
      _ => const SizedBox(),
    };
  }

  Widget _buildNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão Voltar
        if (_currentStep >= 0)
          Expanded(
            child: CustomButton(
              label: 'Voltar',
              filled: false,
              // backgroundColor: colorScheme.surfaceContainerHighest,
              textColor: colorScheme.onPrimaryContainer,
              // icon: Icons.arrow_back_ios_new_outlined,
              // iconOnLeft: true,
              onPressed: _isLoading ? () {} : _handlePrevious,
            ),
          ),
        
        if (_currentStep >= 0) DSSizedBoxSpacing.horizontal(16),
        
        // Botão Próximo/Finalizar
        if (_currentStep >= 0)
          Expanded(
            child: CustomButton(
              label: _currentStep == _totalSteps - 1 ? 'Finalizar' : 'Próximo',
              filled: true,
              // icon: Icons.arrow_forward_ios_outlined,
              // iconOnRight: true,
              onPressed: _isLoading ? () {} : _handleNext,
            ),
          ),
      ],
    );
  }

  void _handleProfileSelected(bool isArtist) {
    setState(() {
      _isArtist = isArtist;
      _currentStep = 0;
    });
  }

  void _handlePrevious() {
    if (_currentStep > -1) {
      setState(() {
        _currentStep--;
        if (_currentStep == -1) {
          _isArtist = null;
        }
      });
    }
  }

  void _handleNext() {
    // Validação do step 0 (dados básicos)
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
      return;
    }
    
    // Validação do step 1 (termos)
    if (_currentStep == 1) {
      if (_isTermsOfUseAccepted && _isPrivacyPolicyAccepted) {
        _handleSubmit();
      } else {
        setState(() => _showTermsError = true);
      }
      return;
    }
  }

  void _handleSubmit() {
    setState(() => _isLoading = true);
    
    // TODO: Implementar lógica de submissão
    // Aqui você vai criar a RegisterEntity e enviar para o backend
    
    print('=== DADOS DO ONBOARDING ===');
    print('Email: ${widget.email}');
    print('É Artista: $_isArtist');
    print('É CNPJ: $_isCnpj');
    print('Telefone: ${_phoneNumberController.text}');
    if (_isCnpj) {
      print('CNPJ: ${_cnpjController.text}');
      print('Razão Social: ${_companyNameController.text}');
      print('Nome Fantasia: ${_fantasyNameController.text}');
    } else {
      print('CPF: ${_cpfController.text}');
      print('Nome: ${_nameController.text}');
      print('Sobrenome: ${_lastNameController.text}');
      print('Data Nascimento: ${_birthdateController.text}');
      print('Gênero: $_selectedGender');
    }
    print('Termos aceitos: $_isTermsOfUseAccepted');
    print('Privacidade aceita: $_isPrivacyPolicyAccepted');
    
    // Simulação de envio
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // TODO: Navegar para próxima tela após sucesso
        // context.router.replace(HomeRoute());
      }
    });
  }
}

