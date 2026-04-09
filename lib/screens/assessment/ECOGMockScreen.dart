import 'package:flutter/material.dart';

import 'assessment_mock_data.dart';
import 'assessment_theme.dart';

class ECOGMockScreen extends StatefulWidget {
  const ECOGMockScreen({super.key});

  @override
  State<ECOGMockScreen> createState() => _ECOGMockScreenState();
}

class _ECOGMockScreenState extends State<ECOGMockScreen> {
  int? _selectedScore;

  @override
  Widget build(BuildContext context) {
    final question = ecogQuestions.first;
    return Scaffold(
      backgroundColor: AssessmentTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Thang ECOG - Đánh giá thể lực',
          style: TextStyle(
            color: AssessmentTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AssessmentTheme.textPrimary,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AssessmentTheme.ecogSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AssessmentTheme.ecogAccent),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.accessibility_new,
                  color: AssessmentTheme.ecogAccent,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đánh giá tình trạng thể lực (Thang ECOG). Chọn 1 mô tả phù hợp nhất với hiện tại.',
                    style: TextStyle(
                      color: AssessmentTheme.textPrimary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Câu hỏi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AssessmentTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AssessmentTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...question.options.map((option) {
            final selected = _selectedScore == option.score;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AssessmentTheme.ecogAccent
                      : AssessmentTheme.cardBorder,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AssessmentTheme.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: RadioListTile<int>(
                value: option.score!,
                groupValue: _selectedScore,
                activeColor: AssessmentTheme.ecogAccent,
                onChanged: (value) {
                  setState(() {
                    _selectedScore = value;
                  });
                },
                title: Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: AssessmentTheme.textPrimary,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selectedScore == null
                ? null
                : () {
                    final score = _selectedScore!;
                    final recommendation = ecogRecommendation(score);
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Kết quả ECOG'),
                        content: Text('Điểm: $score\n\n$recommendation'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AssessmentTheme.ecogAccent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}
