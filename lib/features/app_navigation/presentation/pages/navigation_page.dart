import 'package:app/features/app_navigation/presentation/widgets/bottom_navigation_bar.dart';
import 'package:app/features/chat/presentation/screens/chat_screen.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/unread_count_bloc.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/events/unread_count_events.dart';
import 'package:app/features/chat/presentation/bloc/unread_count/states/unread_count_states.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/pending_contracts_count_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/events/pending_contracts_count_events.dart';
import 'package:app/features/contracts/presentation/bloc/pending_contracts_count/states/pending_contracts_count_states.dart';
import 'package:app/features/artists/artist_dashboard/presentation/screens/artist_dashboard_screen.dart';
import 'package:app/features/contracts/presentation/screens/artists/artist_contract_screen.dart';
// import 'package:app/features/explore/presentation/screens/explore_screen.dart';
// import 'package:app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:app/features/contracts/presentation/screens/clients/client_contracts_screen.dart';
import 'package:app/features/explore/presentation/screens/explore_screen.dart';
import 'package:app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:app/features/artists/artist_availability/presentation/screens/availability_calendar_screen.dart';
import 'package:app/features/artists/artists/presentation/screens/artist_profile_screen.dart';
import 'package:app/features/clients/presentation/screens/client_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

// GlobalKey para acessar o estado do NavigationPage
final _navigationPageKey = GlobalKey<_NavigationPageState>();

@RoutePage(deferredLoading: true)
class NavigationPage extends StatefulWidget {
  final bool isArtist;

  const NavigationPage({
    super.key,
    this.isArtist = false,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
  
  /// Método estático para navegar para uma página específica
  static void navigateToPageIndex(BuildContext context, int index) {
    final state = _navigationPageKey.currentState;
    if (state != null) {
      state.navigateToPage(index);
    }
  }
}

class _NavigationPageState extends State<NavigationPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  late bool isArtist;

  // Páginas para alunos/clientes
  List<Widget> get _clientPages => [
    ExploreScreen(),
    FavoritesScreen(),
    ClientContractsScreen(),
    ChatScreen(isArtist: false),
    ClientProfileScreen(),
  ];

  // Páginas para professores
  List<Widget> get _artistPages => [
    ArtistDashboardScreen(),
    AvailabilityCalendarScreen(),
    ArtistContractsScreen(),
    ChatScreen(isArtist: true),
    ArtistProfileScreen(),
  ];

  // Items do menu para alunos
  List<BottomNavigationBarItem> get _clientNavItems => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: 'Explorar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favoritos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.mic),
      label: 'Shows',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message_rounded),
      label: 'Mensagens',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  // Items do menu para professores
  List<BottomNavigationBarItem> get _artistNavItems => const [
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Calendário',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.mic),
      label: 'Shows',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message_rounded),
      label: 'Mensagens',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    isArtist = widget.isArtist;
    _pageController = PageController(initialPage: 0);
    
    // Carregar contadores ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Carregar contador de mensagens não lidas
        context.read<UnreadCountBloc>().add(LoadUnreadCountEvent());
        // Carregar contador de contratos pendentes (com role atual)
        context.read<PendingContractsCountBloc>().add(LoadPendingContractsCountEvent(isArtist: isArtist));
      }
    });
  }

  @override
  void didUpdateWidget(NavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isArtist != widget.isArtist) {
      setState(() {
        isArtist = widget.isArtist;
        // Resetar para a primeira página quando mudar o tipo de usuário
        _currentIndex = 0;
        _pageController.jumpToPage(0);
      });
      // Recarregar contador com novo role
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PendingContractsCountBloc>().add(LoadPendingContractsCountEvent(isArtist: isArtist));
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  /// Método público para permitir navegação programática entre páginas
  void navigateToPage(int index) {
    if (index >= 0 && index < (isArtist ? _artistPages.length : _clientPages.length)) {
      _onTabTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = isArtist ? _artistPages : _clientPages;
    final navItems = isArtist ? _artistNavItems : _clientNavItems;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    
    // Índices dos itens no bottom nav
    final chatIndex = 3;
    final contractsIndex = isArtist ? 2 : 2; // Shows para artista, Solicitações para cliente
    
    return BlocBuilder<UnreadCountBloc, UnreadCountState>(
      builder: (context, unreadState) {
        return BlocBuilder<PendingContractsCountBloc, PendingContractsCountState>(
          builder: (context, contractsState) {
            // Obter contador de mensagens não lidas
            final hasUnreadMessages = unreadState is UnreadCountSuccess && unreadState.count > 0;
            
            // Obter contador de contratos pendentes (filtrado por role atual)
            final hasPendingContracts = contractsState is PendingContractsCountSuccess && 
                contractsState.totalUnseen > 0;
            
            // Criar mapa de badges
            final badgeIndicators = <int, bool>{};
            if (hasUnreadMessages) {
              badgeIndicators[chatIndex] = true;
            }
            if (hasPendingContracts) {
              badgeIndicators[contractsIndex] = true;
            }
            
            return Scaffold(
              key: _navigationPageKey,
              
              backgroundColor: backgroundColor,
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: navItems,
                badgeIndicators: badgeIndicators,
              ),
            );
          },
        );
      },
    );
  }
}