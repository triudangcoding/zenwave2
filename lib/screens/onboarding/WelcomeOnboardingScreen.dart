import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/app_state_service.dart';

// ── Quick psych questions data ──────────────────────────────────────────────

class _PsychQuestion {
  const _PsychQuestion({required this.question, required this.options});
  final String question;
  final List<String> options;
}

const List<_PsychQuestion> _kQuestions = [
  _PsychQuestion(
    question: 'Trong những ngày gần đây, bạn thường cảm thấy thế nào?',
    options: [
      'Rất căng thẳng, khó tập trung',
      'Khá căng thẳng, thỉnh thoảng lo lắng',
      'Bình thường, không quá căng thẳng',
      'Khá thoải mái, năng lượng tốt',
      'Rất thoải mái và bình tĩnh',
    ],
  ),
  _PsychQuestion(
    question: 'Giấc ngủ của bạn trong tháng qua như thế nào?',
    options: [
      'Rất kém, thường mất ngủ',
      'Kém, khó vào giấc hoặc hay thức giữa đêm',
      'Trung bình, đủ giờ nhưng chưa sâu giấc',
      'Khá tốt, ngủ đủ giấc hầu hết ngày',
      'Rất tốt, ngủ ngon và tỉnh táo khi dậy',
    ],
  ),
  _PsychQuestion(
    question: 'Bạn thường làm gì để giải toả khi cảm thấy căng thẳng?',
    options: [
      'Tôi thường không biết làm gì',
      'Nghe nhạc hoặc xem phim',
      'Tập thể dục hoặc đi bộ',
      'Thiền định hoặc hít thở sâu',
      'Tâm sự với người thân / bạn bè',
    ],
  ),
  _PsychQuestion(
    question: 'Bạn có thường xuyên cảm thấy mệt mỏi dù đã ngủ đủ giấc không?',
    options: [
      'Gần như mỗi ngày',
      'Khá thường xuyên',
      'Thỉnh thoảng',
      'Hiếm khi',
      'Hầu như không bao giờ',
    ],
  ),
  _PsychQuestion(
    question: 'Mức độ tập trung trong công việc / học tập của bạn gần đây?',
    options: [
      'Rất khó tập trung, dễ bị phân tâm',
      'Khó tập trung hơn bình thường',
      'Bình thường',
      'Tập trung tốt',
      'Tập trung rất tốt, năng suất cao',
    ],
  ),
  _PsychQuestion(
    question:
        'Bạn có thường xuyên lo lắng về tương lai hoặc những điều chưa xảy ra không?',
    options: [
      'Gần như lúc nào cũng lo',
      'Lo lắng khá nhiều',
      'Đôi khi lo lắng',
      'Hiếm khi lo lắng',
      'Tôi khá bình tĩnh trước những điều chưa chắc',
    ],
  ),
  _PsychQuestion(
    question:
        'Bạn thường dành bao nhiêu thời gian cho bản thân mỗi ngày (không làm việc)?',
    options: [
      'Gần như không có thời gian riêng',
      'Dưới 30 phút',
      '30 phút – 1 giờ',
      '1 – 2 giờ',
      'Hơn 2 giờ',
    ],
  ),
  _PsychQuestion(
    question: 'Bạn có thường cảm thấy cơ thể căng cứng (cổ, vai, lưng) không?',
    options: [
      'Gần như mỗi ngày',
      'Vài lần mỗi tuần',
      'Thỉnh thoảng',
      'Hiếm khi',
      'Rất hiếm',
    ],
  ),
  _PsychQuestion(
    question: 'Bạn đánh giá khả năng kiểm soát cảm xúc của mình như thế nào?',
    options: [
      'Tôi thường mất kiểm soát khi căng thẳng',
      'Cảm xúc hay bị lấn át',
      'Tạm ổn, nhưng đôi khi khó kiểm soát',
      'Khá tốt, ít khi mất kiểm soát',
      'Tốt, tôi có thể tự điều tiết tốt',
    ],
  ),
  _PsychQuestion(
    question:
        'Bạn có từng thử thiền định, hít thở có chủ đích hoặc các kỹ thuật thư giãn chưa?',
    options: [
      'Chưa bao giờ thử',
      'Đã thử nhưng không biết làm đúng cách',
      'Thỉnh thoảng thử, kết quả chưa rõ',
      'Có, thực hành định kỳ',
      'Có, đây là thói quen hàng ngày của tôi',
    ],
  ),
];

