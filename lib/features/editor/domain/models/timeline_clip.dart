import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// 스티커 애니메이션 타입
enum StickerAnimationType {
  bounce('바운스'),
  pulse('펄스'),
  shake('흔들기'),
  spin('회전'),
  explode('폭발'),
  float('떠다니기'),
  zoomIn('줌인'),
  sparkle('반짝임');

  final String label;
  const StickerAnimationType(this.label);
}

/// 텍스트 애니메이션 타입
enum TextAnimationType {
  none('없음'),
  fadeIn('페이드 인'),
  fadeOut('페이드 아웃'),
  slideUp('슬라이드 업'),
  slideDown('슬라이드 다운'),
  typewriter('타자기'),
  bounce('바운스');

  final String label;
  const TextAnimationType(this.label);
}

/// 필터 프리셋 타입
enum FilterPresetType {
  none('없음'),
  vivid('선명'),
  warm('따뜻함'),
  cool('차가움'),
  vintage('빈티지'),
  bw('흑백'),
  cinema('시네마');

  final String label;
  const FilterPresetType(this.label);
}

/// BGM 아이템
class BgmItem {
  final String id;
  final String name;
  final double volume;

  const BgmItem({
    required this.id,
    required this.name,
    this.volume = 100,
  });

  BgmItem copyWith({
    String? id,
    String? name,
    double? volume,
  }) {
    return BgmItem(
      id: id ?? this.id,
      name: name ?? this.name,
      volume: volume ?? this.volume,
    );
  }
}

/// 타임라인 클립 모델
///
/// React의 TimelineItem을 Flutter로 변환한 모델
/// 5개 트랙 타입(영상/텍스트/오디오/필터/스티커)을 지원
class TimelineClip {
  final String id;
  final String clipId; // 원본 미디어 ID 참조
  final TrackType track;
  final double position; // 타임라인상 시작 위치 (초)
  final double duration; // 타임라인상 길이 (초)

  // 원본 소스 구간 (트림/분할용)
  final double? startTime; // 원본 영상에서의 시작 지점
  final double? endTime; // 원본 영상에서의 끝 지점

  final String? thumbnail;
  final String? sourceUri;

  // ============================================
  // Video specific
  // ============================================
  final double speed; // 재생 속도 (0.1 ~ 8.0)
  final double volume; // 볼륨 (0 ~ 100)

  // ============================================
  // Text specific
  // ============================================
  final String? textContent;
  final String? textFont;
  final double? textFontSize;
  final Color? textColor;
  final TextAlign? textAlign;
  final bool textBold;
  final bool textItalic;
  final bool textUnderline;
  final TextAnimationType? textAnimation;
  final Offset? textPosition; // 0-100 퍼센트 좌표

  // ============================================
  // Audio specific
  // ============================================
  final double audioVolume;
  final bool audioMuted;
  final BgmItem? audioBgm;

  // ============================================
  // Filter specific
  // ============================================
  final double filterBrightness; // -100 ~ 100
  final double filterContrast; // -100 ~ 100
  final double filterSaturation; // -100 ~ 100
  final double filterTemperature; // -100 ~ 100
  final FilterPresetType? filterPreset;

  // ============================================
  // Sticker specific
  // ============================================
  final String? stickerId;
  final String? stickerName;
  final String? stickerEmoji;
  final StickerAnimationType? stickerAnimation;
  final double stickerScale;
  final Offset? stickerPosition; // 0-100 퍼센트 좌표

  const TimelineClip({
    required this.id,
    required this.clipId,
    required this.track,
    required this.position,
    required this.duration,
    this.startTime,
    this.endTime,
    this.thumbnail,
    this.sourceUri,
    // Video
    this.speed = 1.0,
    this.volume = 100,
    // Text
    this.textContent,
    this.textFont,
    this.textFontSize,
    this.textColor,
    this.textAlign,
    this.textBold = false,
    this.textItalic = false,
    this.textUnderline = false,
    this.textAnimation,
    this.textPosition,
    // Audio
    this.audioVolume = 100,
    this.audioMuted = false,
    this.audioBgm,
    // Filter
    this.filterBrightness = 0,
    this.filterContrast = 0,
    this.filterSaturation = 0,
    this.filterTemperature = 0,
    this.filterPreset,
    // Sticker
    this.stickerId,
    this.stickerName,
    this.stickerEmoji,
    this.stickerAnimation,
    this.stickerScale = 1.0,
    this.stickerPosition,
  });

