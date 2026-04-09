import 'package:flutter/material.dart';

import '../../models/breathing_exercise.dart';
import 'BreathingExerciseScreen.dart';

class BreathingDetailScreen extends StatelessWidget {
  final BreathingExercise exercise;

  const BreathingDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin bài tập thở',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF186289),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      color: exercise.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      exercise.imageAsset,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: exercise.primaryColor,
                          child: Center(
                            child: Text(
                              exercise.name.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186289),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeInfo('Thời gian hít vào', exercise.inhaleTime),
                      _buildTimeInfo('Thời gian giữ hơi', exercise.holdTime),
                      _buildTimeInfo('Thời gian thở ra', exercise.exhaleTime),
                      if (exercise.waitTime > 0)
                        _buildTimeInfo('Thời gian chờ', exercise.waitTime),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    exercise.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cách thực hiện:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186289),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    'Hít vào trong ${exercise.inhaleTime} giây.',
                  ),
                  _buildInstructionStep(
                    'Giữ hơi trong ${exercise.holdTime} giây.',
                  ),
                  _buildInstructionStep(
                    'Thở ra trong ${exercise.exhaleTime} giây.',
                  ),
                  if (exercise.waitTime > 0)
                    _buildInstructionStep(
                      'Chờ ${exercise.waitTime} giây trước khi lặp lại.',
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lợi ích:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186289),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...exercise.benefits.map(_buildBenefitItem),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BreathingExerciseScreen(exercise: exercise),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24B0B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Luyện Tập Ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, int seconds) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$seconds',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: exercise.primaryColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: exercise.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_forward,
                size: 14,
                color: exercise.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: exercise.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.check, size: 14, color: exercise.primaryColor),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
