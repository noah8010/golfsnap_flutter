import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// 타임 룰러 위젯
///
/// 타임라인 상단의 시간 눈금을 표시
class TimeRulerWidget extends StatelessWidget {
  final double totalDuration;
  final double zoom;
  final double leftPadding;

  const TimeRulerWidget({
    super.key,
    required this.totalDuration,
    this.zoom = 1.0,
    this.leftPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 5초 간격으로 눈금 생성
    final tickCount = (totalDuration / 5).ceil() + 1;
    final tickWidth = TimelineConfig.timeToPixels(5, zoom);

    return Container(
      height: TimelineConfig.timeRulerHeight,
      color: AppColors.gray100,
      child: Row(
        children: [
          // 좌측 여백
          SizedBox(width: leftPadding),

          // 눈금들
          ...List.generate(tickCount, (i) {
            return SizedBox(
              width: tickWidth,
              child: Stack(
                children: [
                  // 눈금 선
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: AppColors.gray300,
                    ),
                  ),

                  // 시간 텍스트
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Text(
                      '${i * 5}s',
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  // 중간 눈금 (2.5초 지점)
                  Positioned(
                    left: tickWidth / 2,
                    top: TimelineConfig.timeRulerHeight / 2,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: AppColors.gray300,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 타임 룰러 CustomPainter (성능 최적화용)
class TimeRulerPainter extends CustomPainter {
  final double totalDuration;
  final double zoom;
  final double leftPadding;

  TimeRulerPainter({
    required this.totalDuration,
    required this.zoom,
    this.leftPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray400
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final tickInterval = 5.0; // 5초 간격
    final tickWidth = TimelineConfig.timeToPixels(tickInterval, zoom);
    final tickCount = (totalDuration / tickInterval).ceil() + 1;

    for (int i = 0; i < tickCount; i++) {
      final x = leftPadding + i * tickWidth;

      // 주 눈금
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );

      // 시간 텍스트
      textPainter.text = TextSpan(
        text: '${(i * tickInterval).toInt()}s',
        style: const TextStyle(
          color: AppColors.gray500,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 4, 4));

      // 중간 눈금
      final midX = x + tickWidth / 2;
      if (midX < size.width) {
        canvas.drawLine(
          Offset(midX, size.height / 2),
          Offset(midX, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimeRulerPainter oldDelegate) {
    return totalDuration != oldDelegate.totalDuration ||
        zoom != oldDelegate.zoom ||
        leftPadding != oldDelegate.leftPadding;
  }
}
