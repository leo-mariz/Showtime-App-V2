import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/authentication/presentation/widgets/auth_base_page.dart';
import 'package:app/features/authentication/presentation/widgets/progress_indicator.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/profile_selection_step.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/basic_info_step.dart';
import 'package:app/features/authentication/presentation/widgets/onboarding_steps/terms_step.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:app/features/authentication/presentation/bloc/events/auth_events.dart';
import 'package:app/features/authentication/presentation/bloc/states/auth_states.dart';
import 'package:app/features/profile/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/core/users/presentation/bloc/users_bloc.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
import 'package:app/core/users/domain/entities/cnpj/cnpj_user_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/features/authentication/domain/entities/register_entity.dart';

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
  
  // Controller nome artístico (apenas para artistas)
  final _artistNameController = TextEditingController();
  
  // Estado CPF
  String? _selectedGender;
  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Não informar'];
  
  // Estados de termos
  bool _isTermsOfUseAccepted = false;
  bool _isPrivacyPolicyAccepted = false;
  
  // Estados de validação
  bool _showTermsError = false;
  bool _isLoading = false;
  bool _isDocumentValid = false; // Indica se documento está validado e disponível
  bool _hasDocumentBeenVerified = false; // Indica se a verificação no banco já foi realizada
  bool _isArtistNameValid = true; // Indica se nome artístico está válido (opcional, então começa como true)
  

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
    _artistNameController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
        BlocProvider.value(
          value: context.read<ArtistsBloc>(),
        ),
        BlocProvider.value(
          value: context.read<UsersBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterOnboardingLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthInitial) {
          setState(() {
            _isLoading = false;
          });
        }
        if (state is AuthSuccess) {
          context.showSuccess(state.message);
          context.router.replace(NavigationRoute(isArtist: _isArtist!));
        } else if (state is AuthFailure) {
          context.showError(state.error);
          setState(() => _isLoading = false);
        } else if (state is AuthConnectionFailure) {
          context.showError(state.message);
          setState(() => _isLoading = false);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is RegisterOnboardingLoading || _isLoading;
          
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
              _buildNavigationButtons(isLoading),
            ],
          );
        },
      ),
      ),
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
          artistNameController: _isArtist! ? _artistNameController : null,
          selectedGender: _selectedGender,
          genderOptions: _genderOptions,
          onDocumentTypeChanged: (isCnpj) {
            setState(() {
              _isCnpj = isCnpj;
              _hasDocumentBeenVerified = false; // Reset quando muda tipo de documento
              _isDocumentValid = false;
            });
          },
          onGenderChanged: (gender) {
            setState(() => _selectedGender = gender);
          },
          isCnpj: _isCnpj,
          onDocumentValidationChanged: (isValid) {
            setState(() {
              _isDocumentValid = isValid;
              _hasDocumentBeenVerified = true; // Marca que a verificação foi realizada
            });
          },
          onArtistNameValidationChanged: _isArtist!
              ? (isValid) {
                  setState(() => _isArtistNameValid = isValid);
                }
              : null,
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

  Widget _buildNavigationButtons(bool isLoading) {
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
              textColor: colorScheme.onPrimaryContainer,
              onPressed: isLoading ? null : _handlePrevious,
            ),
          ),
        
        if (_currentStep >= 0) DSSizedBoxSpacing.horizontal(16),
        
        // Botão Próximo/Finalizar
        if (_currentStep >= 0)
          Expanded(
            child: CustomButton(
              label: isLoading 
                  ? (_currentStep == _totalSteps - 1 ? 'Finalizando...' : 'Carregando...')
                  : (_currentStep == _totalSteps - 1 ? 'Finalizar' : 'Próximo'),
              filled: true,
              onPressed: isLoading ? null : _handleNext,
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
      // Validar formulário (vazio, formato inválido, etc)
      if (!(_formKey.currentState?.validate() ?? false)) {
        return; // O validator já mostrou a mensagem de erro apropriada
      }
      
      // Só verificar disponibilidade no banco se o documento foi verificado
      if (_hasDocumentBeenVerified && !_isDocumentValid) {
        // Documento foi verificado no banco e já está em uso
        final documentType = _isCnpj ? 'CNPJ' : 'CPF';
        context.showError('Este $documentType já está em uso');
        return;
      }
      
      // Se o documento ainda não foi verificado no banco, aguardar
      if (!_hasDocumentBeenVerified) {
        final documentType = _isCnpj ? 'CNPJ' : 'CPF';
        context.showError('Por favor, aguarde a verificação do $documentType');
        return;
      }
      
      // Validar nome artístico se for artista e tiver preenchido
      if (_isArtist == true && _artistNameController.text.trim().isNotEmpty && !_isArtistNameValid) {
        context.showError('Por favor, verifique se o nome artístico está disponível antes de continuar');
        return;
      }
      
      setState(() => _currentStep++);
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
    // Criar UserEntity
    final user = UserEntity(
      email: widget.email,
      phoneNumber: _phoneNumberController.text.trim(),
      isCnpj: _isCnpj,
      isArtist: _isArtist,
      agreedToPrivacyPolicy: _isPrivacyPolicyAccepted,
      cpfUser: _isCnpj
          ? null
          : CpfUserEntity(
              cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
              firstName: _nameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              birthDate: _birthdateController.text.trim(),
              gender: _selectedGender,
            ),
      cnpjUser: _isCnpj
          ? CnpjUserEntity(
              cnpj: _cnpjController.text.replaceAll(RegExp(r'[^\d]'), ''),
              companyName: _companyNameController.text.trim(),
              fantasyName: _fantasyNameController.text.trim(),
              stateRegistration: _stateRegistrationController.text.trim(),
            )
          : null,
    );

    // Criar ArtistEntity ou ClientEntity
    final artist = _isArtist == true
        ? ArtistEntity.defaultEntity().copyWith(
            artistName: _artistNameController.text.trim().isNotEmpty
                ? _artistNameController.text.trim()
                : null,
          )
        : ArtistEntity.defaultEntity();
    
    final client = ClientEntity.defaultClientEntity();

    // Criar RegisterEntity
    final register = RegisterEntity(
      user: user,
      artist: artist,
      client: client,
    );

    // Enviar para o bloc
    context.read<AuthBloc>().add(RegisterUserOnboardingEvent(register: register));
  }
}

