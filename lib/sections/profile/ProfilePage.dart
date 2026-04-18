import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/app_state_service.dart';
import '../../services/brain_waves_mock_sleep_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: AppStateService.wearingDetectionEnabledNotifier,
            builder: (_, wearingEnabled, __) {
              return _ProfileActionTile(
                icon: Icons.sensors,
                title: 'Nhận diện đeo băng đô',
                trailing: Switch(
                  value: wearingEnabled,
                  activeThumbColor: AppColors.cyan500,
                  activeTrackColor: AppColors.cyan500.withValues(alpha: 0.35),
                  inactiveThumbColor: AppColors.neutral900,
                  inactiveTrackColor: AppColors.neutral300,
                  onChanged: (value) {
                    AppStateService.wearingDetectionEnabledNotifier.value =
                        value;
                  },
                ),
                onTap: () {
                  AppStateService.wearingDetectionEnabledNotifier.value =
                      !AppStateService.wearingDetectionEnabledNotifier.value;
                },
              );
            },
          ),
          _ProfileActionTile(
            icon: Icons.restore,
            title: 'Xoá dữ liệu',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text(
                    'Bạn có chắc muốn xoá toàn bộ dữ liệu? Bạn sẽ phải trả lời lại bộ câu hỏi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Huỷ'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Xoá',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await AppStateService.resetAll();
                await BrainWavesMockSleepService.regenerateSummary();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.cyan500, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.neutral800,
                  fontSize: 30 / 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral600,
                  size: 24,
                ),
          ],
        ),
      ),
    );
  }
}
