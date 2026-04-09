import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'DetailBrain.dart';
import 'HealthTabMenu.dart';

class RelaxPage extends StatelessWidget {
  const RelaxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE6E6E6),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Phiền thiền',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.72,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFFCFE9EE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0B9AB2),
                      ),
                    ),
                    const Center(
                      child: Text(
                        '7:35',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDF2CF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Trạng thái: Thư giãn sâu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D9D55),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Đạt 80% thời gian tỉnh tâm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3A9F56),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Mục tiêu : Duy trì Alpha/Theta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DetailBrainPage(),
                    ),
                  );
                },
                child: const Text(
                  'Xem chi tiết sóng não  ➜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF158EA2),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3838),
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(42),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kết thúc',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF158EA2),
                        minimumSize: const Size.fromHeight(42),
                        side: const BorderSide(
                          color: Color(0xFF7CC9D5),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tạm dừng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}