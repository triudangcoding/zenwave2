import 'package:flutter/material.dart';

import '../../models/breathing_exercise.dart';
import 'BreathingDetailScreen.dart';

class BreathingListScreen extends StatelessWidget {
  const BreathingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF186289)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Danh sách bài tập thở',
          style: TextStyle(
            color: Color(0xFF186289),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Chọn bài tập thở phù hợp với cảm xúc của bạn',
              style: TextStyle(
                color: Color(0xFF186289),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sampleBreathingExercises.length,
              itemBuilder: (context, index) {
                final exercise = sampleBreathingExercises[index];
                return _buildExerciseCard(context, exercise);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, BreathingExercise exercise) {
    return GestureDetector(
      onTap: () {
        _showExerciseDetail(context, exercise);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: exercise.primaryColor.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                exercise.imageAsset,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: exercise.primaryColor.withValues(alpha: 0.5),
                    child: Center(
                      child: Text(
                        exercise.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF186289),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.shortPattern,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF186289),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, BreathingExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      builder: (context) => BreathingDetailScreen(exercise: exercise),
    );
  }
}
