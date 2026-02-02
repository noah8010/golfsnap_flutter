import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/timeline_clip.dart';
import 'timeline_clip_widget.dart';

/// 타임라인 트랙 위젯
///
/// 단일 트랙(영상/텍스트/오디오/필터/스티커)을 렌더링
class TimelineTrackWidget extends StatelessWidget {
  final TrackType trackType;
  final List<TimelineClip> clips;
  final String? selectedClipId;
  final double zoom;
  final double leftPadding;
  final double width;
  final Function(String clipId)? onClipTap;
  final Function(TimelineClip clip)? onClipDoubleTap;
  final Function(String clipId, double newPosition)? onClipMove;
  final Function(String clipId, double delta)? onTrimStart;
  final Function(String clipId, double delta)? onTrimEnd;
  final VoidCallback? onTrackTap;

  const TimelineTrackWidget({
    super.key,
    required this.trackType,
    required this.clips,
    this.selectedClipId,
    this.zoom = 1.0,
    this.leftPadding = 0,
    this.width = 600,
    this.onClipTap,
    this.onClipDoubleTap,
    this.onClipMove,
    this.onTrimStart,
    this.onTrimEnd,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final trackHeight = TimelineConfig.getTrackHeight(trackType);
    final trackClips = clips.where((c) => c.track == trackType).toList();

    return GestureDetector(
      onTap: onTrackTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: trackHeight,
        width: width,
        decoration: const BoxDecoration(
          color: AppColors.gray50,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 클립들
            ...trackClips.map((clip) => TimelineClipWidget(
              key: ValueKey(clip.id),
              clip: clip,
              isSelected: clip.id == selectedClipId,
              zoom: zoom,
              leftPadding: leftPadding,
              onTap: () => onClipTap?.call(clip.id),
              onDoubleTap: () => onClipDoubleTap?.call(clip),
              onMove: onClipMove,
              onTrimStart: onTrimStart,
              onTrimEnd: onTrimEnd,
            )),
          ],
        ),
      ),
    );
  }
}

/// 모든 트랙을 포함하는 타임라인 트랙 목록 위젯
class TimelineTracksColumn extends StatelessWidget {
  final List<TimelineClip> clips;
  final String? selectedClipId;
  final double zoom;
  final double leftPadding;
  final double width;
  final Function(String clipId)? onClipTap;
  final Function(TimelineClip clip)? onClipDoubleTap;
  final Function(String clipId, double newPosition)? onClipMove;
  final Function(String clipId, double delta)? onTrimStart;
  final Function(String clipId, double delta)? onTrimEnd;
  final VoidCallback? onEmptyTap;

  const TimelineTracksColumn({
    super.key,
    required this.clips,
    this.selectedClipId,
    this.zoom = 1.0,
    this.leftPadding = 0,
    this.width = 600,
    this.onClipTap,
    this.onClipDoubleTap,
    this.onClipMove,
    this.onTrimStart,
    this.onTrimEnd,
    this.onEmptyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: TrackType.values.map((trackType) {
        return TimelineTrackWidget(
          trackType: trackType,
          clips: clips,
          selectedClipId: selectedClipId,
          zoom: zoom,
          leftPadding: leftPadding,
          width: width,
          onClipTap: onClipTap,
          onClipDoubleTap: onClipDoubleTap,
          onClipMove: onClipMove,
          onTrimStart: onTrimStart,
          onTrimEnd: onTrimEnd,
          onTrackTap: onEmptyTap,
        );
      }).toList(),
    );
  }
}
