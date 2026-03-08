import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../applications/applications_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _setIndex(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainTabScope(
      index: _currentIndex,
      onTabSelected: _setIndex,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            NotificationsScreen(),
            ApplicationsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _setIndex,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon:
                  Icon(Icons.notifications, color: AppColors.primary),
              label: 'Notifs',
            ),
            NavigationDestination(
              icon: Icon(Icons.all_inbox_outlined),
              selectedIcon:
                  Icon(Icons.inbox, color: AppColors.primary),
              label: 'Candidatures',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class MainTabScope extends InheritedWidget {
  const MainTabScope({
    super.key,
    required this.index,
    required this.onTabSelected,
    required super.child,
  });

  final int index;
  final ValueChanged<int> onTabSelected;

  static MainTabScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<MainTabScope>();
    assert(scope != null, 'MainTabScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(MainTabScope oldWidget) {
    return oldWidget.index != index;
  }
}
