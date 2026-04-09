import 'package:flutter/material.dart';

import 'assessment_mock_data.dart';
import 'assessment_theme.dart';

class PSQIMockScreen extends StatefulWidget {
  const PSQIMockScreen({super.key});

  @override
  State<PSQIMockScreen> createState() => _PSQIMockScreenState();
}

class _PSQIMockScreenState extends State<PSQIMockScreen> {
  final Map<String, int> _answers = <String, int>{};

  int get _totalScore =>
      _answers.values.fold<int>(0, (sum, value) => sum + value);

  @override
  Widget build(BuildContext context) {
    final answered = _answers.length;
    final total = psqiQuestions.length;

    return Scaffold(
      backgroundColor: AssessmentTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Thang đánh giá chất lượng giấc ngủ (PSQI)',
          style: TextStyle(
            color: AssessmentTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AssessmentTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã trả lời $answered/$total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AssessmentTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: answered / total,
                  backgroundColor: AssessmentTheme.sleepSoft,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AssessmentTheme.sleepAccent,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...psqiQuestions.map((question) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AssessmentTheme.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AssessmentTheme.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AssessmentTheme.sleepSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          question.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AssessmentTheme.sleepAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...question.options.map((option) {
                    return RadioListTile<int>(
                      value: option.score ?? 0,
                      groupValue: _answers[question.code],
                      activeColor: AssessmentTheme.sleepAccent,
                      dense: true,
                      title: Text(
                        option.label,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AssessmentTheme.textPrimary,
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _answers[question.code] = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          }),
          FilledButton(
            onPressed: _answers.length == psqiQuestions.length
                ? () {
                    final recommendation = psqiRecommendation(_totalScore);
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Kết quả PSQI'),
                        content: Text(
                          'Tổng điểm: $_totalScore\n\n$recommendation',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AssessmentTheme.sleepAccent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _answers.length == psqiQuestions.length
                  ? 'Nộp bài'
                  : 'Đã trả lời ${_answers.length}/${psqiQuestions.length}',
            ),
          ),
        ],
      ),
    );
  }
}
