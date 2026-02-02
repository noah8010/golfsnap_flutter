import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/timeline_clip.dart';
import 'trim_handle_widget.dart';

/// 타임라인 클립 위젯
///
/// 모든 트랙 타입(영상/텍스트/오디오/필터/스티커)을 렌더링하는 공통 컴포넌트
class TimelineClipWidget extends StatefulWidget {
  final TimelineClip clip;
  final bool isSelected;
  final double zoom;
  final double leftPadding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Function(String clipId, double newPosition)? onMove;
  final Function(String clipId, double delta)? onTrimStart;
  final Function(String clipId, double delta)? onTrimEnd;

  const TimelineClipWidget({
    super.key,
    required this.clip,
    this.isSelected = false,
    this.zoom = 1.0,
    this.leftPadding = 0,
    this.onTap,
    this.onDoubleTap,
    this.onMove,
    this.onTrimStart,
    this.onTrimEnd,
  });

  @override
  State<TimelineClipWidget> createState() => _TimelineClipWidgetState();
}

class _TimelineClipWidgetState extends State<TimelineClipWidget> {
  bool _isDragging = false;
  bool _isLongPressActivated = false;
  double _dragStartX = 0;
  double _dragStartPosition = 0;

  @override
  Widget build(BuildContext context) {
    final clipWidth = TimelineConfig.timeToPixels(widget.clip.duration, widget.zoom);
    final clipLeft = TimelineConfig.timeToPixels(widget.clip.position, widget.zoom) + widget.leftPadding;
    final displayWidth = clipWidth.clamp(TimelineConfig.minClipWidth, double.infinity);

    return Positioned(
      left: clipLeft,
      top: 4,
      bottom: 4,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPressStart: _onLongPressStart,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
        onLongPressEnd: _onLongPressEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: displayWidth,
          transform: Matrix4.identity()..scale(_isDragging ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.clip.trackColor,
            borderRadius: BorderRadius.circular(4),
            border: widget.isSelected
                ? Border.all(
                    color: Colors.white,
                    width: 2,
                  )
                : null,
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // 클립 내용
              _buildClipContent(displayWidth),

              // 트림 핸들 (선택된 경우에만)
              if (widget.isSelected) ...[
                TrimHandleWidget(
                  side: TrimHandleSide.left,
                  onTrim: (delta) => widget.onTrimStart?.call(widget.clip.id, delta),
                  zoom: widget.zoom,
                ),
                TrimHandleWidget(
                  side: TrimHandleSide.right,
                  onTrim: (delta) => widget.onTrimEnd?.call(widget.clip.id, delta),
                  zoom: widget.zoom,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClipContent(double width) {
    switch (widget.clip.track) {
      case TrackType.video:
        return _buildVideoClipContent();
      default:
        return _buildDefaultClipContent();
    }
  }

  Widget _buildVideoClipContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            widget.clip.trackColor,
            widget.clip.trackColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.clip.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.clip.speed != 1.0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '${widget.clip.speed}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultClipContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          widget.clip.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLongPressActivated = true;
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartPosition = widget.clip.position;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isLongPressActivated) return;

    final deltaX = details.globalPosition.dx - _dragStartX;
    final deltaTime = TimelineConfig.pixelsToTime(deltaX, widget.zoom);
    final newPosition = (_dragStartPosition + deltaTime).clamp(0.0, double.infinity);

    widget.onMove?.call(widget.clip.id, newPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isLongPressActivated = false;
      _isDragging = false;
    });
  }
}
