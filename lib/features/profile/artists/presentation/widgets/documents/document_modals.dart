import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
// TODO: Adicionar file_picker ao pubspec.yaml
// import 'package:file_picker/file_picker.dart';

class DocumentModals {
  /// Modal para documento de identidade
  static Future<void> showIdentityModal({
    required BuildContext context,
    required DocumentsEntity document,
    required Function(DocumentsEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IdentityDocumentModal(
        document: document,
        onSave: onSave,
      ),
    );
  }

  /// Modal para comprovante de residência
  static Future<void> showResidenceModal({
    required BuildContext context,
    required DocumentsEntity document,
    required Function(DocumentsEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResidenceDocumentModal(
        document: document,
        onSave: onSave,
      ),
    );
  }

  /// Modal para currículo
  static Future<void> showCurriculumModal({
    required BuildContext context,
    required DocumentsEntity document,
    required Function(DocumentsEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurriculumDocumentModal(
        document: document,
        onSave: onSave,
      ),
    );
  }

  /// Modal para certidão de antecedentes
  static Future<void> showAntecedentsModal({
    required BuildContext context,
    required DocumentsEntity document,
    required Function(DocumentsEntity) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AntecedentsDocumentModal(
        document: document,
        onSave: onSave,
      ),
    );
  }
}

// Modal de Identidade
class _IdentityDocumentModal extends StatefulWidget {
  final DocumentsEntity document;
  final Function(DocumentsEntity) onSave;

  const _IdentityDocumentModal({
    required this.document,
    required this.onSave,
  });

  @override
  State<_IdentityDocumentModal> createState() => _IdentityDocumentModalState();
}

class _IdentityDocumentModalState extends State<_IdentityDocumentModal> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  String? _selectedDocumentOption;
  final List<String> _options = DocumentsEntityOptions.identityDocumentOptions();
  final ImagePickerService _imagePicker = ImagePickerService();

  @override
  void initState() {
    super.initState();
    _idNumberController.text = widget.document.idNumber ?? '';
    _selectedDocumentOption = widget.document.documentOption;
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_formKey.currentState!.validate() && _selectedDocumentOption != null) {
      final file = await _imagePicker.pickImageFromGallery();
      if (file != null && mounted) {
        final document = DocumentsEntity(
          documentType: widget.document.documentType,
          documentOption: _selectedDocumentOption!,
          url: file.path,
          status: 1,
          idNumber: _idNumberController.text,
        );
        widget.onSave(document);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento enviado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identidade',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: bottomPadding + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informe o número do documento e selecione o tipo.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(24),
                    CustomTextField(
                      controller: _idNumberController,
                      label: 'Número do Documento',
                      validator: Validators.validateIsNull,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    CustomDropdownButton(
                      labelText: 'Tipo de Documento',
                      itemsList: _options,
                      selectedValue: _selectedDocumentOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentOption = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o tipo de documento';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  label: 'Enviar Documento',
                  icon: Icons.upload_file,
                  iconOnLeft: true,
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal de Residência
class _ResidenceDocumentModal extends StatefulWidget {
  final DocumentsEntity document;
  final Function(DocumentsEntity) onSave;

  const _ResidenceDocumentModal({
    required this.document,
    required this.onSave,
  });

  @override
  State<_ResidenceDocumentModal> createState() => _ResidenceDocumentModalState();
}

class _ResidenceDocumentModalState extends State<_ResidenceDocumentModal> {
  final _formKey = GlobalKey<FormState>();
  final _zipController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  String? _selectedDocumentOption;
  final List<String> _options = DocumentsEntityOptions.residenceDocumentOptions();
  final ImagePickerService _imagePicker = ImagePickerService();

  @override
  void initState() {
    super.initState();
    if (widget.document.address != null) {
      final addr = widget.document.address!;
      _zipController.text = addr.zipCode;
      _streetController.text = addr.street ?? '';
      _numberController.text = addr.number ?? '';
      _complementController.text = addr.complement ?? '';
      _cityController.text = addr.city ?? '';
      _stateController.text = addr.state ?? '';
      _districtController.text = addr.district ?? '';
    }
    _selectedDocumentOption = widget.document.documentOption;
  }

  @override
  void dispose() {
    _zipController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_formKey.currentState!.validate() && _selectedDocumentOption != null) {
      final file = await _imagePicker.pickImageFromGallery();
      if (file != null && mounted) {
        final address = AddressInfoEntity(
          title: 'Residência',
          zipCode: _zipController.text,
          street: _streetController.text,
          number: _numberController.text,
          complement: _complementController.text.isEmpty ? null : _complementController.text,
          city: _cityController.text,
          state: _stateController.text,
          district: _districtController.text,
        );
        final document = DocumentsEntity(
          documentType: widget.document.documentType,
          documentOption: _selectedDocumentOption!,
          url: file.path,
          status: 1,
          address: address,
        );
        widget.onSave(document);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento enviado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comprovante de Residência',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: bottomPadding + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informe o endereço que será verificado no comprovante.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(24),
                    CustomTextField(
                      controller: _zipController,
                      label: 'CEP',
                      validator: Validators.validateIsNull,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    CustomTextField(
                      controller: _streetController,
                      label: 'Rua',
                      validator: Validators.validateIsNull,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    CustomTextField(
                      controller: _districtController,
                      label: 'Bairro',
                      validator: Validators.validateIsNull,
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _numberController,
                            label: 'Número',
                            validator: Validators.validateIsNull,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(16),
                        Expanded(
                          child: CustomTextField(
                            controller: _complementController,
                            label: 'Complemento (opcional)',
                          ),
                        ),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'Cidade',
                            validator: Validators.validateIsNull,
                          ),
                        ),
                        DSSizedBoxSpacing.horizontal(16),
                        Expanded(
                          child: CustomTextField(
                            controller: _stateController,
                            label: 'Estado',
                            validator: Validators.validateIsNull,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              UpperCaseTextFormatter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DSSizedBoxSpacing.vertical(24),
                    CustomDropdownButton(
                      labelText: 'Tipo de Documento',
                      itemsList: _options,
                      selectedValue: _selectedDocumentOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentOption = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o tipo de documento';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  label: 'Enviar Documento',
                  icon: Icons.upload_file,
                  iconOnLeft: true,
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal de Currículo
class _CurriculumDocumentModal extends StatefulWidget {
  final DocumentsEntity document;
  final Function(DocumentsEntity) onSave;

  const _CurriculumDocumentModal({
    required this.document,
    required this.onSave,
  });

  @override
  State<_CurriculumDocumentModal> createState() => _CurriculumDocumentModalState();
}

class _CurriculumDocumentModalState extends State<_CurriculumDocumentModal> {
  String? _selectedDocumentOption;
  final List<String> _options = DocumentsEntityOptions.curriculumDocumentOptions();

  Future<void> _pickPdf() async {
    if (_selectedDocumentOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de documento')),
      );
      return;
    }

    // TODO: Implementar file_picker quando adicionado ao pubspec.yaml
    // Por enquanto, mostra mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de PDF será implementada com file_picker')),
    );
    
    // Código futuro:
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    //   allowMultiple: false,
    // );
    // if (result != null && result.files.isNotEmpty) {
    //   final filePath = result.files.single.path;
    //   if (filePath != null && mounted) {
    //     final document = DocumentsEntity(
    //       documentType: widget.document.documentType,
    //       documentOption: _selectedDocumentOption!,
    //       url: filePath,
    //       status: 1,
    //     );
    //     widget.onSave(document);
    //     Navigator.of(context).pop();
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Documento enviado com sucesso!')),
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Currículo',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para prosseguir com a verificação, você precisa enviar seu currículo de artista em formato PDF.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(24),
                  CustomDropdownButton(
                    labelText: 'Tipo de Documento',
                    itemsList: _options,
                    selectedValue: _selectedDocumentOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedDocumentOption = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                label: 'Enviar PDF',
                icon: Icons.upload_file,
                iconOnLeft: true,
                onPressed: _pickPdf,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal de Antecedentes
class _AntecedentsDocumentModal extends StatefulWidget {
  final DocumentsEntity document;
  final Function(DocumentsEntity) onSave;

  const _AntecedentsDocumentModal({
    required this.document,
    required this.onSave,
  });

  @override
  State<_AntecedentsDocumentModal> createState() => _AntecedentsDocumentModalState();
}

class _AntecedentsDocumentModalState extends State<_AntecedentsDocumentModal> {
  Future<void> _pickPdf() async {
    // TODO: Implementar file_picker quando adicionado ao pubspec.yaml
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de PDF será implementada com file_picker')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Certidão de Antecedentes',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomPadding + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para prosseguir com a verificação, você precisa enviar sua Certidão de Antecedentes Criminais da Polícia Federal em formato PDF.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Emita sua certidão no link: '),
                        TextSpan(
                          text: 'https://servicos.pf.gov.br/epol-sinic-publico/',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse('https://servicos.pf.gov.br/epol-sinic-publico/'),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomPadding > 0 ? bottomPadding + 16 : 16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                label: 'Enviar Certidão PDF',
                icon: Icons.upload_file,
                iconOnLeft: true,
                onPressed: _pickPdf,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper para formatação de texto em maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