  TimelineClip copyWith({
    String? id,
    String? clipId,
    TrackType? track,
    double? position,
    double? duration,
    double? startTime,
    double? endTime,
    String? thumbnail,
    String? sourceUri,
    double? speed,
    double? volume,
    String? textContent,
    String? textFont,
    double? textFontSize,
    Color? textColor,
    TextAlign? textAlign,
    bool? textBold,
    bool? textItalic,
    bool? textUnderline,
    TextAnimationType? textAnimation,
    Offset? textPosition,
    double? audioVolume,
    bool? audioMuted,
    BgmItem? audioBgm,
    double? filterBrightness,
    double? filterContrast,
    double? filterSaturation,
    double? filterTemperature,
    FilterPresetType? filterPreset,
    String? stickerId,
    String? stickerName,
    String? stickerEmoji,
    StickerAnimationType? stickerAnimation,
    double? stickerScale,
    Offset? stickerPosition,
  }) {
    return TimelineClip(
      id: id ?? this.id,
      clipId: clipId ?? this.clipId,
      track: track ?? this.track,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      thumbnail: thumbnail ?? this.thumbnail,
      sourceUri: sourceUri ?? this.sourceUri,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      textContent: textContent ?? this.textContent,
      textFont: textFont ?? this.textFont,
      textFontSize: textFontSize ?? this.textFontSize,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      textBold: textBold ?? this.textBold,
      textItalic: textItalic ?? this.textItalic,
      textUnderline: textUnderline ?? this.textUnderline,
      textAnimation: textAnimation ?? this.textAnimation,
      textPosition: textPosition ?? this.textPosition,
      audioVolume: audioVolume ?? this.audioVolume,
      audioMuted: audioMuted ?? this.audioMuted,
      audioBgm: audioBgm ?? this.audioBgm,
      filterBrightness: filterBrightness ?? this.filterBrightness,
      filterContrast: filterContrast ?? this.filterContrast,
      filterSaturation: filterSaturation ?? this.filterSaturation,
      filterTemperature: filterTemperature ?? this.filterTemperature,
      filterPreset: filterPreset ?? this.filterPreset,
      stickerId: stickerId ?? this.stickerId,
      stickerName: stickerName ?? this.stickerName,
      stickerEmoji: stickerEmoji ?? this.stickerEmoji,
      stickerAnimation: stickerAnimation ?? this.stickerAnimation,
      stickerScale: stickerScale ?? this.stickerScale,
      stickerPosition: stickerPosition ?? this.stickerPosition,
    );
  }

  /// 클립 끝 위치 (타임라인상)
  double get endPosition => position + duration;

  /// 원본 소스의 시작 시간 (없으면 0)
  double get sourceStartTime => startTime ?? 0;

  /// 원본 소스의 끝 시간 (없으면 시작 + duration)
  double get sourceEndTime => endTime ?? (sourceStartTime + duration);

  /// 원본 소스 구간 길이
  double get sourceLength => sourceEndTime - sourceStartTime;

  /// 클립 라벨 생성 (UI 표시용)
  String get label {
    switch (track) {
      case TrackType.video:
        final clipNum = id.split('-').last;
        return '클립 $clipNum';
      case TrackType.text:
        return textContent ?? '텍스트';
      case TrackType.audio:
        return audioBgm?.name ?? '오디오';
      case TrackType.filter:
        return filterPreset != null ? '필터: ${filterPreset!.label}' : '필터';
      case TrackType.sticker:
        return stickerEmoji != null
            ? '$stickerEmoji ${stickerName ?? ''}'
            : '스티커';
    }
  }

  /// 트랙별 색상 반환
  Color get trackColor {
    switch (track) {
      case TrackType.video:
        return const Color(0xFF3B82F6); // Blue
      case TrackType.text:
        return const Color(0xFFF59E0B); // Amber
      case TrackType.audio:
        return const Color(0xFF10B981); // Emerald
      case TrackType.filter:
        return const Color(0xFFA855F7); // Purple
      case TrackType.sticker:
        return const Color(0xFFEC4899); // Pink
    }
  }
}
