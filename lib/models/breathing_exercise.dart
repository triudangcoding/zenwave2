import 'package:flutter/material.dart';

class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final int inhaleTime;
  final int holdTime;
  final int exhaleTime;
  final int waitTime;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> benefits;

  BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.inhaleTime,
    required this.holdTime,
    required this.exhaleTime,
    this.waitTime = 0,
    required this.primaryColor,
    required this.secondaryColor,
    required this.benefits,
  });

  String get displayPattern =>
      '$inhaleTime - $holdTime - $exhaleTime - $waitTime';

  String get shortPattern =>
      '$inhaleTime - $holdTime - $exhaleTime${waitTime > 0 ? ' - $waitTime' : ''}';
}

List<BreathingExercise> sampleBreathingExercises = [
  BreathingExercise(
    id: 'breathing_555',
    name: 'Thở 5-5-5',
    description:
        'Đây là kỹ thuật thở đều, trong đó bạn hít vào, giữ hơi thở, và thở ra theo thời gian bằng nhau.',
    imageAsset: 'assets/Images/breathing.png',
    inhaleTime: 5,
    holdTime: 5,
    exhaleTime: 5,
    waitTime: 0,
    primaryColor: const Color(0xFF36CFC9),
    secondaryColor: const Color(0xFF5CDBD3),
    benefits: [
      'Giúp giảm lo lắng, căng thẳng',
      'Điều chỉnh nhịp tim và hô hấp, làm dịu hệ thần kinh',
      'Đơn giản và dễ thực hiện trong nhiều tình huống',
    ],
  ),
  BreathingExercise(
    id: 'breathing_box',
    name: 'Thở hộp',
    description:
        'Còn được gọi là Box Breathing, bài thở này được đặt tên theo cách mỗi giai đoạn của hơi thở có thời gian bằng nhau, giống như các cạnh của một cái hộp.',
    imageAsset: 'assets/Images/breathing.png',
    inhaleTime: 4,
    holdTime: 4,
    exhaleTime: 4,
    waitTime: 4,
    primaryColor: const Color(0xFF87E8DE),
    secondaryColor: const Color(0xFFB5F5EC),
    benefits: [
      'Tăng cường sự tập trung và giảm căng thẳng nhanh chóng',
      'Kích hoạt hệ thống thần kinh đối giao cảm, giúp cơ thể thư giãn',
      'Thường được sử dụng bởi các vận động viên, quân đội và những người cần đối phó với áp lực cao',
    ],
  ),
  BreathingExercise(
    id: 'breathing_478',
    name: 'Thở 4-7-8',
    description:
        'Đây là một kỹ thuật thở giúp thư giãn hệ thần kinh, được phát triển bởi Tiến sĩ Andrew Weil, nổi tiếng trong lĩnh vực y học tích hợp.',
    imageAsset: 'assets/Images/breathing.png',
    inhaleTime: 4,
    holdTime: 7,
    exhaleTime: 8,
    waitTime: 0,
    primaryColor: const Color(0xFF69C0FF),
    secondaryColor: const Color(0xFF91D5FF),
    benefits: [
      'Giúp dễ dàng chìm vào giấc ngủ, hỗ trợ điều trị mất ngủ',
      'Tăng khả năng tập trung, bình tĩnh trong các tình huống căng thẳng',
      'Cải thiện khả năng quản lý lo âu, căng thẳng',
    ],
  ),
  BreathingExercise(
    id: 'breathing_relaxation',
    name: 'Thư giãn',
    description:
        'Đây là kỹ thuật thở đều, trong đó bạn hít vào, giữ hơi thở và thở ra theo thời gian bằng nhau.',
    imageAsset: 'assets/Images/breathing.png',
    inhaleTime: 4,
    holdTime: 5,
    exhaleTime: 6,
    waitTime: 0,
    primaryColor: const Color(0xFFFFDC5C),
    secondaryColor: const Color(0xFFFFE58F),
    benefits: [
      'Giúp giảm lo lắng, căng thẳng',
      'Điều chỉnh nhịp tim và hô hấp, làm dịu hệ thần kinh',
      'Đơn giản và dễ thực hiện trong nhiều tình huống',
    ],
  ),
  BreathingExercise(
    id: 'breathing_focus',
    name: 'Tập trung',
    description:
        'Đây là kỹ thuật thở đều, trong đó bạn hít vào, giữ hơi thở và thở ra theo thời gian bằng nhau.',
    imageAsset: 'assets/Images/breathing.png',
    inhaleTime: 3,
    holdTime: 5,
    exhaleTime: 3,
    waitTime: 0,
    primaryColor: const Color(0xFFFFB3C6),
    secondaryColor: const Color(0xFFFFC2D1),
    benefits: [
      'Tăng cường khả năng tập trung',
      'Cải thiện hiệu suất làm việc',
      'Giảm mệt mỏi tinh thần',
    ],
  ),
];
