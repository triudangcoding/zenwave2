import 'package:flutter/material.dart';

import 'core/navigation/tab_navigation_controller.dart';
import 'core/theme/app_colors.dart';
import 'sections/health_management/HealthManagementPage.dart';
import 'sections/home/HomePage.dart';
import 'sections/meditation/MeditationPage.dart';
import 'sections/profile/ProfilePage.dart';

void main() {
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
      home: const MainTabPage(),
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
    MeditationPage(),
    HealthManagementPage(),
    ProfilePage(),
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
    TabNavigationController.selectedIndex
        .removeListener(_handleExternalTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
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
                icon: Icon(Icons.self_improvement_outlined),
                activeIcon: Icon(Icons.self_improvement),
                label: 'Bài tập thiền',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety_outlined),
                activeIcon: Icon(Icons.health_and_safety),
                label: 'Quản lý sức khỏe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
