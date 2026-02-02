import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// 트랙 레이블 위젯
///
/// 타임라인 좌측의 트랙 이름을 표시
class TrackLabelWidget extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;
  final bool showAddButton;

  const TrackLabelWidget({
    super.key,
    required this.label,
    required this.height,
    this.onTap,
    this.showAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: TimelineConfig.trackLabelWidth,
        decoration: const BoxDecoration(
          color: AppColors.gray100,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: onTap != null ? AppColors.textSecondary : AppColors.gray400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showAddButton && onTap != null)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 트랙 레이블 목록 위젯
class TrackLabelsColumn extends StatelessWidget {
  final VoidCallback? onTextTap;
  final VoidCallback? onAudioTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onStickerTap;

  const TrackLabelsColumn({
    super.key,
    this.onTextTap,
    this.onAudioTap,
    this.onFilterTap,
    this.onStickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TimelineConfig.trackLabelWidth,
      color: AppColors.gray100,
      child: Column(
        children: [
          // 줌 컨트롤 영역 공간
          Container(
            height: TimelineConfig.zoomControlHeight,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
              ),
            ),
          ),

          // Time Ruler 공간
          Container(
            height: TimelineConfig.timeRulerHeight,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
              ),
            ),
          ),

          // 영상 트랙 레이블
          TrackLabelWidget(
            label: TrackType.video.label,
            height: TimelineConfig.videoTrackHeight,
          ),

          // 텍스트 트랙 레이블
          TrackLabelWidget(
            label: TrackType.text.label,
            height: TimelineConfig.textTrackHeight,
            onTap: onTextTap,
            showAddButton: true,
          ),

          // 오디오 트랙 레이블
          TrackLabelWidget(
            label: TrackType.audio.label,
            height: TimelineConfig.audioTrackHeight,
            onTap: onAudioTap,
            showAddButton: true,
          ),

          // 필터 트랙 레이블
          TrackLabelWidget(
            label: TrackType.filter.label,
            height: TimelineConfig.filterTrackHeight,
            onTap: onFilterTap,
            showAddButton: true,
          ),

          // 스티커 트랙 레이블
          TrackLabelWidget(
            label: TrackType.sticker.label,
            height: TimelineConfig.stickerTrackHeight,
            onTap: onStickerTap,
            showAddButton: true,
          ),
        ],
      ),
    );
  }
}
