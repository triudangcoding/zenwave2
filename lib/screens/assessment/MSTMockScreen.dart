import 'package:flutter/material.dart';

import 'assessment_mock_data.dart';
import 'assessment_theme.dart';

class MSTMockScreen extends StatefulWidget {
  const MSTMockScreen({super.key});

  @override
  State<MSTMockScreen> createState() => _MSTMockScreenState();
}

class _MSTMockScreenState extends State<MSTMockScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  int? _c3;
  int? _c4;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double? _bmi() {
    final w = double.tryParse(_weightController.text.trim());
    final h = double.tryParse(_heightController.text.trim());
    if (w == null || h == null || h <= 0) {
      return null;
    }
    final hm = h / 100;
    return w / (hm * hm);
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi();
    return Scaffold(
      backgroundColor: AssessmentTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Thang MST - Đánh giá dinh dưỡng',
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
              color: AssessmentTheme.nutritionSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AssessmentTheme.nutritionAccent),
            ),
            child: const Text(
              'Vui lòng điền thông tin cân nặng, chiều cao và trả lời các câu hỏi về tình trạng dinh dưỡng của bạn.',
              style: TextStyle(
                color: AssessmentTheme.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _inputCard('C1. Bạn có cân nặng bao nhiều?', _weightController, 'Kg'),
          const SizedBox(height: 12),
          _inputCard('C2. Chiều cao của bạn?', _heightController, 'Cm'),
          if (bmi != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AssessmentTheme.cardBorder),
              ),
              child: Text(
                'Chỉ số BMI: ${bmi.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AssessmentTheme.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _optionCard(
            title: 'C3. Tình trạng cân nặng của bạn trong 6 tháng gần đây?',
            options: mstC3Options,
            selected: _c3,
            onChanged: (value) => setState(() => _c3 = value),
          ),
          const SizedBox(height: 12),
          _optionCard(
            title: 'C4. Bạn có ăn uống kém do giảm ngon miệng không?',
            options: mstC4Options,
            selected: _c4,
            onChanged: (value) => setState(() => _c4 = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (bmi == null || _c3 == null || _c4 == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng trả lời đủ 4 câu hỏi MST'),
                  ),
                );
                return;
              }
              final c3Score = _c3 == 5 ? 2 : _c3!;
              final total = c3Score + _c4!;
              final recommendation = mstRecommendation(bmi, total);
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kết quả MST'),
                  content: Text(
                    'BMI: ${bmi.toStringAsFixed(1)}\nĐiểm MST: $total\n\n$recommendation',
                  ),
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
              backgroundColor: AssessmentTheme.nutritionAccent,
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

  Widget _inputCard(
    String title,
    TextEditingController controller,
    String suffix,
  ) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              suffixText: suffix,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required List<AssessmentOption> options,
    required int? selected,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...options.map(
            (option) => RadioListTile<int>(
              value: option.score!,
              groupValue: selected,
              activeColor: AssessmentTheme.nutritionAccent,
              title: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AssessmentTheme.textPrimary,
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
