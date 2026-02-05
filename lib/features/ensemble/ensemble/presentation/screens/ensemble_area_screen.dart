import 'dart:io';

import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/services/image_picker_service.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/features/artists/artists/presentation/bloc/artists_bloc.dart';
import 'package:app/features/artists/artists/presentation/bloc/events/artists_events.dart';
import 'package:app/features/artists/artists/presentation/bloc/states/artists_states.dart';
import 'package:app/features/artists/artists/presentation/widgets/artist_area_activation_card.dart';
import 'package:app/features/artists/artists/presentation/widgets/artist_area_option_card.dart';
import 'package:app/features/ensemble/ensemble/domain/enums/ensemble_info_type_enum.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/widgets/ensemble_completeness_card.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_header.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/photo_confirmation_dialog.dart';
import 'package:app/features/profile/shared/presentation/widgets/profile_picture/profile_picture_options_menu.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsembleAreaScreen extends StatefulWidget {
  final String ensembleId;

  const EnsembleAreaScreen({super.key, required this.ensembleId});

  @override
  State<EnsembleAreaScreen> createState() => _EnsembleAreaScreenState();
}

class _EnsembleAreaScreenState extends State<EnsembleAreaScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isUpdatingActiveStatus = false;
  bool _isUpdatingProfilePhoto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<EnsembleBloc>().add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
    // Garante que o artista (dono) esteja carregado para navegação para "Minha Página"
    if (context.read<ArtistsBloc>().state is! GetArtistSuccess) {
      context.read<ArtistsBloc>().add(GetArtistEvent());
    }
  }

  String _getArtistName() {
    final state = context.read<ArtistsBloc>().state;
    if (state is GetArtistSuccess) {
      return state.artist.artistName ?? 'Artista';
    }
    return 'Artista';
  }

  ArtistEntity? _getArtist() {
    final state = context.read<ArtistsBloc>().state;
    if (state is GetArtistSuccess) {
      return state.artist;
    }
    return null;
  }

  /// Número de integrantes além do dono (o dono não é salvo em members).
  int _additionalMembersCount(EnsembleEntity ensemble) {
    final count = (ensemble.members?.length ?? 0) - 1;
    if (count < 0) {
      return 0;
    }
    return count;
  }

  /// Nome de exibição do conjunto: "Nome do Artista" ou "Nome do Artista + N".
  String _displayName(EnsembleEntity ensemble) {
    final artistName = _getArtistName();
    final count = _additionalMembersCount(ensemble);
    return count > 0 ? '$artistName + $count' : artistName;
  }

  /// Verifica se a seção [type] está marcada como incompleta em [ensemble.incompleteSections].
  /// [type] deve ser o nome do enum (ex: professionalInfo, profilePhoto, presentations, members, ownerDocumentsAndBank).
  bool _hasIncompleteSection(EnsembleEntity ensemble, String type) {
    final sections = ensemble.incompleteSections;
    if (sections == null) return false;
    return sections.values.any((types) => types.contains(type));
  }

  bool _hasIncompleteMembers(EnsembleEntity ensemble) {
    final sections = ensemble.incompleteSections;
    if (sections == null) return false;
    return sections.values.any((types) => types.contains(EnsembleInfoType.members.name) || types.contains(EnsembleInfoType.memberDocuments.name));
  }

  /// Modal de opções e handlers para foto de perfil do conjunto.
  Future<void> _handleProfilePictureTap(EnsembleEntity ensemble) async {
    if (!mounted) return;

    final hasImage = ensemble.profilePhotoUrl != null &&
        ensemble.profilePhotoUrl!.trim().isNotEmpty;

    final option = await ProfilePictureOptionsMenu.show(
      context,
      hasImage: hasImage,
    );

    if (option == null || !mounted) return;

    switch (option) {
      case ProfilePictureOption.view:
        _showImageViewDialog(ensemble.profilePhotoUrl);
        break;

      case ProfilePictureOption.gallery:
        final result = await _imagePickerService.pickImageFromGallery();
        if (!mounted) return;
        if (result.file != null) {
          await _confirmAndUpdateProfilePicture(result.file!);
        } else if (result.errorMessage != null) {
          context.showError(result.errorMessage!);
        }
        break;

      case ProfilePictureOption.camera:
        final result = await _imagePickerService.captureImageFromCamera();
        if (!mounted) return;
        if (result.file != null) {
          await _confirmAndUpdateProfilePicture(result.file!);
        } else if (result.errorMessage != null) {
          context.showError(result.errorMessage!);
        }
        break;

      case ProfilePictureOption.remove:
        await _confirmAndRemoveProfilePicture(ensemble);
        break;
    }
  }

  void _showImageViewDialog(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: DSSize.width(48),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: DSSize.height(16),
              right: DSSize.width(16),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: DSSize.width(32),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndUpdateProfilePicture(File imageFile) async {
    final confirmed = await PhotoConfirmationDialog.show(
      context,
      imageFile: imageFile,
    );

    if (confirmed == true && mounted) {
      setState(() => _isUpdatingProfilePhoto = true);
      context.read<EnsembleBloc>().add(
            UpdateEnsembleProfilePhotoEvent(
              ensembleId: widget.ensembleId,
              localFilePath: imageFile.path,
            ),
          );
    }
  }

  Future<void> _confirmAndRemoveProfilePicture(EnsembleEntity ensemble) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto de perfil'),
        content: const Text(
          'Tem certeza que deseja remover a foto de perfil do conjunto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updated = ensemble.copyWith(profilePhotoUrl: null);
      context.read<EnsembleBloc>().add(UpdateEnsembleEvent(ensemble: updated));
      context.read<EnsembleBloc>().add(
            GetEnsembleByIdEvent(ensembleId: widget.ensembleId),
          );
      if (mounted) context.showSuccess('Foto removida.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return BlocBuilder<EnsembleBloc, EnsembleState>(
      buildWhen: (previous, current) =>
          current is GetAllEnsemblesSuccess ||
          current is GetEnsembleByIdFailure,
      builder: (context, state) {
        if (state is GetEnsembleByIdFailure) {
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Conjunto',
            showAppBarBackButton: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<EnsembleBloc>().add(
                            GetEnsembleByIdEvent(ensembleId: widget.ensembleId),
                          );
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final success = state is GetAllEnsemblesSuccess ? state : null;
        final currentEnsemble = success?.currentEnsemble;
        final isRequestedEnsemble = currentEnsemble?.id == widget.ensembleId;

        if (success == null || currentEnsemble == null || !isRequestedEnsemble) {
          if (success != null && currentEnsemble == null) {
            return BasePage(
              showAppBar: true,
              appBarTitle: 'Conjunto',
              showAppBarBackButton: true,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          return BasePage(
            showAppBar: true,
            appBarTitle: 'Conjunto',
            showAppBarBackButton: true,
            child: const Center(child: Text('Conjunto não encontrado.')),
          );
        }

        final ensemble = currentEnsemble;
        final displayName = _displayName(ensemble);
        final appBarTitle = displayName.length > 24
            ? '${displayName.substring(0, 24)}...'
            : displayName;
        final membersCount = _additionalMembersCount(ensemble)+1;

        final hasIncompleteSections = ensemble.hasIncompleteSections ?? true;
        final isActive = ensemble.isActive ?? false;

        return BlocListener<EnsembleBloc, EnsembleState>(
          listenWhen: (previous, current) =>
              current is UpdateEnsembleProfilePhotoSuccess ||
              current is UpdateEnsembleProfilePhotoFailure ||
              current is UpdateEnsembleActiveStatusSuccess ||
              current is UpdateEnsembleActiveStatusFailure,
          listener: (context, state) {
            if (state is UpdateEnsembleProfilePhotoSuccess) {
              if (mounted) setState(() => _isUpdatingProfilePhoto = false);
              context.showSuccess('Foto atualizada.');
            }
            if (state is UpdateEnsembleProfilePhotoFailure) {
              if (mounted) setState(() => _isUpdatingProfilePhoto = false);
              context.showError(state.error);
            }
            if (state is UpdateEnsembleActiveStatusSuccess) {
              if (mounted) setState(() => _isUpdatingActiveStatus = false);
              context.showSuccess(
                state.ensemble.isActive == true
                    ? 'Conjunto visível para clientes.'
                    : 'Conjunto oculto das buscas.',
              );
            }
            if (state is UpdateEnsembleActiveStatusFailure) {
              if (mounted) setState(() => _isUpdatingActiveStatus = false);
              context.showError(state.error);
            }
          },
          child: BasePage(
            showAppBar: true,
            appBarTitle: appBarTitle,
            showAppBarBackButton: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSSizedBoxSpacing.vertical(16),
                  ProfileHeader(
                    imageUrl: ensemble.profilePhotoUrl,
                    name: displayName,
                    isArtist: false,
                    isGroup: true,
                    onProfilePictureTap: () => _handleProfilePictureTap(ensemble),
                    isLoadingProfilePicture: _isUpdatingProfilePhoto,
                    showPhotoIncompleteBadge: _hasIncompleteSection(ensemble, EnsembleInfoType.profilePhoto.name),
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  // Incompleto: card com mensagem e detalhes. Completo e aprovado: botão de ativar. Completo e não aprovado: mensagem "em análise".
                  if (hasIncompleteSections) ...[
                    EnsembleCompletenessCard(ensemble: ensemble),
                  ] else if (ensemble.allMembersApproved != true) ...[
                    _EnsembleUnderReviewCard(iconColor: onPrimaryContainer),
                  ] else ...[
                    ArtistAreaActivationCard(
                      title: 'Ativar visualização',
                      description: isActive
                          ? 'Seu conjunto está ativo e visível para clientes.'
                          : 'Ative seu conjunto para aparecer nas buscas.',
                      icon: Icons.public_outlined,
                      iconColor: onPrimaryContainer,
                      isActive: isActive,
                      isEnabled: !_isUpdatingActiveStatus,
                      onChanged: (value) {
                        setState(() => _isUpdatingActiveStatus = true);
                        context.read<EnsembleBloc>().add(
                              UpdateEnsembleActiveStatusEvent(
                                ensembleId: widget.ensembleId,
                                isActive: value,
                              ),
                            );
                      },
                    ),
                  ],
                  DSSizedBoxSpacing.vertical(24),
                  ArtistAreaOptionCard(
                    title: 'Integrantes',
                    description:
                        'Gerencie os integrantes do conjunto ($membersCount cadastrado${membersCount == 1 ? '' : 's'}).',
                    icon: Icons.people_outline_rounded,
                    iconColor: onPrimaryContainer,
                    hasIncompleteInfo: _hasIncompleteMembers(ensemble),
                    onTap: () {
                      context.router.push(EnsembleMembersRoute(ensembleId: widget.ensembleId));
                    },
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  ArtistAreaOptionCard(
                    title: 'Dados Profissionais',
                    description: 'Defina as informações de apresentação do conjunto.',
                    icon: Icons.work_outline_rounded,
                    iconColor: onPrimaryContainer,
                    hasIncompleteInfo: _hasIncompleteSection(ensemble, EnsembleInfoType.professionalInfo.name),
                    onTap: () {
                      context.router.push(
                        EnsembleProfessionalInfoRoute(ensembleId: widget.ensembleId),
                      );
                    },
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  ArtistAreaOptionCard(
                    title: 'Apresentações',
                    description: 'Adicione o vídeo de apresentação do conjunto (até 1 min).',
                    icon: Icons.video_library_outlined,
                    iconColor: onPrimaryContainer,
                    hasIncompleteInfo: _hasIncompleteSection(ensemble, EnsembleInfoType.presentations.name),
                    onTap: () {
                      context.router.push(
                        EnsemblePresentationsRoute(ensembleId: widget.ensembleId),
                      );
                    },
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  ArtistAreaOptionCard(
                    title: 'Disponibilidade',
                    description: 'Defina horários e raio de atuação do conjunto.',
                    icon: Icons.calendar_today_outlined,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      context.router.push(EnsembleAvailabilityCalendarRoute(ensembleId: widget.ensembleId));
                    },
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  ArtistAreaOptionCard(
                    title: 'Minha Página',
                    description: 'Visualize como a página do conjunto aparece para os clientes.',
                    icon: Icons.person_outline_rounded,
                    iconColor: onPrimaryContainer,
                    onTap: () {
                      final artist = _getArtist();
                      if (artist != null) {
                        context.router.push(EnsembleExploreRoute(
                          ensembleId: widget.ensembleId,
                          artist: artist,
                          viewOnly: true,
                        ));
                      } else {
                        context.showError('Carregue seus dados de artista antes de visualizar a página.');
                      }
                    },
                  ),
                  DSSizedBoxSpacing.vertical(24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Card exibido quando o conjunto está completo mas ainda não aprovado (documentos em análise).
class _EnsembleUnderReviewCard extends StatelessWidget {
  final Color iconColor;

  const _EnsembleUnderReviewCard({required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceContainerHighest = colorScheme.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSize.width(24),
        vertical: DSSize.height(24),
      ),
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DSSize.width(12)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty_rounded, color: iconColor, size: DSSize.width(24)),
          DSSizedBoxSpacing.horizontal(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conjunto em análise',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'Seu conjunto está em análise. Você poderá ativá-lo quando a verificação dos documentos for concluída.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
