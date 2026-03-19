import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/widgets/circle_avatar.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/custom_message_field.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/select_single_option_sheet.dart';
import 'package:app/core/shared/widgets/select_talents_sheet.dart';
import 'package:app/core/validators/input_validator.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/create_ensemble_dto.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/ensemble_name_field.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal para criar um novo conjunto.
/// Nome do grupo (EnsembleNameField), número de integrantes (+/-), tipo de conjunto,
/// talentos (lista do app lists, até N = integrantes), bio (opcional). Só UI.
class NewEnsembleModal extends StatefulWidget {
  const NewEnsembleModal({
    super.key,
    required this.ensembleBloc,
    required this.appListsBloc,
  });

  final EnsembleBloc ensembleBloc;
  final AppListsBloc appListsBloc;

  /// Exibe o modal. Retorna o conjunto criado ao sucesso ou null ao cancelar/erro.
  /// Garante que [EnsembleBloc] e [AppListsBloc] estejam disponíveis no modal.
  static Future<EnsembleEntity?> show({
    required BuildContext context,
  }) {
    final ensembleBloc = context.read<EnsembleBloc>();
    final appListsBloc = context.read<AppListsBloc>();
    return showModalBottomSheet<EnsembleEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BlocProviderScope(
        ensembleBloc: ensembleBloc,
        appListsBloc: appListsBloc,
        child: NewEnsembleModal(
          ensembleBloc: ensembleBloc,
          appListsBloc: appListsBloc,
        ),
      ),
    );
  }

  @override
  State<NewEnsembleModal> createState() => _NewEnsembleModalState();
}

/// Provider apenas para disponibilizar os blocs no modal (sheet não herda a árvore da tela).
class _BlocProviderScope extends StatelessWidget {
  final EnsembleBloc ensembleBloc;
  final AppListsBloc appListsBloc;
  final Widget child;

  const _BlocProviderScope({
    required this.ensembleBloc,
    required this.appListsBloc,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ensembleBloc),
        BlocProvider.value(value: appListsBloc),
      ],
      child: child,
    );
  }
}

class _NewEnsembleModalState extends State<NewEnsembleModal> {
  static const int _minMembers = 2;
  static const int _maxMembers = 20;

  final TextEditingController _ensembleNameController = TextEditingController();
  final TextEditingController _talentsController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  int _membersCount = _minMembers;
  String? _ensembleType;
  List<String> _talentOptions = [];
  List<String> _ensembleTypeOptions = [];
  bool _nameValidationValid = false; // usado ao integrar botão Criar (habilitar só quando válido)

  @override
  void initState() {
    super.initState();
    widget.appListsBloc.add(GetTalentsEvent());
    widget.appListsBloc.add(GetEnsembleTypesEvent());
  }

