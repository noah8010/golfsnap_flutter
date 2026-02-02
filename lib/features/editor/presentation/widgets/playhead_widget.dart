import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// 플레이헤드 위젯
///
/// 타임라인의 현재 재생 위치를 표시하는 중앙 고정 플레이헤드
class PlayheadWidget extends StatelessWidget {
  /// 플레이헤드 상단 오프셋 (줌 컨트롤 높이 고려)
  final double topOffset;

  const PlayheadWidget({
    super.key,
    this.topOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // 수직 라인
          Positioned(
            top: topOffset,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: TimelineConfig.playheadWidth,
                color: AppColors.error,
              ),
            ),
          ),

          // 헤드 (원형)
          Positioned(
            top: topOffset - TimelineConfig.playheadHeadSize / 2 + 2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: TimelineConfig.playheadHeadSize,
                height: TimelineConfig.playheadHeadSize,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 타임라인 스크롤 가능 영역 내부에 위치하는 플레이헤드
/// (스크롤과 함께 움직이는 버전)
class ScrollablePlayhead extends StatelessWidget {
  final double currentTime;
  final double zoom;
  final double leftPadding;

  const ScrollablePlayhead({
    super.key,
    required this.currentTime,
    this.zoom = 1.0,
    this.leftPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final position = TimelineConfig.timeToPixels(currentTime, zoom) + leftPadding;

    return Positioned(
      left: position - TimelineConfig.playheadWidth / 2,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Column(
          children: [
            // 헤드 (삼각형)
            CustomPaint(
              size: const Size(12, 8),
              painter: _PlayheadTrianglePainter(),
            ),

            // 수직 라인
            Expanded(
              child: Container(
                width: TimelineConfig.playheadWidth,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayheadTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
