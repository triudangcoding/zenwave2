import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'StartMeditation.dart';
import '../../core/theme/app_colors.dart';
import '../health_management/HealthTabMenu.dart';

/// Maps lesson titles → YouTube video IDs (meditation / mindfulness videos).
const Map<String, String> _lessonVideoIds = {
  'Nền tảng hơi thở': 'inpok4MKVLM',       // 5-min breathing meditation
  'Thả lỏng cơ thể': 'MIr3RsUWrdo',        // body relaxation guided
  'Nhận Diện Suy Nghĩ': '4pLUleLdwY4',      // mindfulness of thoughts
  'Cảm Giác Cơ Thể': '15q-N-_kkrU',         // body scan meditation
  'Xử Lý Cảm Xúc Tiêu Cực': 'SEfs5TJZ6Nk', // emotional healing
  'Thiền Từ Bi (Metta)': '-d_AA9H4z9U',      // loving-kindness meditation
  'Thiền Chấp Nhận': 'ZToicYcHIOU',          // acceptance meditation
  'Thiền Lưu Thông': '2K4z_IxsaHE',          // flow meditation
  'Thiền Khai Mở': 'O-6f5wQXSu8',            // open awareness
  'Thiền Giác Ngộ': 'wirV265ZYSw',            // awakening meditation
};

const String _defaultVideoId = 'inpok4MKVLM';

/// Also handle recommendation titles from BrainWavesPage that don't match
/// the standard lesson titles above.
const Map<String, String> _extraVideoIds = {
  'Thiền Hít Thở Sâu & Thư Giãn': 'inpok4MKVLM',
  'Thiền Buổi Sáng': '1ZYbU82GVz4',
  'Thiền Cân Bằng Cảm Xúc': 'SEfs5TJZ6Nk',
  'Ổn Định Tâm Trí (Tập trung)': '4pLUleLdwY4',
  'Thiền Giảm Căng Thẳng': 'MIr3RsUWrdo',
  'Thiền Quét Toàn Thân (Body Scan)': '15q-N-_kkrU',
  'Thiền Đi Bộ Nhẹ Nhàng': '2K4z_IxsaHE',
};

class DetailLessonMeditationPage extends StatefulWidget {
  const DetailLessonMeditationPage({
    super.key,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.isResume,
  });

  final int lessonNumber;
  final String lessonTitle;
  final bool isResume;

  @override
  State<DetailLessonMeditationPage> createState() =>
      _DetailLessonMeditationPageState();
}

class _DetailLessonMeditationPageState
    extends State<DetailLessonMeditationPage> {
  late final YoutubePlayerController _ytCtrl;

  @override
  void initState() {
    super.initState();
    final videoId = _lessonVideoIds[widget.lessonTitle] ??
        _extraVideoIds[widget.lessonTitle] ??
        _defaultVideoId;
    _ytCtrl = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _ytCtrl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
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
                        color: AppColors.neutral700,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bài ${widget.lessonNumber}: ${widget.lessonTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionCard(),
                    const SizedBox(height: 8),
                    _buildMainContentCard(),
                    const SizedBox(height: 8),
                    const Text(
                      'Video/ Hình ảnh minh họa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: _buildVideoPlayer()),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StartMeditationPage(),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.isResume ? 'Tiếp tục Thiền' : 'Bắt đầu Thiền',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFBCEAF0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Bài tập này giúp bạn kết nối tâm trí với cảm giác cơ thể, để đưa sự chú ý về hiện tại.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Các bước chuẩn bị:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '• Tìm nơi yên tĩnh, ngồi thoải mái với lưng thẳng.\n• Đặt tay lên đùi, lòng bàn tay ngửa hoặc úp.\n• Nhắm mắt nhẹ hoặc nhìn xuống sàn.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan500),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nội dung chính:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Chúng ta sẽ bắt đầu quét từ đỉnh đầu xuống ngón chân. Hãy chú ý đến bất kỳ cảm giác nào - căng thẳng, nóng, lạnh, hoặc rung nhẹ - mà không phán xét.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(controller: _ytCtrl),
    );
  }
}
