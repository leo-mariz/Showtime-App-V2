import 'package:app/core/config/auto_router_config.gr.dart';
import 'package:app/core/design_system/padding/ds_padding.dart';
import 'package:app/core/design_system/size/ds_size.dart';
import 'package:app/core/design_system/sized_box_spacing/ds_sized_box_spacing.dart';
import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
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
import 'package:app/features/contracts/presentation/bloc/request_availabilities/events/request_availabilities_events.dart';
import 'package:app/features/contracts/presentation/bloc/request_availabilities/request_availabilities_bloc.dart';
import 'package:app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/events/favorites_events.dart';
import 'package:app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:app/features/favorites/presentation/bloc/states/favorites_states.dart';
import 'package:app/features/explore/presentation/bloc/states/explore_states.dart';
import 'package:app/features/explore/presentation/widgets/address_selector.dart';
import 'package:app/features/explore/presentation/widgets/artist_availability_calendar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(deferredLoading: true)
class ArtistExploreScreen extends StatefulWidget {
  final ArtistEntity artist;
  final bool isFavorite;
  final bool viewOnly;
  final DateTime? selectedDate;
  final AddressInfoEntity? selectedAddress;

  const ArtistExploreScreen({
    super.key,
    required this.artist,
    this.isFavorite = false,
    this.viewOnly = false,
    this.selectedDate,
    this.selectedAddress,
  });

  @override
  State<ArtistExploreScreen> createState() => _ArtistExploreScreenState();
}

class _ArtistExploreScreenState extends State<ArtistExploreScreen> {
  AddressInfoEntity? _selectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
      }
    });
    // Se veio com endereço selecionado, usar ele
    if (widget.selectedAddress != null) {
      _selectedAddress = widget.selectedAddress;
      _loadAvailabilities();
    } else {
      // Buscar endereços do AddressesBloc
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  /// Carrega disponibilidades para o endereço selecionado
  void _loadAvailabilities() {
    if (_selectedAddress != null && widget.artist.uid != null) {
      context.read<RequestAvailabilitiesBloc>().add(
        LoadArtistAvailabilitiesEvent(
          artistId: widget.artist.uid!,
          userAddress: _selectedAddress,
        ),
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

    router.push(
      RequestRoute(
        selectedDate: widget.selectedDate ?? DateTime.now(),
        selectedAddress: _selectedAddress!,
        artist: widget.artist,
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

    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is AddFavoriteSuccess) {
          context.showSuccess('Artista adicionado aos favoritos');
          context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
        } else if (state is AddFavoriteFailure) {
          context.showError(state.error);
        } else if (state is RemoveFavoriteSuccess) {
          context.showSuccess('Artista removido dos favoritos');
          context.read<FavoritesBloc>().add(GetFavoriteArtistsEvent());
        } else if (state is RemoveFavoriteFailure) {
          context.showError(state.error);
        }
      },
      child: BasePage(
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
                    // Imagem de perfil
                    Container(
                      height: DSSize.height(300),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: artist.profilePicture != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  artist.profilePicture!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: artist.profilePicture == null
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

                      // Nome artístico
                      Text(
                        artist.artistName ?? 'Artista',
                        style: textTheme.titleLarge?.copyWith(
                          color: onPrimary,
                        ),
                      ),

                      DSSizedBoxSpacing.vertical(8),
                      // Badges de avaliação, contratos e favorito
                      Row(
                        children: [
                          CustomBadge(value: artist.rating?.toStringAsFixed(2) ?? '0.0', icon: Icons.star, color: onPrimaryContainer),
                          DSSizedBoxSpacing.horizontal(8),
                          CustomBadge(title: 'Contratos', value: artist.rateCount?.toString() ?? '0', color: onPrimaryContainer),
                          const Spacer(),
                          if (!widget.viewOnly)
                            BlocBuilder<FavoritesBloc, FavoritesState>(
                              buildWhen: (prev, curr) =>
                                  curr is GetFavoriteArtistsSuccess ||
                                  curr is AddFavoriteSuccess ||
                                  curr is RemoveFavoriteSuccess,
                              builder: (context, favState) {
                                final isFavorite = favState is GetFavoriteArtistsSuccess
                                    ? favState.artists.any((a) => a.uid == artist.uid)
                                    : widget.isFavorite;
                                return FavoriteButton(
                                  isFavorite: isFavorite,
                                  onTap: () {
                                    if (artist.uid == null || artist.uid!.isEmpty) return;
                                    if (isFavorite) {
                                      context.read<FavoritesBloc>().add(
                                        RemoveFavoriteEvent(artistId: artist.uid!),
                                      );
                                    } else {
                                      context.read<FavoritesBloc>().add(
                                        AddFavoriteEvent(artistId: artist.uid!),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                      DSSizedBoxSpacing.vertical(4),

                      

                      // Talentos (Specialty)
                      if (artist.professionalInfo?.specialty?.isNotEmpty ?? false) ...[
                        Wrap(
                          spacing: DSSize.width(8),
                          runSpacing: DSSize.height(8),
                          children: artist.professionalInfo!.specialty!.map(
                            (talent) => GenreChip(label: talent),
                          ).toList(),
                        ),
                      ],

                      

                      DSSizedBoxSpacing.vertical(16),

                      // Bio completa
                      if (artist.professionalInfo?.bio != null) ...[
                        Text(
                          artist.professionalInfo!.bio!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        DSSizedBoxSpacing.vertical(24),
                      ],

                      // Tabs de Estilos/Talentos/Calendário
                      TabsSection(
                        artist: widget.artist,
                        onVideoTap: (videoUrl) => _onVideoTap(videoUrl),
                        calendarTab: _buildCalendarTab(colorScheme, textTheme),
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
              'Para visualizar as disponibilidades do artista, selecione um endereço acima',
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

  /// Conteúdo do calendário baseado no estado do ExploreBloc
  Widget _buildCalendarContent(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        if (state is GetArtistAllAvailabilitiesLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(DSSize.width(24)),
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          );
        }

        if (state is GetArtistAllAvailabilitiesFailure) {
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
                    'Erro ao carregar disponibilidades',
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

        if (state is GetArtistsWithAvailabilitiesSuccess) {
          final availabilities = state.availabilities ?? [];
          
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
                      'Artista não atende neste endereço',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    DSSizedBoxSpacing.vertical(8),
                    Text(
                      'Este artista não possui disponibilidades para o endereço selecionado. Tente selecionar outro endereço.',
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
                // Navegar para tela de solicitação com data selecionada
                if (_selectedAddress != null && !widget.viewOnly) {
                  context.router.push(
                    RequestRoute(
                      selectedDate: date,
                      selectedAddress: _selectedAddress!,
                      artist: widget.artist,
                    ),
                  );
                }
              },
              requestMinimumEarlinessMinutes: widget.artist.professionalInfo?.requestMinimumEarliness,
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(DSSize.width(32)),
            child: Text(
              'Selecione um endereço para ver as disponibilidades',
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

