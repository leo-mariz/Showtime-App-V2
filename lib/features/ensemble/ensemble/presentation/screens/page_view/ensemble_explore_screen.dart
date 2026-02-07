import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/core/shared/extensions/context_notification_extension.dart';
import 'package:app/core/shared/widgets/base_page_widget.dart';
import 'package:app/core/shared/widgets/custom_icon_button.dart';
import 'package:app/core/shared/widgets/artist_footer.dart';
import 'package:app/core/shared/widgets/favorite_button.dart';
import 'package:app/core/shared/widgets/custom_badge.dart';
import 'package:app/core/shared/widgets/genre_chip.dart';
import 'package:app/core/shared/widgets/tabs_section.dart';
import 'package:app/core/shared/widgets/video_viewer.dart';
import 'package:app/features/addresses/presentation/bloc/addresses_bloc.dart';
import 'package:app/features/addresses/presentation/bloc/events/addresses_events.dart';
import 'package:app/features/addresses/presentation/bloc/states/addresses_states.dart';
import 'package:app/features/addresses/presentation/widgets/addresses_modal.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/ensemble_bloc.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/events/ensemble_events.dart';
import 'package:app/features/ensemble/ensemble/presentation/bloc/states/ensemble_states.dart';
import 'package:app/features/ensemble/members/presentation/bloc/events/members_events.dart';
import 'package:app/features/ensemble/members/presentation/bloc/members_bloc.dart';
import 'package:app/features/ensemble/members/presentation/bloc/states/members_states.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/ensemble_availability_bloc.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/events/ensemble_availability_events.dart';
import 'package:app/features/ensemble/ensemble_availability/presentation/bloc/states/ensemble_availability_states.dart';
import 'package:app/features/explore/presentation/widgets/address_selector.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:app/features/explore/presentation/widgets/artist_availability_calendar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class EnsembleExploreScreen extends StatefulWidget {
  final String ensembleId;
  final ArtistEntity? artist;
  final bool isFavorite;
  final bool viewOnly;
  final DateTime? selectedDate;
  final AddressInfoEntity? selectedAddress;

  const EnsembleExploreScreen({
    super.key,
    required this.ensembleId,
    this.artist,
    this.isFavorite = false,
    this.viewOnly = false,
    this.selectedDate,
    this.selectedAddress,
  });

  @override
  State<EnsembleExploreScreen> createState() => _EnsembleExploreScreenState();
}

