import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';

/// 트림 핸들 방향
enum TrimHandleSide { left, right }

/// 트림 핸들 위젯
///
/// 클립의 시작/끝을 조절하는 드래그 핸들
class TrimHandleWidget extends StatefulWidget {
  final TrimHandleSide side;
  final Function(double delta) onTrim;
  final double zoom;

  const TrimHandleWidget({
    super.key,
    required this.side,
    required this.onTrim,
    this.zoom = 1.0,
  });

  @override
  State<TrimHandleWidget> createState() => _TrimHandleWidgetState();
}

class _TrimHandleWidgetState extends State<TrimHandleWidget> {
  bool _isDragging = false;
  double _startX = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.side == TrimHandleSide.left ? 0 : null,
      right: widget.side == TrimHandleSide.right ? 0 : null,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: Container(
            width: TimelineConfig.trimHandleWidth + TimelineConfig.trimHandleTouchPadding * 2,
            padding: EdgeInsets.only(
              left: widget.side == TrimHandleSide.left ? TimelineConfig.trimHandleTouchPadding : 0,
              right: widget.side == TrimHandleSide.right ? TimelineConfig.trimHandleTouchPadding : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: TimelineConfig.trimHandleWidth,
              decoration: BoxDecoration(
                color: _isDragging
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.horizontal(
                  left: widget.side == TrimHandleSide.left
                      ? const Radius.circular(4)
                      : Radius.zero,
                  right: widget.side == TrimHandleSide.right
                      ? const Radius.circular(4)
                      : Radius.zero,
                ),
                boxShadow: _isDragging
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _isDragging
                        ? Colors.grey[800]
                        : Colors.grey[600],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _isDragging = true;
      _startX = details.globalPosition.dx;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final deltaX = details.globalPosition.dx - _startX;
    final deltaTime = TimelineConfig.pixelsToTime(deltaX, widget.zoom);

    // 왼쪽 핸들: 양수 delta = 시작점 늘림 (클립 짧아짐)
    // 오른쪽 핸들: 양수 delta = 끝점 늘림 (클립 길어짐)
    widget.onTrim(deltaTime);

    _startX = details.globalPosition.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }
}