// ── Onboarding Screen ───────────────────────────────────────────────────────

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  final List<int?> _answers = List<int?>.filled(_kQuestions.length, null);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // total pages: 1 intro + N questions + 1 completion
  static int get _totalPages => 1 + _kQuestions.length + 1;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finish() {
    final List<int> answered = _answers.map((int? a) => a ?? 0).toList();
    // Predict scores from answers before completing so HomePage shows them immediately
    AppStateService.predictScoresFromAnswers(answered);
    AppStateService.completeOnboarding(answered);
    AppStateService.saveOnboarding(answered);
  }

  bool get _canProceed {
    if (_currentPage == 0) return true; // intro page
    final int questionIndex = _currentPage - 1;
    if (questionIndex >= 0 && questionIndex < _kQuestions.length) {
      return _answers[questionIndex] != null;
    }
    return true; // completion page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress bar
            if (_currentPage > 0 && _currentPage < _totalPages - 1)
              _buildProgressBar(),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildIntroPage(),
                  ...List<Widget>.generate(
                    _kQuestions.length,
                    (i) => _buildQuestionPage(i),
                  ),
                  _buildCompletionPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    final int questionIndex = _currentPage - 1; // 0-based
    final double progress = (_currentPage) / (_totalPages - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.neutral700,
                ),
              ),
              Text(
                questionIndex < _kQuestions.length
                    ? 'Câu ${questionIndex + 1} / ${_kQuestions.length}'
                    : '',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 26),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.neutral100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.cyan500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Intro page ────────────────────────────────────────────────────────────

  Widget _buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          // Illustration placeholder
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.teal100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_alt,
                size: 60,
                color: AppColors.cyan600,
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Chào mừng đến\nvới ZenWave',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trước khi bắt đầu, hãy trả lời 10 câu hỏi ngắn để ZenWave dự đoán mức độ căng thẳng và đưa ra gợi ý phù hợp nhất cho bạn.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.6,
              color: AppColors.neutral700,
            ),
          ),
          const Spacer(flex: 2),
          _buildPrimaryButton(label: 'Bắt đầu', onPressed: _nextPage),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Question page ─────────────────────────────────────────────────────────

  Widget _buildQuestionPage(int questionIndex) {
    final _PsychQuestion q = _kQuestions[questionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn một câu trả lời phù hợp nhất với bạn',
            style: TextStyle(fontSize: 13.5, color: AppColors.neutral600),
          ),
          const SizedBox(height: 24),
          ...List<Widget>.generate(q.options.length, (int i) {
            final bool selected = _answers[questionIndex] == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                label: q.options[i],
                selected: selected,
                onTap: () {
                  setState(() {
                    _answers[questionIndex] = i;
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 28),
          _buildPrimaryButton(
            label: questionIndex < _kQuestions.length - 1
                ? 'Tiếp theo'
                : 'Hoàn tất',
            onPressed: _canProceed ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  // ── Completion page ───────────────────────────────────────────────────────

  int _previewStress() {
    final List<int> answered = _answers.map((a) => a ?? 0).toList();
    final double avg = answered.fold<int>(0, (a, b) => a + b) / answered.length;
    return (10 - (avg / 4.0 * 9)).round().clamp(1, 10);
  }

  Widget _buildCompletionPage() {
    final int previewStress = _previewStress();
    final Color stressColor = previewStress <= 3
        ? const Color(0xFF22C55E)
        : previewStress <= 6
        ? const Color(0xFFCA8A04)
        : const Color(0xFFEF4444);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.teal100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: AppColors.cyan500,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Đánh giá ban đầu của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dựa trên 10 câu trả lời, ZenWave dự đoán mức độ căng thẳng hiện tại của bạn là:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 24),
          // Predicted score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: stressColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: stressColor.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                Text(
                  '$previewStress',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: stressColor,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '/ 10',
                  style: TextStyle(
                    fontSize: 18,
                    color: stressColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Gradient bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF22C55E),
                              Color(0xFFFACC15),
                              Color(0xFFEF4444),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        left:
                            ((previewStress - 1) / 9) *
                            (MediaQuery.of(context).size.width - 96),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: stressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    previewStress <= 3
                        ? 'Khá bình tĩnh — tiếp tục duy trì!'
                        : previewStress <= 6
                        ? 'Căng thẳng nhẹ — cần chú ý thêm'
                        : 'Căng thẳng cao — nên thư giãn ngay',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: stressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kết quả được dự đoán dựa trên 10 câu hỏi bạn vừa làm. '
                    'Kết nối headband để đo chính xác hơn.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildPrimaryButton(label: 'Xem gợi ý của tôi', onPressed: _finish),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Shared button ─────────────────────────────────────────────────────────

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: onPressed == null
              ? AppColors.neutral200
              : AppColors.cyan500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onPressed == null ? AppColors.neutral500 : AppColors.white,
          ),
        ),
      ),
    );
  }
}

// ── Option tile widget ────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan100 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.cyan500 : AppColors.neutral200,
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? AppColors.cyan500 : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.cyan500 : AppColors.neutral400,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.cyan800 : AppColors.neutral800,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
