import 'package:flutter/material.dart';

import 'ECOGMockScreen.dart';
import 'MSTMockScreen.dart';
import 'PSQIMockScreen.dart';
import 'StressThermometerMockScreen.dart';
import 'assessment_theme.dart';

class AssessmentHubScreen extends StatelessWidget {
  const AssessmentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const padding = 16.0;
    const spacing = 12.0;
    final cardWidth = (screenWidth - (padding * 2) - spacing) / 2;
    final cardHeight = cardWidth * 0.95;

    return Scaffold(
      backgroundColor: AssessmentTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Đánh giá tổng quát sức khỏe của bạn',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AssessmentTheme.textPrimary,
          ),
        ),
        foregroundColor: AssessmentTheme.textPrimary,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Danh sách bài đánh giá',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AssessmentTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _AssessmentCard(
                    width: cardWidth,
                    height: cardHeight,
                    title: 'Nhu cầu hỗ trợ',
                    subtitle: 'Stress Thermometer',
                    icon: Icons.speed,
                    cardColor: const Color(0xFFC89252),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StressThermometerMockScreen(),
                        ),
                      );
                    },
                  ),
                  _AssessmentCard(
                    width: cardWidth,
                    height: cardHeight,
                    title: 'Dinh dưỡng',
                    subtitle: 'MST',
                    icon: Icons.restaurant,
                    cardColor: const Color(0xFF2EA342),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MSTMockScreen(),
                        ),
                      );
                    },
                  ),
                  _AssessmentCard(
                    width: cardWidth,
                    height: cardHeight,
                    title: 'Thể lực',
                    subtitle: 'ECOG',
                    icon: Icons.accessibility_new,
                    cardColor: const Color(0xFF1B8BA3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ECOGMockScreen(),
                        ),
                      );
                    },
                  ),
                  _AssessmentCard(
                    width: cardWidth,
                    height: cardHeight,
                    title: 'Giấc ngủ',
                    subtitle: 'PSQI',
                    icon: Icons.bedtime,
                    cardColor: const Color(0xFFE75863),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PSQIMockScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.width,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.onTap,
  });

  final double width;
  final double height;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -14,
              right: -10,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bắt đầu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
