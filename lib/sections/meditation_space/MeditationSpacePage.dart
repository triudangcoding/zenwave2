import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class MeditationSpacePage extends StatefulWidget {
  const MeditationSpacePage({super.key});

  @override
  State<MeditationSpacePage> createState() => _MeditationSpacePageState();
}

class _MeditationSpacePageState extends State<MeditationSpacePage> {
  final TextEditingController _searchController = TextEditingController();
  int _activeCarouselIndex = 0;
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MeditationVideo> get _filteredMeditations {
    if (_searchKeyword.trim().isEmpty) {
      return _mockMeditations;
    }

    final keyword = _searchKeyword.toLowerCase().trim();
    return _mockMeditations.where((item) {
      return item.title.toLowerCase().contains(keyword) ||
          item.category.toLowerCase().contains(keyword) ||
          item.description.toLowerCase().contains(keyword);
    }).toList();
  }

  void _openMeditationDetail(_MeditationVideo meditation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MeditationDetailPage(meditation: meditation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meditations = _filteredMeditations;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const horizontalPadding = 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8F9FF), Color(0xFFF9FCFE)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: topInset),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  0,
                ),
                child: _Header(onBack: () => Navigator.of(context).maybePop()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    20 + bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchKeyword = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle(
                        title: 'Nổi bật hôm nay',
                        subtitle:
                            'Bộ sưu tập được đề xuất theo trạng thái tinh thần',
                      ),
                      const SizedBox(height: 12),
                      CarouselSlider.builder(
                        itemCount: _featuredMeditations.length,
                        options: CarouselOptions(
                          height: 210,
                          viewportFraction: 0.9,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _activeCarouselIndex = index;
                            });
                          },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          final item = _featuredMeditations[index];
                          return _FeaturedMeditationCarouselCard(
                            meditation: item,
                            onPlay: () => _openMeditationDetail(item),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_featuredMeditations.length, (
                          index,
                        ) {
                          final isActive = index == _activeCarouselIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.meditationSpacePrimary
                                  : AppColors.neutral300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'Danh mục',
                        subtitle: 'Chọn nhanh theo mục tiêu thiền hôm nay',
                      ),
                      const SizedBox(height: 10),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _CategoryChip(
                            iconPath:
                                'assets/Icons/solar_sleeping-circle-broken.png',
                            title: 'Ngủ sâu',
                            color: AppColors.meditationSpacePrimary,
                            backgroundColor:
                                AppColors.meditationSpaceBlueBackground,
                          ),
                          _CategoryChip(
                            iconPath: 'assets/Icons/Vector.png',
                            title: 'Giảm stress',
                            color: AppColors.meditationSpaceOrange,
                            backgroundColor:
                                AppColors.meditationSpacePeachBackground,
                          ),
                          _CategoryChip(
                            iconPath: 'assets/Icons/Group.png',
                            title: 'Tập trung',
                            color: AppColors.meditationSpaceGreen,
                            backgroundColor:
                                AppColors.meditationSpaceMintBackground,
                          ),
                          _CategoryChip(
                            iconPath:
                                'assets/Icons/solar_sleeping-circle-broken.png',
                            title: 'Thiền nhanh',
                            color: AppColors.neutral700,
                            backgroundColor: Color(0xFFF1F5F7),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'Danh sách bài thiền',
                        subtitle:
                            'Có thể mở video và xem trực tiếp ngay trong ứng dụng',
                      ),
                      const SizedBox(height: 12),
                      if (meditations.isEmpty)
                        const _EmptyResultCard()
                      else
                        ListView.separated(
                          itemCount: meditations.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final meditation = meditations[index];
                            return _MeditationListCard(
                              meditation: meditation,
                              onPlay: () => _openMeditationDetail(meditation),
                            );
                          },
                        ),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onBack,
              iconSize: 17,
              splashRadius: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: AppColors.neutral700),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không gian thiền định',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Khơi mở sự tĩnh lặng mỗi ngày',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE8EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.neutral500),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên bài, danh mục, cảm xúc...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Icon(Icons.tune_rounded, color: AppColors.neutral500),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}

class _FeaturedMeditationCarouselCard extends StatelessWidget {
  const _FeaturedMeditationCarouselCard({
    required this.meditation,
    required this.onPlay,
  });

  final _MeditationVideo meditation;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(meditation.thumbnailUrl, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xC3000000)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x99FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meditation.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  meditation.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      meditation.duration,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      meditation.level,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: onPlay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.meditationSpacePrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Xem ngay',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.iconPath,
    required this.title,
    required this.color,
    required this.backgroundColor,
  });

  final String iconPath;
  final String title;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 20, height: 20),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationListCard extends StatelessWidget {
  const _MeditationListCard({required this.meditation, required this.onPlay});

  final _MeditationVideo meditation;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 112,
            maxHeight: 112,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3ECEF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      meditation.thumbnailUrl,
                      width: 96,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meditation.duration,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(
                        meditation.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F9FC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            meditation.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.meditationSpacePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7EE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            meditation.level,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.meditationSpaceGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: onPlay,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.meditationSpacePrimary,
                            foregroundColor: AppColors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text(
                            'Mở',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3ECEF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không tìm thấy bài phù hợp',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Thử tìm theo từ khóa khác như "ngủ sâu", "hít thở", "stress".',
            style: TextStyle(fontSize: 13, color: AppColors.neutral700),
          ),
        ],
      ),
    );
  }
}

