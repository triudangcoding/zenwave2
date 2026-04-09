import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/assessment/AssessmentHubScreen.dart';
import '../../screens/Breathing/BreathingListScreen.dart';
import '../brain_overview/BrainOverviewPage.dart';
import '../meditation_space/MeditationSpacePage.dart';
import 'StartMeditation2.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openBrainOverview(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BrainOverviewPage()));
  }

  void _openMeditationSpace(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MeditationSpacePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: _buildHeader(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecommendedCard(context),
                    const SizedBox(height: 10),
                    _buildStatsCard(),
                    const SizedBox(height: 12),
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.55,
                      children: [
                        _OverviewCard(
                          title: 'Tổng Quan Sóng Não',
                          backgroundColor: AppColors.homeOverviewBrain,
                          imagePath: 'assets/Images/HomePage2.png',
                          onTap: () => _openBrainOverview(context),
                        ),
                        _OverviewCard(
                          title: 'Không gian thiền định',
                          backgroundColor: AppColors.homeOverviewSpace,
                          imagePath: 'assets/Images/HomePage4.png',
                          onTap: () => _openMeditationSpace(context),
                        ),
                        _OverviewCard(
                          title: 'Bài tập thở',
                          backgroundColor: AppColors.homeOverviewMood,
                          imagePath: 'assets/Images/HomePage3.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BreathingListScreen(),
                              ),
                            );
                          },
                        ),
                        _OverviewCard(
                          title: 'Bài tập đánh giá sức khỏe',
                          backgroundColor: AppColors.homeOverviewAi,
                          imagePath: 'assets/Images/HomePage5.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AssessmentHubScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDailySection(),
                    const SizedBox(height: 14),
                    _buildQuickActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConnectDeviceSheet(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Connect Device',
      barrierDismissible: true,
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              heightFactor: 1,
              child: const _ConnectDeviceSideSheet(),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.homeWelcomeAvatar,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Images/HomePage3.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 21,
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Chào buổi sáng, Zenwave',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openConnectDeviceSheet(context),
              child: const Icon(
                Icons.bluetooth_searching,
                size: 21,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.homeRecommendedCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hãy giữ nhịp hôm nay',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bài tập được đề xuất:',
                    style: TextStyle(fontSize: 13, color: AppColors.neutral900),
                  ),
                  Text(
                    'Thiền thở (10 phút)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StartMeditationPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cyan500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text(
                        'Bắt đầu thiền ngay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Image.asset(
                  'assets/Images/HomePage1.png',
                  height: 144,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.self_improvement,
                    size: 90,
                    color: AppColors.cyan600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.homeStatsBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '600\'',
            label: 'Tổng thời gian',
            color: AppColors.homeStatsTime,
          ),
          _StatItem(
            value: '21',
            label: 'Chuỗi Ngày',
            color: AppColors.homeStatsStreak,
          ),
          _StatItem(
            value: '92',
            label: 'Health Score',
            color: AppColors.homeStatsScore,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hằng ngày',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.homeSectionCardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.homeSectionCardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.homeCardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Chưa có dữ liệu sóng não',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homeDailyHeadline,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy kết nối thiết bị để bắt đầu theo dõi chỉ số tập trung và thư giãn.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: AppColors.homeDailyBody,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Xem hướng dẫn kết nối thiết bị ->',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.homeDailyLink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tác vụ nhanh',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.0,
          children: const [
            _QuickActionTile(
              icon: Icons.self_improvement_outlined,
              label: 'Bắt đầu\nthiền 10 phút',
              iconColor: AppColors.homeQuickMeditationIcon,
              iconBackground: AppColors.homeQuickMeditationBg,
            ),
            _QuickActionTile(
              icon: Icons.calendar_month_outlined,
              label: 'Đặt lịch\nnhắc nhở',
              iconColor: AppColors.homeQuickReminderIcon,
              iconBackground: AppColors.homeQuickReminderBg,
            ),
            _QuickActionTile(
              icon: Icons.description_outlined,
              label: 'Xem tiến\ntrình tuần',
              iconColor: AppColors.homeQuickWeeklyIcon,
              iconBackground: AppColors.homeQuickWeeklyBg,
            ),
            _QuickActionTile(
              icon: Icons.handshake_outlined,
              label: 'Kết nối\nchuyên gia',
              iconColor: AppColors.homeQuickExpertIcon,
              iconBackground: AppColors.homeQuickExpertBg,
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectDeviceSideSheet extends StatefulWidget {
  const _ConnectDeviceSideSheet();

  @override
  State<_ConnectDeviceSideSheet> createState() =>
      _ConnectDeviceSideSheetState();
}

class _ConnectDeviceSideSheetState extends State<_ConnectDeviceSideSheet> {
  bool _isScanning = true;
  bool _isConnecting = false;
  bool _isConnected = false;
  String _selectedDevice = 'ZenWave NeuroBand X2';
  double _batteryLevel = 0.78;
  Timer? _scanTimer;

  final List<String> _devices = <String>[
    'ZenWave NeuroBand X2',
    'ZenWave NeuroBand Pro',
    'MindFlow Sensor A1',
  ];

  @override
  void initState() {
    super.initState();
    _scanTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isScanning = false;
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _isConnecting = true;
      _isConnected = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _batteryLevel = 0.82;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kết nối thiết bị sóng não',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.neutral700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.teal100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal300),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _batteryLevel,
                            strokeWidth: 4,
                            backgroundColor: AppColors.teal200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.cyan500,
                            ),
                          ),
                          Text(
                            '${(_batteryLevel * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isConnected
                            ? 'Đã kết nối với $_selectedDevice'
                            : 'Trạng thái pin thiết bị khả dụng',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Thiết bị gần đây',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const Spacer(),
                  if (_isScanning)
                    const Text(
                      'Đang quét...',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.cyan700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final deviceName = _devices[index];
                    final selected = _selectedDevice == deviceName;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDevice = deviceName;
                          _isConnected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal100 : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.cyan500
                                : AppColors.homeQuickTileBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.cyan200
                                    : AppColors.neutral100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.sensors,
                                color: selected
                                    ? AppColors.cyan700
                                    : AppColors.neutral700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deviceName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                  Text(
                                    _isConnected && selected
                                        ? 'Đã ghép nối'
                                        : 'Sẵn sàng kết nối',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.neutral700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isConnected && selected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.green600,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isConnecting ? null : _connectToDevice,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cyan500,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(_isConnected ? 'Đã kết nối' : 'Kết nối thiết bị'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral900),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.backgroundColor,
    required this.imagePath,
    this.onTap,
  });

  final String title;
  final Color backgroundColor;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.homeCardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: backgroundColor),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: AppColors.homeOverviewFrost),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 80,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.homeOverviewInnerShadowTop,
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.homeOverviewInnerShadowBottom,
                        ],
                        stops: [0.0, 0.15, 0.72, 1.0],
                      ),
                      border: Border.all(color: AppColors.homeOverviewStroke),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.homeQuickTileBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 34, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
