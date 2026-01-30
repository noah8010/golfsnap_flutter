import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// 타임라인 클립 모델
class TimelineClip {
  final String id;
  final TrackType track;
  final double position; // 시작 위치 (초)
  final double duration; // 길이 (초)
  final String? thumbnail;
  final String? sourceUri;

  // Video specific
  final double? speed;
  final double? volume;

  // Text specific
  final String? textContent;
  final Color? textColor;
  final double? textFontSize;
  final bool? textBold;
  final bool? textItalic;
  final bool? textUnderline;
  final TextAlign? textAlign;
  final Offset? textPosition; // 0-100 퍼센트 좌표

  // Audio specific
  final String? audioName;
  final double? audioVolume;

  // Filter specific
  final String? filterType;
  final double? filterIntensity;

  // Sticker specific
  final String? stickerEmoji;
  final double? stickerScale;
  final String? stickerAnimation;
  final Offset? stickerPosition; // 0-100 퍼센트 좌표

  const TimelineClip({
    required this.id,
    required this.track,
    required this.position,
    required this.duration,
    this.thumbnail,
    this.sourceUri,
    this.speed,
    this.volume,
    this.textContent,
    this.textColor,
    this.textFontSize,
    this.textBold,
    this.textItalic,
    this.textUnderline,
    this.textAlign,
    this.textPosition,
    this.audioName,
    this.audioVolume,
    this.filterType,
    this.filterIntensity,
    this.stickerEmoji,
    this.stickerScale,
    this.stickerAnimation,
    this.stickerPosition,
  });

  TimelineClip copyWith({
    String? id,
    TrackType? track,
    double? position,
    double? duration,
    String? thumbnail,
    String? sourceUri,
    double? speed,
    double? volume,
    String? textContent,
    Color? textColor,
    double? textFontSize,
    bool? textBold,
    bool? textItalic,
    bool? textUnderline,
    TextAlign? textAlign,
    Offset? textPosition,
    String? audioName,
    double? audioVolume,
    String? filterType,
    double? filterIntensity,
    String? stickerEmoji,
    double? stickerScale,
    String? stickerAnimation,
    Offset? stickerPosition,
  }) {
    return TimelineClip(
      id: id ?? this.id,
      track: track ?? this.track,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      sourceUri: sourceUri ?? this.sourceUri,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      textContent: textContent ?? this.textContent,
      textColor: textColor ?? this.textColor,
      textFontSize: textFontSize ?? this.textFontSize,
      textBold: textBold ?? this.textBold,
      textItalic: textItalic ?? this.textItalic,
      textUnderline: textUnderline ?? this.textUnderline,
      textAlign: textAlign ?? this.textAlign,
      textPosition: textPosition ?? this.textPosition,
      audioName: audioName ?? this.audioName,
      audioVolume: audioVolume ?? this.audioVolume,
      filterType: filterType ?? this.filterType,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      stickerEmoji: stickerEmoji ?? this.stickerEmoji,
      stickerScale: stickerScale ?? this.stickerScale,
      stickerAnimation: stickerAnimation ?? this.stickerAnimation,
      stickerPosition: stickerPosition ?? this.stickerPosition,
    );
  }

  /// 클립 끝 위치
  double get endPosition => position + duration;
}
