import 'dart:io';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/dropdown_button.dart';
import 'package:app/core/shared/widgets/selection_modal.dart';
import 'package:app/core/shared/widgets/text_field.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum para opções de fonte de arquivo
enum DocumentFileSource {
  file,
  gallery,
}

class DocumentModals {
  /// Modal para documento de identidade
  static Future<void> showIdentityModal({
    required BuildContext context,
    required DocumentsEntity document,
    required Function(DocumentsEntity, String?) onSave,
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
    required Function(DocumentsEntity, String?) onSave,
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
    required Function(DocumentsEntity, String?) onSave,
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
    required Function(DocumentsEntity, String?) onSave,
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
  final Function(DocumentsEntity, String?) onSave;

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
  File? _selectedFile;
  String? _fileName;

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

  bool get _isFormValid {
    // Validação simples para habilitar botão - validação completa só no submit
    return _idNumberController.text.trim().isNotEmpty &&
        _selectedDocumentOption != null &&
        _selectedFile != null;
  }

  Future<void> _showFileSourceModal() async {
    final source = await SelectionModal.show<DocumentFileSource>(
      context: context,
      title: 'Selecionar arquivo',
      options: [
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.insert_drive_file,
          title: 'Arquivo',
          value: DocumentFileSource.file,
        ),
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.photo_library,
          title: 'Galeria',
          value: DocumentFileSource.gallery,
        ),
      ],
    );

    if (source != null && mounted) {
      if (source == DocumentFileSource.file) {
        await _pickFile();
      } else {
        await _pickFromGallery();
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final pickedFile = result.files.single;
        if (pickedFile.path != null) {
          setState(() {
            _selectedFile = File(pickedFile.path!);
            _fileName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
      final file = await _imagePicker.pickImageFromGallery();
      if (file != null && mounted) {
      setState(() {
        _selectedFile = file;
        _fileName = file.path.split('/').last;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _handleSubmit() async {
    // Validar formulário apenas quando clicar no botão
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedDocumentOption == null) {
      context.showError('Selecione o tipo de documento');
      return;
    }

    if (_selectedFile == null) {
      context.showError('Selecione um arquivo');
      return;
    }

    if (mounted) {
        final document = DocumentsEntity(
          documentType: widget.document.documentType,
          documentOption: _selectedDocumentOption!,
        url: widget.document.url, // Mantém URL original (será atualizada após upload)
          status: 1,
        idNumber: _idNumberController.text.trim(),
        );
      widget.onSave(document, _selectedFile!.path);
        Navigator.of(context).pop();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
              child: Container(
                width: DSSize.width(40),
                height: DSSize.height(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(DSSize.width(2)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
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
                  left: DSSize.width(16),
                  right: DSSize.width(16),
                  top: DSSize.height(16),
                  bottom: bottomPadding + DSSize.height(16),
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
                    DSSizedBoxSpacing.vertical(24),
                    // Área de upload
                    Text(
                      'Arquivo',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    GestureDetector(
                      onTap: _showFileSourceModal,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(DSSize.width(16)),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(DSSize.width(12)),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: _selectedFile == null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    color: colorScheme.onPrimaryContainer,
                                    size: DSSize.width(24),
                                  ),
                                  DSSizedBoxSpacing.horizontal(12),
                                  Expanded(
                                    child: Text(
                                      'Clique para selecionar arquivo (PDF ou Imagem)',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    _fileName?.toLowerCase().endsWith('.pdf') == true
                                        ? Icons.picture_as_pdf
                                        : Icons.image,
                                    color: colorScheme.primary,
                                    size: DSSize.width(24),
                                  ),
                                  DSSizedBoxSpacing.horizontal(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _fileName ?? 'Arquivo selecionado',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        DSSizedBoxSpacing.vertical(2),
                                        Text(
                                          'Toque para alterar',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: colorScheme.error,
                                      size: DSSize.width(20),
                                    ),
                                    onPressed: _removeFile,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding > 0 ? bottomPadding + DSSize.height(16) : DSSize.height(16),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: DSSize.width(10),
                    offset: Offset(0, -DSSize.height(2)),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  label: 'Enviar',
                  icon: Icons.send,
                  iconOnLeft: true,
                  onPressed: _isFormValid ? _handleSubmit : null,
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
  final Function(DocumentsEntity, String?) onSave;

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
  File? _selectedFile;
  String? _fileName;

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

  bool get _isFormValid {
    // Validação simples para habilitar botão - validação completa só no submit
    final zipCode = _zipController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    return zipCode.isNotEmpty &&
        _streetController.text.trim().isNotEmpty &&
        _districtController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _selectedDocumentOption != null &&
        _selectedFile != null;
  }

  Future<void> _showFileSourceModal() async {
    final source = await SelectionModal.show<DocumentFileSource>(
      context: context,
      title: 'Selecionar arquivo',
      options: [
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.insert_drive_file,
          title: 'Arquivo',
          value: DocumentFileSource.file,
        ),
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.photo_library,
          title: 'Galeria',
          value: DocumentFileSource.gallery,
        ),
      ],
    );

    if (source != null && mounted) {
      if (source == DocumentFileSource.file) {
        await _pickFile();
      } else {
        await _pickFromGallery();
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final pickedFile = result.files.single;
        if (pickedFile.path != null) {
          setState(() {
            _selectedFile = File(pickedFile.path!);
            _fileName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
      final file = await _imagePicker.pickImageFromGallery();
      if (file != null && mounted) {
      setState(() {
        _selectedFile = file;
        _fileName = file.path.split('/').last;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _handleSubmit() async {
    // Validar formulário apenas quando clicar no botão
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedDocumentOption == null) {
      context.showError('Selecione o tipo de documento');
      return;
    }

    if (_selectedFile == null) {
      context.showError('Selecione um arquivo');
      return;
    }

    if (mounted) {
        final address = AddressInfoEntity(
          title: 'Residência',
        zipCode: _zipController.text.trim(),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        complement: _complementController.text.trim().isEmpty 
            ? null 
            : _complementController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        );
        final document = DocumentsEntity(
          documentType: widget.document.documentType,
          documentOption: _selectedDocumentOption!,
        url: widget.document.url, // Mantém URL original (será atualizada após upload)
          status: 1,
          address: address,
        );
      widget.onSave(document, _selectedFile!.path);
        Navigator.of(context).pop();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
              child: Container(
                width: DSSize.width(40),
                height: DSSize.height(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(DSSize.width(2)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                    'Comprovante de Residência',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  left: DSSize.width(16),
                  right: DSSize.width(16),
                  top: DSSize.height(16),
                  bottom: bottomPadding + DSSize.height(16),
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
                    DSSizedBoxSpacing.vertical(24),
                    // Área de upload
                    Text(
                      'Arquivo',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    GestureDetector(
                      onTap: _showFileSourceModal,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(DSSize.width(16)),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(DSSize.width(12)),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: _selectedFile == null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    color: colorScheme.onPrimaryContainer,
                                    size: DSSize.width(24),
                                  ),
                                  DSSizedBoxSpacing.horizontal(12),
                                  Expanded(
                                    child: Text(
                                      'Clique para selecionar arquivo (PDF ou Imagem)',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    _fileName?.toLowerCase().endsWith('.pdf') == true
                                        ? Icons.picture_as_pdf
                                        : Icons.image,
                                    color: colorScheme.primary,
                                    size: DSSize.width(24),
                                  ),
                                  DSSizedBoxSpacing.horizontal(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _fileName ?? 'Arquivo selecionado',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        DSSizedBoxSpacing.vertical(2),
                                        Text(
                                          'Toque para alterar',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: colorScheme.error,
                                      size: DSSize.width(20),
                                    ),
                                    onPressed: _removeFile,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding > 0 ? bottomPadding + DSSize.height(16) : DSSize.height(16),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: DSSize.width(10),
                    offset: Offset(0, -DSSize.height(2)),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  label: 'Enviar Documento',
                  icon: Icons.upload_file,
                  iconOnLeft: true,
                  onPressed: _isFormValid ? _handleSubmit : null,
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
  final Function(DocumentsEntity, String?) onSave;

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
  File? _selectedFile;
  String? _fileName;

  bool get _isFormValid {
    return _selectedDocumentOption != null && _selectedFile != null;
  }

  Future<void> _showFileSourceModal() async {
    final source = await SelectionModal.show<DocumentFileSource>(
      context: context,
      title: 'Selecionar arquivo',
      options: [
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.insert_drive_file,
          title: 'Arquivo',
          value: DocumentFileSource.file,
        ),
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.photo_library,
          title: 'Galeria',
          value: DocumentFileSource.gallery,
        ),
      ],
    );

    if (source != null && mounted) {
      if (source == DocumentFileSource.file) {
        await _pickFile();
      } else {
        await _pickFromGallery();
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final pickedFile = result.files.single;
        if (pickedFile.path != null) {
          setState(() {
            _selectedFile = File(pickedFile.path!);
            _fileName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePickerService imagePicker = ImagePickerService();
    final file = await imagePicker.pickImageFromGallery();
    if (file != null && mounted) {
      setState(() {
        _selectedFile = file;
        _fileName = file.path.split('/').last;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) return;

    if (_selectedFile != null && mounted) {
      final document = DocumentsEntity(
        documentType: widget.document.documentType,
        documentOption: _selectedDocumentOption!,
        url: widget.document.url, // Mantém URL original (será atualizada após upload)
        status: 1,
      );
      widget.onSave(document, _selectedFile!.path);
      Navigator.of(context).pop();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
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
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding + DSSize.height(16),
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
                  DSSizedBoxSpacing.vertical(24),
                  // Área de upload
                  Text(
                    'Arquivo',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  GestureDetector(
                    onTap: _showFileSourceModal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _selectedFile == null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: colorScheme.onPrimaryContainer,
                                  size: 24,
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                Expanded(
                                  child: Text(
                                    'Clique para selecionar arquivo (PDF ou Imagem)',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  _fileName?.toLowerCase().endsWith('.pdf') == true
                                      ? Icons.picture_as_pdf
                                      : Icons.image,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fileName ?? 'Arquivo selecionado',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      DSSizedBoxSpacing.vertical(2),
                                      Text(
                                        'Toque para alterar',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  onPressed: _removeFile,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
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
                label: 'Enviar Documento',
                icon: Icons.upload_file,
                iconOnLeft: true,
                onPressed: _isFormValid ? _handleSubmit : null,
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
  final Function(DocumentsEntity, String?) onSave;

  const _AntecedentsDocumentModal({
    required this.document,
    required this.onSave,
  });

  @override
  State<_AntecedentsDocumentModal> createState() => _AntecedentsDocumentModalState();
}

class _AntecedentsDocumentModalState extends State<_AntecedentsDocumentModal> {
  File? _selectedFile;
  String? _fileName;

  bool get _isFormValid {
    return _selectedFile != null;
  }

  Future<void> _showFileSourceModal() async {
    final source = await SelectionModal.show<DocumentFileSource>(
      context: context,
      title: 'Selecionar arquivo',
      options: [
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.insert_drive_file,
          title: 'Arquivo',
          value: DocumentFileSource.file,
        ),
        SelectionModalOption<DocumentFileSource>(
          icon: Icons.photo_library,
          title: 'Galeria',
          value: DocumentFileSource.gallery,
        ),
      ],
    );

    if (source != null && mounted) {
      if (source == DocumentFileSource.file) {
        await _pickFile();
      } else {
        await _pickFromGallery();
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final pickedFile = result.files.single;
        if (pickedFile.path != null) {
          setState(() {
            _selectedFile = File(pickedFile.path!);
            _fileName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePickerService imagePicker = ImagePickerService();
    final file = await imagePicker.pickImageFromGallery();
    if (file != null && mounted) {
      setState(() {
        _selectedFile = file;
        _fileName = file.path.split('/').last;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) return;

    if (_selectedFile != null && mounted) {
      final document = DocumentsEntity(
        documentType: widget.document.documentType,
        documentOption: widget.document.documentOption,
        url: widget.document.url, // Mantém URL original (será atualizada após upload)
        status: 1,
      );
      widget.onSave(document, _selectedFile!.path);
      Navigator.of(context).pop();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSSize.width(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: DSSize.height(12), bottom: DSSize.height(8)),
            child: Container(
              width: DSSize.width(40),
              height: DSSize.height(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(DSSize.width(2)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                  'Certidão de Antecedentes',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                left: DSSize.width(16),
                right: DSSize.width(16),
                top: DSSize.height(16),
                bottom: bottomPadding + DSSize.height(16),
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
                  DSSizedBoxSpacing.vertical(24),
                  // Área de upload
                  Text(
                    'Arquivo',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  GestureDetector(
                    onTap: _showFileSourceModal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _selectedFile == null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: colorScheme.onPrimaryContainer,
                                  size: 24,
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                Expanded(
                                  child: Text(
                                    'Clique para selecionar arquivo (PDF ou Imagem)',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                    ),
                  ),
                ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  _fileName?.toLowerCase().endsWith('.pdf') == true
                                      ? Icons.picture_as_pdf
                                      : Icons.image,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fileName ?? 'Arquivo selecionado',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      DSSizedBoxSpacing.vertical(2),
                                      Text(
                                        'Toque para alterar',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  onPressed: _removeFile,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
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
                label: 'Enviar Certidão',
                icon: Icons.upload_file,
                iconOnLeft: true,
                onPressed: _isFormValid ? _handleSubmit : null,
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

