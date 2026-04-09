import 'package:flutter/material.dart';

class AssessmentOption {
  const AssessmentOption({required this.label, this.score});

  final String label;
  final int? score;
}

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.code,
    required this.text,
    required this.options,
  });

  final String code;
  final String text;
  final List<AssessmentOption> options;
}

const List<AssessmentQuestion> ecogQuestions = [
  AssessmentQuestion(
    code: 'ECOG',
    text: 'Hãy chọn mô tả đúng nhất với tình trạng thể lực hiện tại của bạn.',
    options: [
      AssessmentOption(
        label:
            'Hoàn toàn năng động, có thể thực hiện tất cả các hoạt động như trước khi mắc bệnh mà không bị hạn chế',
        score: 0,
      ),
      AssessmentOption(
        label:
            'Bị hạn chế trong hoạt động thể chất nặng nhưng đi lại được và có thể thực hiện công việc có tính chất nhẹ hoặc ít vận động, ví dụ: công việc nhà nhẹ nhàng, công việc văn phòng',
        score: 1,
      ),
      AssessmentOption(
        label:
            'Đi lại được và có khả năng tự chăm sóc nhưng không thể thực hiện bất kỳ hoạt động công việc nào; đi lại được trong hơn 50% thời gian thức tỉnh',
        score: 2,
      ),
      AssessmentOption(
        label:
            'Khả năng chăm sóc bản thân hạn chế; nằm liệt giường hoặc ghế trên 50% thời gian thức tỉnh',
        score: 3,
      ),
      AssessmentOption(
        label:
            'Hoàn toàn không có khả năng hoạt động; không thể tự chăm sóc bản thân; hoàn toàn nằm liệt giường hoặc ghế',
        score: 4,
      ),
    ],
  ),
];

const List<AssessmentOption> mstC3Options = [
  AssessmentOption(label: 'Không giảm cân', score: 0),
  AssessmentOption(label: 'Giảm 1-5 kg', score: 1),
  AssessmentOption(label: 'Giảm 6-10 kg', score: 2),
  AssessmentOption(label: 'Giảm 11-15 kg', score: 3),
  AssessmentOption(label: 'Giảm 15 kg trở lên', score: 4),
  AssessmentOption(label: 'Không biết', score: 5),
];

const List<AssessmentOption> mstC4Options = [
  AssessmentOption(label: 'Không', score: 0),
  AssessmentOption(label: 'Có', score: 1),
];

