import 'package:flutter/material.dart';

import 'core/navigation/tab_navigation_controller.dart';
import 'core/theme/app_colors.dart';
import 'screens/onboarding/WelcomeOnboardingScreen.dart';
import 'sections/brain_waves/BrainWavesPage.dart';
import 'sections/home/HomePage.dart';
import 'sections/meditation/MeditationPage.dart';
import 'sections/profile/ProfilePage.dart';
import 'sections/smart_ring/smart_ring_page.dart';
import 'services/app_state_service.dart';
import 'services/smart_ring/smart_ring_connection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStateService.loadFromPrefs();
  AppStateService.bindBleState();
  await SmartRingConnectionService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zenwave',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal500),
      ),
      home: const _AppRoot(),
    );
  }
}

/// Listens to [AppStateService.isOnboardedNotifier] and switches between
/// the onboarding flow and the main tab shell.
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppStateService.isOnboardedNotifier,
      builder: (BuildContext ctx, bool onboarded, _) {
        if (!onboarded) {
          return const WelcomeOnboardingScreen();
        }
        return const MainTabPage();
      },
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    BrainWavesPage(),
    MeditationPage(),
    ProfilePage(),
    SmartRingPage(),
  ];

  @override
  void initState() {
    super.initState();
    TabNavigationController.selectedIndex.value = _selectedIndex;
    TabNavigationController.selectedIndex.addListener(_handleExternalTabChange);
  }

  void _handleExternalTabChange() {
    final int requestedIndex = TabNavigationController.selectedIndex.value;

    if (requestedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = requestedIndex;
      });
    }
  }

  @override
  void dispose() {
    TabNavigationController.selectedIndex.removeListener(
      _handleExternalTabChange,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.cyan400,
            unselectedItemColor: AppColors.neutral500,
            selectedFontSize: 11.4,
            unselectedFontSize: 11.4,
            iconSize: 25.08,
            selectedLabelStyle: const TextStyle(
              fontSize: 11.4,
              fontWeight: FontWeight.w400,
              height: 1.2,
              overflow: TextOverflow.visible,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11.4,
              fontWeight: FontWeight.w400,
              height: 1.2,
              overflow: TextOverflow.visible,
            ),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                TabNavigationController.selectedIndex.value = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.waves_outlined),
                activeIcon: Icon(Icons.waves),
                label: 'Sóng não',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.self_improvement_outlined),
                activeIcon: Icon(Icons.self_improvement),
                label: 'Bài tập thiền',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety_outlined),
                activeIcon: Icon(Icons.health_and_safety),
                label: 'Smart Ring',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