class _MeditationDetailPage extends StatelessWidget {
  const _MeditationDetailPage({required this.meditation});

  final _MeditationVideo meditation;

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.tryParse(meditation.youtubeUrl);
    if (uri == null) {
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không mở được video. Vui lòng thử lại.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F9FF),
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Chi tiết bài thiền',
          style: TextStyle(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.neutral700),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.network(
                    meditation.thumbnailUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meditation.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${meditation.duration}  •  ${meditation.level}  •  ${meditation.category}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              meditation.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutral800,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hướng dẫn trước khi thiền',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              meditation.preMeditationSteps.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.meditationSpaceBlueBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.meditationSpacePrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        meditation.preMeditationSteps[index],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EAED)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video hướng dẫn',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meditation.youtubeUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openVideo(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.meditationSpacePrimary,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Text(
                        'Mở video và bắt đầu thiền',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationVideo {
  const _MeditationVideo({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.level,
    required this.thumbnailUrl,
    required this.youtubeUrl,
    required this.preMeditationSteps,
  });

  final String title;
  final String description;
  final String duration;
  final String category;
  final String level;
  final String thumbnailUrl;
  final String youtubeUrl;
  final List<String> preMeditationSteps;
}

const List<_MeditationVideo> _mockMeditations = [
  _MeditationVideo(
    title: 'Thiền thư giãn toàn thân trước khi ngủ',
    description:
        'Làm dịu hệ thần kinh, thả lỏng cơ thể và vào giấc ngủ sâu hơn.',
    duration: '12 phút',
    category: 'Ngủ sâu',
    level: 'Cơ bản',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1000&q=80',
    youtubeUrl: 'https://www.youtube.com/watch?v=inpok4MKVLM',
    preMeditationSteps: [
      'Ngồi hoặc nằm ở tư thế thoải mái, thả lỏng vai và cổ.',
      'Tắt bớt tiếng ồn, để điện thoại ở chế độ yên lặng.',
      'Hít vào chậm 4 giây và thở ra chậm 6 giây trong 3 nhịp trước khi bắt đầu.',
    ],
  ),
  _MeditationVideo(
    title: 'Thiền giảm lo âu trong 10 phút',
    description:
        'Bài thiền ngắn giúp cân bằng nhịp thở và giảm căng thẳng tức thì.',
    duration: '10 phút',
    category: 'Giảm stress',
    level: 'Cơ bản',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1474418397713-7ede21d49118?auto=format&fit=crop&w=1000&q=80',
    youtubeUrl: 'https://www.youtube.com/watch?v=O-6f5wQXSu8',
    preMeditationSteps: [
      'Đặt hai chân chạm sàn và giữ lưng thẳng tự nhiên.',
      'Đặt một tay lên ngực, một tay lên bụng để cảm nhận nhịp thở.',
      'Tự nhắc bản thân: chỉ tập trung vào hơi thở trong vài phút tới.',
    ],
  ),
  _MeditationVideo(
    title: 'Thiền tập trung sâu cho công việc',
    description:
        'Kích hoạt trạng thái tập trung cao độ trước khi bắt đầu phiên làm việc.',
    duration: '15 phút',
    category: 'Tập trung',
    level: 'Trung bình',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1444312645910-ffa973656eba?auto=format&fit=crop&w=1000&q=80',
    youtubeUrl: 'https://www.youtube.com/watch?v=ZToicYcHIOU',
    preMeditationSteps: [
      'Chuẩn bị bàn làm việc gọn gàng, bỏ bớt yếu tố gây xao nhãng.',
      'Ngồi thẳng lưng, mắt nhìn nhẹ về một điểm cố định.',
      'Thiết lập mục tiêu nhỏ cho phiên tập trung sau bài thiền.',
    ],
  ),
  _MeditationVideo(
    title: 'Thiền thở tỉnh thức buổi sáng',
    description:
        'Khởi động tinh thần nhẹ nhàng, làm mới năng lượng cho cả ngày.',
    duration: '8 phút',
    category: 'Thiền nhanh',
    level: 'Cơ bản',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1508672019048-805c876b67e2?auto=format&fit=crop&w=1000&q=80',
    youtubeUrl: 'https://www.youtube.com/watch?v=SEfs5TJZ6Nk',
    preMeditationSteps: [
      'Mở cửa sổ hoặc chọn góc có ánh sáng tự nhiên dịu nhẹ.',
      'Ngồi vững vàng, thả lỏng cơ mặt và hàm.',
      'Đặt ý định cho ngày mới bằng một câu tích cực ngắn.',
    ],
  ),
  _MeditationVideo(
    title: 'Quét cơ thể và giải phóng căng cơ',
    description:
        'Body scan dẫn dắt giúp giải tỏa áp lực vùng cổ vai gáy và lưng.',
    duration: '18 phút',
    category: 'Phục hồi',
    level: 'Nâng cao',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1000&q=80',
    youtubeUrl: 'https://www.youtube.com/watch?v=6p_yaNFSYao',
    preMeditationSteps: [
      'Nằm ngửa hoặc ngồi tựa lưng, giữ cột sống thoải mái.',
      'Thả lỏng lần lượt từ đỉnh đầu xuống vai, lưng và chân.',
      'Nếu có suy nghĩ chen vào, chỉ ghi nhận rồi quay lại cảm nhận cơ thể.',
    ],
  ),
];

final List<_MeditationVideo> _featuredMeditations = _mockMeditations
    .take(4)
    .toList(growable: false);