  @override
  void dispose() {
    _ensembleNameController.dispose();
    _talentsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onAddPhoto() {
    // TODO: integrar picker de foto
  }

  void _openTalentsSheet() {
    final options = _talentOptions.isNotEmpty
        ? _talentOptions
        : ['Cantor', 'Dançarino', 'Músico', 'Atores', 'Comediantes', 'Outros'];
    final initial = _talentsController.text
        .split(', ')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SelectTalentsSheet(
        title: 'Talentos do conjunto',
        subtitle: 'Selecione até $_membersCount talentos (opcional).',
        talentNames: options,
        initialSelected: initial,
        maxSelections: _membersCount,
        confirmButtonLabel: 'Confirmar',
        onConfirm: (selected) {
          _talentsController.text = selected.join(', ');
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _openEnsembleTypeSheet() {
    final options = _ensembleTypeOptions.isNotEmpty
        ? _ensembleTypeOptions
        : ['Orquestra', 'Banda', 'Outro'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SelectSingleOptionSheet(
        title: 'Tipo de conjunto',
        subtitle: 'Escolha o tipo que melhor descreve o conjunto.',
        options: options,
        initialSelected: _ensembleType,
        confirmButtonLabel: 'Confirmar',
        onConfirm: (selected) {
          if (ctx.mounted) {
            setState(() => _ensembleType = selected);
            Navigator.of(ctx).pop();
          }
        },
      ),
    );
  }

  void _onCreate() {
    final talentsList = _talentsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final dto = CreateEnsembleDto(
      ensembleName: _ensembleNameController.text.trim(),
      membersCount: _membersCount,
      ensembleType: _ensembleType,
      talents: talentsList.isNotEmpty ? talentsList : null,
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
    );
    context.read<EnsembleBloc>().add(CreateEnsembleEvent(dto: dto));
  }

  static const double _labelWidth = 160;

  Widget _buildLabelFieldRow({
    required BuildContext context,
    required String label,
    required Widget field,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Padding(
      padding: EdgeInsets.only(bottom: DSSize.height(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: onPrimary,
              ),
            ),
          ),
          DSSizedBoxSpacing.horizontal(12),
          Expanded(child: field),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final onPrimary = colorScheme.onPrimary;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<EnsembleBloc, EnsembleState>(
      listenWhen: (prev, curr) =>
          curr is CreateEnsembleSuccess || curr is CreateEnsembleFailure,
      listener: (context, state) {
        if (state is CreateEnsembleSuccess) {
          if (context.mounted) Navigator.of(context).pop(state.ensemble);
        } else if (state is CreateEnsembleFailure) {
          if (context.mounted) context.showError(state.error);
        }
      },
      child: BlocListener<AppListsBloc, AppListsState>(
        listener: (context, state) {
          if (state is GetTalentsSuccess) {
            final names = state.talents.map((t) => t.name).toList()..sort();
            setState(() => _talentOptions = names);
          } else if (state is GetTalentsFailure) {
            setState(() => _talentOptions = []);
          } else if (state is GetEnsembleTypesSuccess) {
            final names = state.ensembleTypes.map((t) => t.name).toList()..sort();
            setState(() => _ensembleTypeOptions = names);
          } else if (state is GetEnsembleTypesFailure) {
            setState(() => _ensembleTypeOptions = []);
          }
        },
        child: BlocBuilder<EnsembleBloc, EnsembleState>(
          buildWhen: (prev, curr) =>
              curr is CreateEnsembleLoading || prev is CreateEnsembleLoading,
          builder: (context, ensembleState) {
            final isCreating = ensembleState is CreateEnsembleLoading;
            return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DSSize.width(20)),
                  topRight: Radius.circular(DSSize.width(20)),
                ),
              ),
              child: Column(
                children: [
                  DSSizedBoxSpacing.vertical(8),
                  Container(
                    width: DSSize.width(40),
                    height: DSSize.height(4),
                    margin: EdgeInsets.only(bottom: DSSize.height(8)),
                    decoration: BoxDecoration(
                      color: onPrimary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(DSSize.width(2)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Novo conjunto',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onPrimary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: onPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                      children: [
                        // Header: foto + nome lado a lado, sem label
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomCircleAvatar(
                              imageUrl: null,
                              onEdit: _onAddPhoto,
                              size: DSSize.width(80),
                              showCameraIcon: true,
                            ),
                            DSSizedBoxSpacing.horizontal(12),
                            Expanded(
                              child: EnsembleNameField(
                                controller: _ensembleNameController,
                                onValidationChanged: (valid) {
                                  setState(() => _nameValidationValid = valid);
                                },
                                considerEmptyAsValid: false,
                              ),
                            ),
                          ],
                        ),
                        DSSizedBoxSpacing.vertical(8),
                        Text(
                          'Obrigatórios: nome, número de integrantes e tipo. Após a criação do conjunto, todos os campos são editáveis.',
                          style: textTheme.bodySmall?.copyWith(
                            color: onPrimary.withOpacity(0.7),
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(16),
                        _buildLabelFieldRow(
                          context: context,
                          label: 'Número de integrantes',
                          field: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filled(
                                  onPressed: _membersCount > _minMembers
                                      ? () => setState(() => _membersCount--)
                                      : null,
                                  icon: const Icon(Icons.remove),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: onPrimary,
                                  ),
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                Text(
                                  '$_membersCount',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: onPrimary,
                                  ),
                                ),
                                DSSizedBoxSpacing.horizontal(12),
                                IconButton.filled(
                                  onPressed: _membersCount < _maxMembers
                                      ? () => setState(() => _membersCount++)
                                      : null,
                                  icon: const Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildLabelFieldRow(
                          context: context,
                          label: 'Tipo de conjunto',
                          field: GestureDetector(
                            onTap: _openEnsembleTypeSheet,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DSSize.width(16),
                                vertical: DSSize.height(14),
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(DSSize.width(12)),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _ensembleType ?? 'Selecione o tipo',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _ensembleType != null
                                            ? onPrimary
                                            : onPrimary.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: DSSize.width(24),
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildLabelFieldRow(
                          context: context,
                          label: 'Talentos',
                          field: GestureDetector(
                            onTap: _openTalentsSheet,
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _talentsController,
                                style: textTheme.bodyMedium?.copyWith(color: onPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Selecione (opcional)',
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: DSSize.width(16),
                                    vertical: DSSize.height(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(DSSize.width(12)),
                                    borderSide: BorderSide(color: onPrimary),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down,
                                    size: DSSize.width(24),
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bio: label em cima, input embaixo
                        Padding(
                          padding: EdgeInsets.only(bottom: DSSize.height(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descrição / Bio',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: onPrimary,
                                ),
                              ),
                              DSSizedBoxSpacing.vertical(6),
                              CustomMessageField(
                                controller: _bioController,
                                labelText: '',
                                hintText: 'Opcional. Fale sobre o conjunto...',
                                onChanged: (_) {},
                                validator: Validators.validateIsNull,
                              ),
                            ],
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(8),
                        CustomButton(
                          label: isCreating ? 'Criando...' : 'Criar',
                          onPressed: (!isCreating && _nameValidationValid)
                              ? _onCreate
                              : null,
                          icon: isCreating ? null : Icons.check,
                        ),
                        DSSizedBoxSpacing.vertical(24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  ),
  );
  }
}
