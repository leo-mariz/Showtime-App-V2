import 'package:app/features/app_navigation/presentation/widgets/bottom_navigation_bar.dart';
import 'package:app/features/chat/presentation/screens/chat_screen.dart';
import 'package:app/features/artist_dashboard/presentation/screens/artist_dashboard_screen.dart';
import 'package:app/features/contracts/presentation/screens/artists/artist_contract_screen.dart';
import 'package:app/features/explore/presentation/screens/explore_screen.dart';
import 'package:app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:app/features/contracts/presentation/screens/clients/client_contracts_screen.dart';
import 'package:app/features/profile/artists/presentation/screens/artist_profile_screen.dart';
import 'package:app/features/profile/clients/presentation/screens/client_profile_screen.dart';
import 'package:flutter/material.dart';
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
    ChatScreen(),
    ClientProfileScreen(),
  ];

  // Páginas para professores
  List<Widget> get _artistPages => [
    ArtistDashboardScreen(),
    ArtistContractsScreen(),
    ChatScreen(),
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
      label: 'Solicitações',
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
      icon: Icon(Icons.event),
      label: 'Apresentações',
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
      ),
    );
  }
}