const List<AssessmentQuestion> psqiQuestions = [
  AssessmentQuestion(
    code: 'E1',
    text: 'Trong tháng qua, bạn thường bắt đầu đi ngủ lúc mấy giờ?',
    options: [
      AssessmentOption(label: 'Trước 22:00', score: 0),
      AssessmentOption(label: '22:00 - 23:00', score: 1),
      AssessmentOption(label: '23:00 - 00:00', score: 2),
      AssessmentOption(label: 'Sau 00:00', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E2',
    text: 'Trong tháng qua, mỗi đêm bạn mất bao lâu để đi vào giấc ngủ?',
    options: [
      AssessmentOption(label: '<=15 phút', score: 0),
      AssessmentOption(label: '16 - 30 phút', score: 1),
      AssessmentOption(label: '31 - 60 phút', score: 2),
      AssessmentOption(label: '>60 phút', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E3',
    text: 'Trong tháng qua, bạn thường ngủ dậy lúc mấy giờ?',
    options: [
      AssessmentOption(label: 'Trước 05:00', score: 3),
      AssessmentOption(label: '05:00 - 06:00', score: 2),
      AssessmentOption(label: '06:00 - 07:00', score: 1),
      AssessmentOption(label: 'Sau 07:00', score: 0),
    ],
  ),
  AssessmentQuestion(
    code: 'E4',
    text:
        'Trong tháng qua, mỗi đêm bạn thường ngủ thực tế được bao nhiêu thời gian?',
    options: [
      AssessmentOption(label: '>=7h', score: 0),
      AssessmentOption(label: '6 - <7h', score: 1),
      AssessmentOption(label: '5 - <6h', score: 2),
      AssessmentOption(label: '<5h', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.1',
    text: 'Không thể ngủ được trong vòng 30 phút',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.2',
    text: 'Tỉnh dậy lúc nửa đêm hoặc quá sớm vào buổi sáng',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.3',
    text: 'Phải thức dậy để tắm',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.4',
    text: 'Khó thở',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.5',
    text: 'Ho hoặc ngáy to',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.6',
    text: 'Cảm thấy rất lạnh',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.7',
    text: 'Cảm thấy rất nóng',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.8',
    text: 'Có ác mộng',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E5.9',
    text: 'Thấy đau',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E6',
    text: 'Trong tháng qua, bạn dùng thuốc ngủ với tần suất nào?',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E7',
    text: 'Bạn khó duy trì tỉnh táo khi lái xe, ăn uống hoặc sinh hoạt xã hội?',
    options: [
      AssessmentOption(label: 'Không có', score: 0),
      AssessmentOption(label: '< 1 lần/tuần', score: 1),
      AssessmentOption(label: '1 - 2 lần/tuần', score: 2),
      AssessmentOption(label: '>= 3 lần/tuần', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E8',
    text: 'Bạn gặp khó khăn để duy trì hứng thú hoàn thành công việc?',
    options: [
      AssessmentOption(label: 'Không khó khăn', score: 0),
      AssessmentOption(label: 'Khó khăn nhẹ', score: 1),
      AssessmentOption(label: 'Khó khăn vừa', score: 2),
      AssessmentOption(label: 'Khó khăn nhiều', score: 3),
    ],
  ),
  AssessmentQuestion(
    code: 'E9',
    text:
        'Nhìn chung bạn đánh giá về chất lượng giấc ngủ trong tháng qua thế nào?',
    options: [
      AssessmentOption(label: 'Rất tốt', score: 0),
      AssessmentOption(label: 'Tương đối tốt', score: 1),
      AssessmentOption(label: 'Tương đối kém', score: 2),
      AssessmentOption(label: 'Rất kém', score: 3),
    ],
  ),
];

const Map<String, List<String>> stressProblemCategories = {
  'A1. Thực tế cuộc sống': [
    'Nhà cửa',
    'Bảo hiểm',
    'Công việc',
    'Xe cộ',
    'Chăm sóc con cái',
  ],
  'A2. Về thể chất': [
    'Đau',
    'Buồn nôn hoặc nôn',
    'Mệt mỏi',
    'Buồn ngủ hoặc Mất ngủ',
    'Đi lại khó khăn',
    'Tắm gội/ Mặc quần áo khó khăn',
    'Khó thở',
    'Đau miệng/Khó nuốt',
    'Không ngon miệng',
    'Khó nói',
    'Táo bón/Tiêu chảy',
    'Tiểu khó',
    'Tê bi tay chân',
    'Giảm tình dục',
    'Khô, ngứa da',
    'Phù tay chân',
  ],
  'A3. Gia đình': ['Vợ/chồng', 'Con cái', 'Khác (ghi rõ)'],
  'A4. Về cảm xúc': [
    'Lo lắng',
    'Chưa quen với bệnh',
    'Cô đơn',
    'Chán nản',
    'Chưa quen với thay đổi ngoại hình',
  ],
  'A5. Về nhận thức': [
    'Hay quên',
    'Nhìn hoặc nghe khác thường',
    'Hay nhầm lẫn',
    'Khó suy nghĩ',
  ],
  'A6. Về tâm linh': [
    'Nghĩ tới Chúa/Phật',
    'Mất niềm tin',
    'Đối mặt với cái chết',
    'Cảm thấy không có mục đích',
  ],
  'A7. Thiếu thông tin': [
    'Về chẩn đoán',
    'Về điều trị hiện tại',
    'Về các điều trị khác',
    'Về duy trì sức khỏe',
  ],
};

String ecogRecommendation(int score) {
  if (score <= 1) {
    return 'Đề xuất tập bài tập dự 3 từ thể';
  }
  if (score <= 3) {
    return 'Đề xuất Bài tập từ thể nằm/ngồi';
  }
  return 'Đề xuất Tập Phục hồi chức năng và lăn trở chống loét tại giường';
}

String mstRecommendation(double bmi, int totalScore) {
  if (bmi >= 18.5 && bmi <= 25.0 && totalScore < 2) {
    return 'Chưa có nguy cơ dinh dưỡng';
  }
  return 'Có nguy cơ dinh dưỡng, cần đánh giá bởi cán bộ chuyên khoa dinh dưỡng';
}

String stressRecommendation(int level) {
  if (level < 4) {
    return 'Theo dõi định kỳ một số vấn đề';
  }
  if (level <= 8) {
    return 'Cần cung cấp tài liệu giáo dục tâm lý';
  }
  return 'Bạn đang có nguy cơ bị Rối loạn lo âu. Cần đặt lịch tư vấn ngay với chuyên gia tâm lý';
}

String psqiRecommendation(int totalScore) {
  if (totalScore <= 5) {
    return 'Chất lượng giấc ngủ tương đối tốt';
  }
  if (totalScore <= 10) {
    return 'Có dấu hiệu rối loạn giấc ngủ mức nhẹ - trung bình';
  }
  return 'Rối loạn giấc ngủ rõ rệt, nên được tư vấn chuyên sâu';
}

Color scoreColor(int score) {
  if (score <= 1) {
    return const Color(0xFF68B378);
  }
  if (score <= 3) {
    return const Color(0xFFFFB366);
  }
  return const Color(0xFFFF6B6B);
}
