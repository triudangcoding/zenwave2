import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../sections/profile/ProfilePage.dart';

void openProfileShortcutPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.neutral900,
          title: const Text(
            'Cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ),
        body: const SafeArea(top: false, child: ProfilePage()),
      ),
    ),
  );
}

class ProfileShortcutOverlay extends StatefulWidget {
  const ProfileShortcutOverlay({
    super.key,
    required this.itemCount,
    required this.targetIndex,
    required this.onTapTarget,
    this.holdDuration = const Duration(seconds: 5),
  });

  final int itemCount;
  final int targetIndex;
  final VoidCallback onTapTarget;
  final Duration holdDuration;

  @override
  State<ProfileShortcutOverlay> createState() => _ProfileShortcutOverlayState();
}

class _ProfileShortcutOverlayState extends State<ProfileShortcutOverlay> {
  Timer? _holdTimer;
  bool _didOpenProfile = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _didOpenProfile = false;
    _holdTimer = Timer(widget.holdDuration, () {
      if (!mounted) {
        return;
      }
      _didOpenProfile = true;
      openProfileShortcutPage(context);
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / widget.itemCount;
          final double left = itemWidth * widget.targetIndex;

          return Stack(
            children: [
              Positioned(
                left: left,
                width: itemWidth,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) => _startHoldTimer(),
                  onTapUp: (_) => _cancelHoldTimer(),
                  onTapCancel: _cancelHoldTimer,
                  onTap: () {
                    if (_didOpenProfile) {
                      _didOpenProfile = false;
                      return;
                    }
                    widget.onTapTarget();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