class _EnsembleExploreScreenState extends State<EnsembleExploreScreen> {
  AddressInfoEntity? _selectedAddress;
  EnsembleEntity? _currentEnsemble;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EnsembleBloc>().add(GetEnsembleByIdEvent(ensembleId: widget.ensembleId));
        context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
      }
    });
    if (widget.selectedAddress != null) {
      _selectedAddress = widget.selectedAddress;
      _loadAvailabilities();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final addressesState = context.read<AddressesBloc>().state;
        if (addressesState is! GetAddressesSuccess) {
          context.read<AddressesBloc>().add(GetAddressesEvent());
        } else {
          _getPrimaryAddressFromState(addressesState);
        }
      });
    }
  }

  /// Obtém endereço primário do estado do AddressesBloc
  void _getPrimaryAddressFromState(GetAddressesSuccess state) {
    if (state.addresses.isEmpty) {
      return;
    }

    AddressInfoEntity primaryAddress;
    try {
      primaryAddress = state.addresses.firstWhere(
        (address) => address.isPrimary,
      );
    } catch (e) {
      primaryAddress = state.addresses.first;
    }

    if (_selectedAddress == null && mounted) {
      setState(() {
        _selectedAddress = primaryAddress;
      });
      _loadAvailabilities();
    }
  }

  /// Carrega disponibilidades do conjunto para o endereço selecionado
  void _loadAvailabilities() {
    if (_selectedAddress != null && widget.ensembleId.isNotEmpty) {
      context.read<EnsembleAvailabilityBloc>().add(
        GetAllAvailabilitiesEvent(ensembleId: widget.ensembleId),
      );
    }
  }

  /// Abre modal de seleção de endereço
  void _onAddressSelected() async {
    final selectedAddress = await AddressesModal.show(
      context: context,
      selectedAddress: _selectedAddress,
    );

    if (selectedAddress != null && selectedAddress != _selectedAddress) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
      _loadAvailabilities();
    }
  }

  String get _currentAddressDisplay {
    if (_selectedAddress == null) {
      return 'Selecione um endereço';
    }
    return _selectedAddress!.title;
  }

  void _onVideoTap(String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: VideoViewer(
              videoUrl: videoUrl,
              autoPlay: true,
            ),
          ),
        ),
      ),
    );
  }

  void _onRequestPressed(BuildContext context) {
    final router = context.router;

    if (_selectedAddress == null) {
      context.showError('Selecione um endereço antes de solicitar');
      return;
    }
    if (widget.artist == null) {
      context.showError('Solicitação indisponível para este conjunto no momento');
      return;
    }
    if (_currentEnsemble == null || _currentEnsemble!.id == null) {
      context.showError('Dados do conjunto não carregados. Tente novamente.');
      return;
    }

    final ensembleWithAvailabilities = EnsembleWithAvailabilitiesEntity.empty(
      _currentEnsemble!,
      ownerArtist: widget.artist,
    );

    router.push(
      RequestRoute(
        selectedDate: widget.selectedDate ?? DateTime.now(),
        selectedAddress: _selectedAddress!,
        artist: widget.artist!,
        ensemble: ensembleWithAvailabilities,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onPrimary = colorScheme.onPrimary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final artist = widget.artist;
    final ensemble = _currentEnsemble;
    final profilePhotoUrl = ensemble?.profilePhotoUrl ?? artist?.profilePicture;
    final totalDisplayMembers = (ensemble?.members?.length ?? 0) - 1;
    // Nome do grupo: nome do artista dono + número de integrantes
    final displayTitle = totalDisplayMembers > 0
        ? '${artist?.artistName ?? 'Conjunto'} + $totalDisplayMembers'
        : (artist?.artistName ?? 'Conjunto');
    final professionalInfo = ensemble?.professionalInfo ?? artist?.professionalInfo;
    final bio = professionalInfo?.bio;

    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is AddFavoriteSuccess) {
          context.showSuccess('Conjunto adicionado aos favoritos');
          context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
        } else if (state is AddFavoriteFailure) {
          context.showError(state.error);
        } else if (state is RemoveFavoriteEnsembleSuccess) {
          context.showSuccess('Conjunto removido dos favoritos');
          context.read<FavoritesBloc>().add(GetFavoriteEnsemblesEvent());
        } else if (state is RemoveFavoriteFailure) {
          context.showError(state.error);
        }
      },
      child: BlocConsumer<EnsembleBloc, EnsembleState>(
      listenWhen: (previous, current) =>
          current is GetAllEnsemblesSuccess || current is GetEnsembleByIdFailure,
      listener: (context, state) {
        if (state is GetAllEnsemblesSuccess &&
            state.currentEnsemble?.id == widget.ensembleId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _currentEnsemble = state.currentEnsemble);
              context.read<MembersBloc>().add(GetAllMembersEvent(forceRemote: false));
            }
          });
        }
      },
      buildWhen: (previous, current) =>
          current is GetAllEnsemblesSuccess || current is GetEnsembleByIdFailure,
      builder: (context, state) {
        if (state is GetAllEnsemblesSuccess &&
            state.currentEnsemble?.id == widget.ensembleId &&
            _currentEnsemble == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _currentEnsemble == null) {
              setState(() => _currentEnsemble = state.currentEnsemble);
            }
          });
        }
        return BasePage(
      horizontalPadding: 0,
      verticalPadding: 0,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Foto de perfil com gradiente
                Stack(
                  children: [
                    // Imagem de perfil (conjunto ou artista)
                    Container(
                      height: DSSize.height(300),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: profilePhotoUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  profilePhotoUrl,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: profilePhotoUrl == null
                            ? colorScheme.surfaceContainerHighest
                            : null,
                      ),
                    ),
                    // Gradiente
                    Container(
                      height: DSSize.height(300),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colorScheme.surface.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    // Header com botões
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: DSPadding.horizontal(16),
                          vertical: DSPadding.vertical(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onPressed: () => Navigator.of(context).pop(),
                              backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                              color: onPrimaryContainer,
                            ),
                            CustomIconButton(
                              icon: Icons.share,
                              onPressed: () {
                                // TODO: Implementar compartilhamento
                              },
                              backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                              color: onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Conteúdo principal
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSPadding.horizontal(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSSizedBoxSpacing.vertical(16),

                      // Nome do grupo: artista + (N integrantes) — sem chips de talento
                      Text(
                        displayTitle,
                        style: textTheme.titleLarge?.copyWith(
                          color: onPrimary,
                        ),
                      ),

                      DSSizedBoxSpacing.vertical(8),
                      Row(
                        children: [
                          CustomBadge(value: artist?.rating?.toStringAsFixed(2) ?? '0.0', icon: Icons.star, color: onPrimaryContainer),
                          DSSizedBoxSpacing.horizontal(8),
                          CustomBadge(title: 'Contratos', value: artist?.rateCount?.toString() ?? '0', color: onPrimaryContainer),
                          const Spacer(),
                          if (!widget.viewOnly)
                            BlocBuilder<FavoritesBloc, FavoritesState>(
                              buildWhen: (prev, curr) =>
                                  curr is GetFavoriteEnsemblesSuccess ||
                                  curr is AddFavoriteSuccess ||
                                  curr is RemoveFavoriteEnsembleSuccess,
                              builder: (context, favState) {
                                final isFavorite = favState is GetFavoriteEnsemblesSuccess
                                    ? favState.ensembles.any((e) => e.ensemble.id == widget.ensembleId)
                                    : widget.isFavorite;
                                return FavoriteButton(
                                  isFavorite: isFavorite,
                                  onTap: () {
                                    if (widget.ensembleId.isEmpty) return;
                                    if (isFavorite) {
                                      context.read<FavoritesBloc>().add(
                                        RemoveFavoriteEnsembleEvent(ensembleId: widget.ensembleId),
                                      );
                                    } else {
                                      context.read<FavoritesBloc>().add(
                                        AddFavoriteEnsembleEvent(ensembleId: widget.ensembleId),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                      ),

                      DSSizedBoxSpacing.vertical(4),


                      // Linha superior: Conjunto + X Integrantes (estilo talentos/GenreChip)
                      Row(
                        children: [
                          Wrap(
                            spacing: DSSize.width(8),
                            runSpacing: DSSize.height(8),
                            children: [
                              GenreChip(label: 'Conjunto'),
                              GenreChip(label: '${totalDisplayMembers+1} Integrantes'),
                            ],
                          ),
                          

                      ],),

                      // Linha inferior: rating, contratos e favorito
                      

                      DSSizedBoxSpacing.vertical(16),

                      if (bio != null && bio.isNotEmpty) ...[
                        Text(
                          bio,
                          style: textTheme.bodyMedium?.copyWith(
                            color: onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(24),
                      ],

                      // Só monta TabsSection quando já temos artist ou ensemble (ensemble carrega de forma assíncrona)
                      if (artist != null || ensemble != null)
                        BlocBuilder<MembersBloc, MembersState>(
                          buildWhen: (p, c) => c is GetAllMembersSuccess,
                          builder: (context, membersState) {
                            List<String>? displayNames;
                            if (ensemble?.members != null &&
                                membersState is GetAllMembersSuccess) {
                              final allMembers = membersState.members;
                              final byId = {
                                for (final m in allMembers) if (m.id != null) m.id!: m
                              };
                              displayNames = ensemble!.members!.map((slot) {
                                if (slot.isOwner) {
                                  return artist?.artistName ?? 'Dono';
                                }
                                return byId[slot.memberId]?.name ?? 'Integrante';
                              }).toList();
                            }
                            return TabsSection(
                              artist: widget.artist,
                              onVideoTap: (videoUrl) => _onVideoTap(videoUrl),
                              ensemble: ensemble,
                              ownerDisplayName: artist?.artistName,
                              ensembleMemberDisplayNames: displayNames,
                              ownerArtistSpecialty: artist?.professionalInfo?.specialty,
                              calendarTab: _buildCalendarTab(colorScheme, textTheme),
                            );
                          },
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: DSSize.height(24)),
                          child: Center(
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          ),
                        ),

                      DSSizedBoxSpacing.vertical(100), // Espaço para o footer
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer fixo
          if (!widget.viewOnly) ...[
            Positioned(
              left: DSSize.width(0),
              right: DSSize.width(0),
              bottom: DSSize.height(-12),
              child: ArtistFooter(
                onRequestPressed: () => _onRequestPressed(context),
              ),
            ),
          ],
        ],
      ),
    );
      },
    ),
    );
  }

  /// Constrói a tab do calendário com seletor de endereço
  Widget _buildCalendarTab(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocListener<AddressesBloc, AddressesState>(
      listener: (context, state) {
        if (state is GetAddressesSuccess && _selectedAddress == null) {
          _getPrimaryAddressFromState(state);
        }
      },
      child: Column(
        children: [
          // Seletor de endereço
          Padding(
            padding: EdgeInsets.only(
              top: DSSize.height(16),
              left: DSSize.width(16),
              right: DSSize.width(16),
              bottom: DSSize.height(8),
            ),
            child: AddressSelector(
              currentAddress: _currentAddressDisplay,
              onAddressTap: _onAddressSelected,
            ),
          ),

          // Calendário com diferentes estados
          Expanded(
            child: _selectedAddress == null
                ? _buildNoAddressState(colorScheme, textTheme)
                : _buildCalendarContent(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  /// Estado quando não há endereço selecionado
  Widget _buildNoAddressState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DSSize.width(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: DSSize.width(64),
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            DSSizedBoxSpacing.vertical(16),
            Text(
              'Selecione um endereço',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            DSSizedBoxSpacing.vertical(8),
            Text(
              'Para visualizar as disponibilidades do conjunto, selecione um endereço acima',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Conteúdo do calendário baseado no estado do EnsembleAvailabilityBloc
  Widget _buildCalendarContent(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<EnsembleAvailabilityBloc, EnsembleAvailabilityState>(
      builder: (context, state) {
        if (state is GetAllAvailabilitiesLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DSSize.width(24)),
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          );
        }

        if (state is GetAllAvailabilitiesFailure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DSSize.width(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: DSSize.width(48),
                    color: colorScheme.error,
                  ),
                  DSSizedBoxSpacing.vertical(16),
                  Text(
                    'Erro ao carregar disponibilidades do conjunto',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  DSSizedBoxSpacing.vertical(8),
                  Text(
                    state.error,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is GetAllAvailabilitiesSuccess) {
          final availabilities = state.availabilities;

          if (availabilities.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(DSSize.width(32)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: DSSize.width(64),
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    DSSizedBoxSpacing.vertical(16),
                    Text(
                      'Conjunto não atende neste endereço',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Este conjunto não possui disponibilidades para o endereço selecionado. Tente selecionar outro endereço.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: ArtistAvailabilityCalendar(
              availabilities: availabilities,
              selectedDate: widget.selectedDate,
              onDateSelected: (date) {
                if (_selectedAddress != null && !widget.viewOnly && widget.artist != null) {
                  context.router.push(
                    RequestRoute(
                      selectedDate: date,
                      selectedAddress: _selectedAddress!,
                      artist: widget.artist!,
                    ),
                  );
                }
              },
              requestMinimumEarlinessMinutes: _currentEnsemble?.professionalInfo?.requestMinimumEarliness,
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(DSSize.width(32)),
            child: Text(
              'Selecione um endereço para ver as disponibilidades do conjunto',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

