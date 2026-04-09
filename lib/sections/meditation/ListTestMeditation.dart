import 'package:flutter/material.dart';

import 'LessonTestMeditation.dart';
import '../../core/theme/app_colors.dart';
import '../health_management/HealthTabMenu.dart';

class ListTestMeditationPage extends StatefulWidget {
  const ListTestMeditationPage({super.key});

  @override
  State<ListTestMeditationPage> createState() => _ListTestMeditationPageState();
}

enum MeditationFilter { all, focus, relax }

class MeditationItem {
  const MeditationItem({
    required this.title,
    required this.totalLessons,
    required this.filter,
  });

  final String title;
  final int totalLessons;
  final MeditationFilter filter;
}

class _ListTestMeditationPageState extends State<ListTestMeditationPage> {
  final TextEditingController _searchController = TextEditingController();

  MeditationFilter _selectedFilter = MeditationFilter.all;
  bool _sortAscending = true;
  bool _isVoiceMode = false;

  final List<MeditationItem> _meditationItems = const [
    MeditationItem(
      title: 'Làm Quen Với Thiền Định',
      totalLessons: 10,
      filter: MeditationFilter.focus,
    ),
    MeditationItem(
      title: 'Thiền Cân Bằng Cảm Xúc',
      totalLessons: 10,
      filter: MeditationFilter.relax,
    ),
    MeditationItem(
      title: 'Thiền Hít Thở Sâu & Thư Giãn',
      totalLessons: 10,
      filter: MeditationFilter.relax,
    ),
    MeditationItem(
      title: 'Ổn Định Tâm Trí (Tập trung)',
      totalLessons: 10,
      filter: MeditationFilter.focus,
    ),
    MeditationItem(
      title: 'Thiền Buổi Sáng',
      totalLessons: 10,
      filter: MeditationFilter.focus,
    ),
    MeditationItem(
      title: 'Thiền Quét Toàn Thân (Body Scan)',
      totalLessons: 10,
      filter: MeditationFilter.relax,
    ),
    MeditationItem(
      title: 'Thiền Giảm Căng Thẳng',
      totalLessons: 10,
      filter: MeditationFilter.relax,
    ),
    MeditationItem(
      title: 'Thiền Đi Bộ Nhẹ Nhàng',
      totalLessons: 10,
      filter: MeditationFilter.relax,
    ),
  ];

  List<MeditationItem> get _displayedItems {
    final String keyword = _searchController.text.trim().toLowerCase();

    final List<MeditationItem> filtered = _meditationItems.where((item) {
      final bool matchFilter =
          _selectedFilter == MeditationFilter.all ||
          item.filter == _selectedFilter;
      final bool matchSearch =
          keyword.isEmpty || item.title.toLowerCase().contains(keyword);
      return matchFilter && matchSearch;
    }).toList();

    filtered.sort((a, b) {
      final int result = a.title.compareTo(b.title);
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  void _toggleVoiceMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVoiceMode
              ? 'Đã bật chế độ giọng nói (demo).'
              : 'Đã tắt chế độ giọng nói.',
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _openLessonPage(MeditationItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonTestMeditationPage(
          courseTitle: item.title,
          totalLessons: item.totalLessons,
          completedProgress: 5,
          inProgressLesson: 4,
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final MeditationFilter? selected =
        await showModalBottomSheet<MeditationFilter>(
          context: context,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            MeditationFilter draft = _selectedFilter;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bộ lọc bài thiền',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildFilterChip(
                            'Tất cả',
                            MeditationFilter.all,
                            draft,
                            setModalState,
                          ),
                          _buildFilterChip(
                            'Tập trung',
                            MeditationFilter.focus,
                            draft,
                            setModalState,
                          ),
                          _buildFilterChip(
                            'Thư giãn',
                            MeditationFilter.relax,
                            draft,
                            setModalState,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(draft),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.cyan500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedFilter = selected;
    });
  }

  Widget _buildFilterChip(
    String label,
    MeditationFilter value,
    MeditationFilter selected,
    void Function(void Function()) setModalState,
  ) {
    final bool isSelected = selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        setModalState(() {
          selected = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected ? AppColors.cyan100 : AppColors.neutral100,
          border: Border.all(
            color: isSelected ? AppColors.cyan400 : AppColors.neutral200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.cyan700 : AppColors.neutral700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MeditationItem> items = _displayedItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Bài thiền Cơ Bản',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.neutral300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài thiền...',
                        hintStyle: const TextStyle(
                          color: AppColors.neutral500,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.neutral400,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _toggleVoiceMode,
                          icon: Icon(
                            _isVoiceMode ? Icons.mic : Icons.mic_none,
                            color: _isVoiceMode
                                ? AppColors.cyan500
                                : AppColors.neutral400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openFilterSheet,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.neutral100,
                            side: BorderSide.none,
                            alignment: Alignment.centerLeft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                          ),
                          icon: const Icon(
                            Icons.filter_alt_outlined,
                            size: 18,
                            color: AppColors.neutral700,
                          ),
                          label: Text(
                            _selectedFilter == MeditationFilter.all
                                ? 'Bộ lọc'
                                : _selectedFilter == MeditationFilter.focus
                                ? 'Tập trung'
                                : 'Thư giãn',
                            style: const TextStyle(
                              color: AppColors.neutral700,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleSort,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.neutral100,
                            side: BorderSide.none,
                            alignment: Alignment.centerLeft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                          ),
                          icon: const Icon(
                            Icons.sort_by_alpha,
                            size: 18,
                            color: AppColors.neutral700,
                          ),
                          label: Text(
                            _sortAscending ? 'Sắp xếp A-Z' : 'Sắp xếp Z-A',
                            style: const TextStyle(
                              color: AppColors.neutral700,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final MeditationItem item = items[index];
                  return _MeditationListTile(
                    item: item,
                    onTap: () => _openLessonPage(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationListTile extends StatelessWidget {
  const _MeditationListTile({required this.item, required this.onTap});

  final MeditationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.teal100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.teal200),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 21,
                  color: AppColors.cyan500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyan500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.totalLessons} bài thiền',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral900,
                      ),
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
