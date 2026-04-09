import 'package:flutter/material.dart';

import 'assessment_mock_data.dart';
import 'assessment_theme.dart';

class StressThermometerMockScreen extends StatefulWidget {
  const StressThermometerMockScreen({super.key});

  @override
  State<StressThermometerMockScreen> createState() =>
      _StressThermometerMockScreenState();
}

class _StressThermometerMockScreenState
    extends State<StressThermometerMockScreen> {
  int _stressLevel = 0;
  final Set<String> _selectedProblems = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Thang Nhiệt kế căng thẳng',
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
              color: AssessmentTheme.stressSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AssessmentTheme.stressAccent),
            ),
            child: const Text(
              'Hãy đánh dấu vào mức độ căng thẳng của bạn trong tuần vừa qua và chọn các vấn đề đang gây căng thẳng.',
              style: TextStyle(
                color: AssessmentTheme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '1. Hãy đánh dấu vào mức độ căng thẳng của bạn trong tuần vừa qua (từ 0-10)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AssessmentTheme.cardBorder),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AssessmentTheme.stressAccent,
                inactiveTrackColor: AssessmentTheme.stressSoft,
                thumbColor: AssessmentTheme.stressAccent,
                overlayColor: AssessmentTheme.stressSoft.withValues(alpha: 0.4),
              ),
              child: Slider(
                value: _stressLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: '$_stressLevel',
                onChanged: (value) {
                  setState(() {
                    _stressLevel = value.round();
                  });
                },
              ),
            ),
          ),
          Text(
            'Mức độ căng thẳng đã chọn: $_stressLevel/10',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            '2. Hãy chọn các vấn đề đang gây căng thẳng:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...stressProblemCategories.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AssessmentTheme.cardBorder),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: entry.value.map((problem) {
                  final checked = _selectedProblems.contains(problem);
                  return CheckboxListTile(
                    value: checked,
                    dense: true,
                    activeColor: AssessmentTheme.stressAccent,
                    title: Text(
                      problem,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AssessmentTheme.textPrimary,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedProblems.add(problem);
                        } else {
                          _selectedProblems.remove(problem);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selectedProblems.isEmpty
                ? null
                : () {
                    final recommendation = stressRecommendation(_stressLevel);
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Kết quả Stress Thermometer'),
                        content: Text(
                          'Mức căng thẳng: $_stressLevel/10\nSố vấn đề đã chọn: ${_selectedProblems.length}\n\n$recommendation',
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
              backgroundColor: AssessmentTheme.stressAccent,
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
