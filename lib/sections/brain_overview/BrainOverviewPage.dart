import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrainOverviewPage extends StatefulWidget {
  const BrainOverviewPage({super.key});

  @override
  State<BrainOverviewPage> createState() => _BrainOverviewPageState();
}

enum _BrainRange { day, week, month }

class _BrainOverviewPageState extends State<BrainOverviewPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  _BrainRange _selectedRange = _BrainRange.day;
  late Map<String, List<double>> _fromSeries;
  late Map<String, List<double>> _toSeries;

  static const List<String> _seriesOrder = [
    'Alpha',
    'Theta',
    'Beta',
    'Delta',
    'Gamma',
  ];

  static const Map<String, Color> _seriesColors = {
    'Alpha': Color(0xFF149A33),
    'Theta': Color(0xFFF8AC14),
    'Beta': Color(0xFF009CC4),
    'Delta': Color(0xFFFF4E5B),
    'Gamma': Color(0xFFB913C0),
  };

  static const Map<_BrainRange, List<String>> _xLabels = {
    _BrainRange.day: ['07h', '10h', '13h', '16h', '19h', '22h'],
    _BrainRange.week: ['T2', 'T3', 'T4', 'T5', 'T6', 'CN'],
    _BrainRange.month: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
  };

  static const Map<_BrainRange, Map<String, List<double>>> _seriesByRange = {
    _BrainRange.day: {
      'Alpha': [56, 75, 55, 54, 46, 72],
      'Theta': [35, 40, 50, 39, 41, 46],
      'Beta': [17, 56, 34, 42, 12, 40],
      'Delta': [18, 19, 27, 24, 13, 32],
      'Gamma': [50, 22, 28, 80, 39, 11],
    },
    _BrainRange.week: {
      'Alpha': [45, 52, 59, 55, 61, 64],
      'Theta': [32, 37, 40, 38, 43, 45],
      'Beta': [26, 44, 33, 41, 27, 36],
      'Delta': [24, 26, 22, 18, 21, 25],
      'Gamma': [38, 30, 46, 58, 43, 35],
    },
    _BrainRange.month: {
      'Alpha': [40, 48, 58, 54, 60, 68],
      'Theta': [28, 33, 41, 39, 44, 49],
      'Beta': [18, 35, 42, 31, 26, 38],
      'Delta': [20, 23, 26, 21, 19, 24],
      'Gamma': [35, 42, 54, 47, 34, 29],
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..value = 1.0;

    _fromSeries = _cloneSeries(_seriesByRange[_selectedRange]!);
    _toSeries = _cloneSeries(_seriesByRange[_selectedRange]!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, List<double>> _cloneSeries(Map<String, List<double>> input) {
    return {
      for (final MapEntry<String, List<double>> entry in input.entries)
        entry.key: List<double>.from(entry.value),
    };
  }

  void _onRangeSelected(_BrainRange range) {
    if (range == _selectedRange) {
      return;
    }

    setState(() {
      _fromSeries = _cloneSeries(_toSeries);
      _toSeries = _cloneSeries(_seriesByRange[range]!);
      _selectedRange = range;
    });

    _controller.forward(from: 0);
  }

  List<double> _interpolateSeries(String key, double t) {
    final List<double> from = _fromSeries[key]!;
    final List<double> to = _toSeries[key]!;

    return List<double>.generate(from.length, (int i) {
      return lerpDouble(from[i], to[i], t)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String rangeTitle = switch (_selectedRange) {
      _BrainRange.day => 'Ngày',
      _BrainRange.week => 'Tuần',
      _BrainRange.month => 'Tháng',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrainOverviewHeader(
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 18),
              _RangeTabs(
                selectedRange: _selectedRange,
                onSelected: _onRangeSelected,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.brainOverviewCardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Biểu đồ Sóng Não ($rangeTitle)',
                      style: const TextStyle(
                        fontSize: 38 / 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brainOverviewTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, _) {
                        final double t = Curves.easeInOutCubic.transform(
                          _controller.value,
                        );

                        final Map<String, List<double>> data = {
                          for (final String key in _seriesOrder)
                            key: _interpolateSeries(key, t),
                        };

                        return _BrainWaveChart(
                          labels: _xLabels[_selectedRange]!,
                          series: data,
                          seriesOrder: _seriesOrder,
                          seriesColors: _seriesColors,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _seriesOrder
                          .map((String key) {
                            return _LegendItem(
                              color: _seriesColors[key]!,
                              label: key,
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.brainOverviewInsightBackground,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Nhận Định',
                      style: TextStyle(
                        fontSize: 28 / 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brainOverviewPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sóng Alpha và Beta dao động ổn định trong ngày biểu hiện khả năng tập trung và thư giãn cân bằng.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.32,
                        color: AppColors.brainOverviewTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrainOverviewHeader extends StatelessWidget {
  const _BrainOverviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onBack,
              iconSize: 18,
              splashRadius: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: AppColors.neutral700),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tổng quan sóng não',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brainOverviewTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  const _RangeTabs({required this.selectedRange, required this.onSelected});

  final _BrainRange selectedRange;
  final ValueChanged<_BrainRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RangeButton(
            label: 'Ngày',
            selected: selectedRange == _BrainRange.day,
            onTap: () => onSelected(_BrainRange.day),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RangeButton(
            label: 'Tuần',
            selected: selectedRange == _BrainRange.week,
            onTap: () => onSelected(_BrainRange.week),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RangeButton(
            label: 'Tháng',
            selected: selectedRange == _BrainRange.month,
            onTap: () => onSelected(_BrainRange.month),
          ),
        ),
      ],
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Ink(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.brainOverviewPrimary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.brainOverviewPrimary
                : const Color(0xFFB7B7B7),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrainWaveChart extends StatelessWidget {
  const _BrainWaveChart({
    required this.labels,
    required this.series,
    required this.seriesOrder,
    required this.seriesColors,
  });

  final List<String> labels;
  final Map<String, List<double>> series;
  final List<String> seriesOrder;
  final Map<String, Color> seriesColors;

  @override
  Widget build(BuildContext context) {
    final double chartHeight = (MediaQuery.sizeOf(context).height * 0.46).clamp(
      320.0,
      420.0,
    );

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: List<Widget>.generate(11, (int index) {
                final int value = 100 - (index * 10);
                return Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _BurndownChartPainter(
                      series: series,
                      seriesOrder: seriesOrder,
                      seriesColors: seriesColors,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: labels
                      .map(
                        (String label) => Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral700,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BurndownChartPainter extends CustomPainter {
  const _BurndownChartPainter({
    required this.series,
    required this.seriesOrder,
    required this.seriesColors,
  });

  final Map<String, List<double>> series;
  final List<String> seriesOrder;
  final Map<String, Color> seriesColors;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = AppColors.brainOverviewGrid
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const int yDivisions = 10;
    for (int i = 0; i <= yDivisions; i++) {
      final double y = (size.height / yDivisions) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final String key in seriesOrder) {
      final List<double>? values = series[key];
      if (values == null || values.isEmpty) {
        continue;
      }

      final Path path = _buildSmoothPath(values, size);

      final Paint linePaint = Paint()
        ..color = seriesColors[key]!
        ..strokeWidth = 2.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
    }
  }

  Path _buildSmoothPath(List<double> values, Size size) {
    final double stepX = values.length <= 1
        ? 0
        : size.width / (values.length - 1);

    final List<Offset> points = List<Offset>.generate(values.length, (int i) {
      final double x = i * stepX;
      final double y =
          size.height - (values[i].clamp(0, 100) / 100 * size.height);
      return Offset(x, y);
    });

    if (points.length < 2) {
      return Path();
    }

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];
      final double controlX = (current.dx + next.dx) / 2;
      path.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _BurndownChartPainter oldDelegate) {
    return oldDelegate.series != series;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 21 / 2,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
