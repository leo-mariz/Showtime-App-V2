import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_button.dart';
import 'package:app/core/shared/widgets/select_single_option_sheet.dart';
import 'package:app/core/shared/widgets/select_talents_sheet.dart';
import 'package:app/features/app_lists/presentation/bloc/app_lists_bloc.dart';
import 'package:app/features/app_lists/presentation/bloc/events/app_lists_events.dart';
import 'package:app/features/app_lists/presentation/bloc/states/app_lists_states.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/update_ensemble_integrants_dto.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsembleIntegrantsScreen extends StatefulWidget {
  final String ensembleId;

  const EnsembleIntegrantsScreen({super.key, required this.ensembleId});

  @override
  State<EnsembleIntegrantsScreen> createState() => _EnsembleIntegrantsScreenState();
}

class _EnsembleIntegrantsScreenState extends State<EnsembleIntegrantsScreen> {
  static const int _minMembers = 2;
  static const int _maxMembers = 20;
  static const double _labelWidth = 160;

  final TextEditingController _talentsController = TextEditingController();

  int _membersCount = _minMembers;
  String? _ensembleType;
  List<String> _talentOptions = [];
  List<String> _ensembleTypeOptions = [];
  bool _hasLoadedEnsemble = false;

  @override
  void initState() {
    super.initState();
    context.read<EnsembleBloc>().add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
    context.read<AppListsBloc>().add(GetTalentsEvent());
    context.read<AppListsBloc>().add(GetEnsembleTypesEvent());
  }

  @override
  void dispose() {
    _talentsController.dispose();
    super.dispose();
  }

  void _openTalentsSheet() {
    final options = _talentOptions.isNotEmpty
        ? _talentOptions
        : ['Cantor', 'Dançarino', 'Músico', 'Atores', 'Comediantes', 'Outros'];
    final initial = _talentsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
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

  void _onSave() {
    final talentsList = _talentsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final dto = UpdateEnsembleIntegrantsDto(
      membersCount: _membersCount,
      talents: talentsList.isNotEmpty ? talentsList : null,
      ensembleType: _ensembleType,
    );
    context.read<EnsembleBloc>().add(UpdateEnsembleMembersEvent(
          ensembleId: widget.ensembleId,
          dto: dto,
        ));
  }

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
    final onPrimary = colorScheme.onPrimary;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AppListsBloc, AppListsState>(
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
      child: BlocListener<EnsembleBloc, EnsembleState>(
      listenWhen: (prev, curr) =>
          curr is UpdateEnsembleMembersSuccess || curr is UpdateEnsembleMembersFailure,
      listener: (context, state) {
        if (state is UpdateEnsembleMembersSuccess) {
          if (context.mounted) {
            context.showSuccess('Integrantes e talentos atualizados.');
            context.router.maybePop();
          }
        } else if (state is UpdateEnsembleMembersFailure) {
          if (context.mounted) context.showError(state.error);
        }
      },
        child: BlocBuilder<EnsembleBloc, EnsembleState>(
          buildWhen: (prev, curr) {
            if (curr is GetAllEnsemblesSuccess) {
              final hasMatch = curr.currentEnsemble?.id == widget.ensembleId ||
                  curr.ensembles.any((e) => e.id == widget.ensembleId);
              return hasMatch;
            }
            return curr is UpdateEnsembleMembersLoading || prev is UpdateEnsembleMembersLoading;
          },
          builder: (context, state) {
            EnsembleEntity? ensemble;
            if (state is GetAllEnsemblesSuccess) {
              if (state.currentEnsemble?.id == widget.ensembleId) {
                ensemble = state.currentEnsemble;
              } else {
                final match = state.ensembles.where((e) => e.id == widget.ensembleId);
                ensemble = match.isEmpty ? null : match.first;
              }
            }
            if (ensemble != null && !_hasLoadedEnsemble) {
              final e = ensemble;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasLoadedEnsemble = true;
                    _membersCount = (e.members ?? _minMembers).clamp(_minMembers, _maxMembers);
                    _ensembleType = e.ensembleType;
                    _talentsController.text = (e.talents ?? []).join(', ');
                  });
                }
              });
            }

            final isLoading = state is UpdateEnsembleMembersLoading;
            final canSave = ensemble != null && !isLoading;

            return BasePage(
              showAppBar: true,
              appBarTitle: 'Sobre o Conjunto',
              showAppBarBackButton: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: DSSize.width(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSizedBoxSpacing.vertical(24),
                    _buildLabelFieldRow(
                      context: context,
                      label: 'Número de integrantes',
                      field: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.filled(
                              onPressed: canSave && _membersCount > _minMembers
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
                              onPressed: canSave && _membersCount < _maxMembers
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
                        onTap: canSave ? _openEnsembleTypeSheet : null,
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
                        onTap: canSave ? _openTalentsSheet : null,
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
                                borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.3)),
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
                    DSSizedBoxSpacing.vertical(24),
                    CustomButton(
                      label: isLoading ? 'Salvando...' : 'Salvar',
                      onPressed: canSave ? _onSave : null,
                      icon: isLoading ? null : Icons.check,
                    ),
                    DSSizedBoxSpacing.vertical(24),
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
