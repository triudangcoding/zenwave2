import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isScreenModeEnabled = false;
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.neutral600,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ZenWave',
                    style: TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 40 / 1.6,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '0968868886',
                    style: TextStyle(
                      color: AppColors.neutral600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileActionTile(
            icon: Icons.person_outline,
            title: 'Tài khoản',
            backgroundColor: AppColors.neutral100.withOpacity(0.55),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _ProfileActionTile(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {},
          ),
          _ProfileActionTile(
            icon: Icons.smartphone_outlined,
            title: 'Chế độ màn hình',
            trailing: Switch(
              value: _isScreenModeEnabled,
              activeColor: AppColors.cyan500,
              inactiveThumbColor: AppColors.neutral900,
              inactiveTrackColor: AppColors.neutral300,
              onChanged: (value) {
                setState(() {
                  _isScreenModeEnabled = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isScreenModeEnabled = !_isScreenModeEnabled;
              });
            },
          ),
          _ProfileActionTile(
            icon: Icons.notifications_none,
            title: 'Thông báo',
            trailing: Switch(
              value: _isNotificationEnabled,
              activeColor: AppColors.cyan500,
              inactiveThumbColor: AppColors.neutral900,
              inactiveTrackColor: AppColors.neutral300,
              onChanged: (value) {
                setState(() {
                  _isNotificationEnabled = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isNotificationEnabled = !_isNotificationEnabled;
              });
            },
          ),
          _ProfileActionTile(
            icon: Icons.shield_outlined,
            title: 'Bảo mật',
            onTap: () {},
          ),
          _ProfileActionTile(
            icon: Icons.help_outline,
            title: 'Hỗ trợ',
            onTap: () {},
          ),
          _ProfileActionTile(
            icon: Icons.logout,
            title: 'Thoát',
            showChevron: false,
            onTap: () {},
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
    this.showChevron = true,
    this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showChevron;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
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
                (showChevron
                    ? const Icon(
                        Icons.chevron_right,
                        color: AppColors.neutral600,
                        size: 24,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
