import 'package:flutter/material.dart';

import 'ListTestMeditation.dart';

class MeditationPage extends StatelessWidget {
  const MeditationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildStreakSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Bài thiền Cơ Bản'),
                    const SizedBox(height: 16),
                    _buildGridBasic(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Bài thiền Nâng Cao'),
                    const SizedBox(height: 16),
                    _buildGridAdvanced(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.mic_none, color: Colors.grey),
          hintText: 'Tìm kiếm bài thiền...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bài thiền đề xuất',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Thiền Cân Bằng Cảm Xúc',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0093AD),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10 phút - Tập trung',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF0093AD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text(
                            'Bắt đầu ngay',
                            style: TextStyle(
                              color: Color(0xFF0093AD),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child:
                      const SizedBox(), // Khoảng trống để text luôn nằm bên trái và không đè lên ảnh
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom:
                20, // Kéo phần đáy của ảnh lên bằng với mép dưới của Padding => ngang bằng nút "Bắt Đầu Ngay"
            child: Image.asset(
              'assets/Images/123123.png',
              height:
                  130, // Điều chỉnh nhẹ lại kích thước sau khi đã đưa ảnh lên để không bị lấn mất tiêu đề
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.self_improvement,
                  size: 140,
                  color: Color(0xFF2796A8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.self_improvement,
                  color: Color(0xFF199A37),
                  size: 34,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: const Text(
                    'Bài thiền\nđang luyện',
                    style: TextStyle(
                      color: Color(0xFF199A37),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_special_outlined,
                  color: Color(0xFFF29B18),
                  size: 34,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: const Text(
                    'Bài thiền\nđã lưu',
                    style: TextStyle(
                      color: Color(0xFFF29B18),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0093AD), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Luyện tập Hạn Mức (Streak)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hít Thở Sâu 5 Phút',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0093AD),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bài thiền nhanh • 5 phút',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0093AD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Bắt đầu',
                  style: TextStyle(
                    color: Color(0xFF0093AD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  void _openBasicMeditationList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ListTestMeditationPage()),
    );
  }

  Widget _buildGridBasic(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      childAspectRatio:
          1.9, // Vẫn thấp hơn trước nhưng đủ chỗ để tránh overflow
      children: [
        _buildBasicCard(
          'Làm quen với\nthiền định',
          '10 bài thiền',
          onTap: () => _openBasicMeditationList(context),
        ),
        _buildBasicCard(
          'Làm quen với\nthiền định',
          '10 bài thiền',
          onTap: () => _openBasicMeditationList(context),
        ),
        _buildBasicCard(
          'Làm quen với\nthiền định',
          '10 bài thiền',
          onTap: () => _openBasicMeditationList(context),
        ),
        _buildSeeAllCard(false, onTap: () => _openBasicMeditationList(context)),
      ],
    );
  }

  Widget _buildGridAdvanced() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildAdvancedCard('Làm quen với\nthiền định', '10 bài thiền'),
        _buildAdvancedCard('Làm quen với\nthiền định', '10 bài thiền'),
        _buildAdvancedCard('Làm quen với\nthiền định', '10 bài thiền'),
        _buildSeeAllCard(true),
      ],
    );
  }

  Widget _buildBasicCard(String title, String subtitle, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: Color(0xFF0093AD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 1), // Căn đỉnh text với đỉnh icon
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0093AD),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
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

  Widget _buildAdvancedCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(
              'Mở khóa khi hoàn thành thiền Cơ Bản',
              style: TextStyle(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllCard(bool isAdvanced, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isAdvanced
                ? const Color(0xFFEDEDED)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            border: isAdvanced ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xem toàn bộ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAdvanced
                        ? Colors.black54
                        : const Color(0xFF0093AD),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: isAdvanced ? Colors.black54 : const Color(0xFF0093AD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
