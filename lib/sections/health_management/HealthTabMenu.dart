import 'package:flutter/material.dart';

import '../../core/navigation/tab_navigation_controller.dart';
import '../../core/theme/app_colors.dart';

class HealthTabMenu extends StatelessWidget {
  const HealthTabMenu({super.key, this.currentIndex = 2});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
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
            if (index == currentIndex) {
              return;
            }

            TabNavigationController.selectedIndex.value = index;
            Navigator.of(context).popUntil((route) => route.isFirst);
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
    );
  }
}