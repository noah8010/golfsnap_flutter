/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GolfSnap';
  static const String appVersion = '1.0.0';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 9999.0;

  // Status Bar Height (시뮬레이션용)
  static const double statusBarHeight = 44.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Media Selection
  static const int maxMediaSelection = 20;

  // Aspect Ratios
  static const Map<String, double> aspectRatios = {
    '16:9': 16 / 9,
    '9:16': 9 / 16,
    '1:1': 1.0,
  };
}

/// 타임라인 설정 상수
///
/// React constants/editor.ts의 TIMELINE_CONFIG를 Flutter로 변환
class TimelineConfig {
  TimelineConfig._();

  // ============================================
  // 줌 설정
  // ============================================
  static const double zoomMin = 0.5;
  static const double zoomMax = 3.0;
  static const double zoomStep = 0.25;
  static const double zoomDefault = 1.0;

  // ============================================
  // 타임라인 기본 설정
  // ============================================
  /// 초당 픽셀 수 (기본 줌 1.0 기준)
  static const double pixelsPerSecond = 10.0;

  /// 최소 클립 길이 (초)
  static const double minClipDuration = 0.1;

  /// 최소 클립 너비 (픽셀)
  static const double minClipWidth = 30.0;

  // ============================================
  // 속도 설정
  // ============================================
  static const double speedMin = 0.1;
  static const double speedMax = 8.0;
  static const double speedDefault = 1.0;
  static const double speedStep = 0.1;

  // ============================================
  // 트랙 높이
  // ============================================
  static const double videoTrackHeight = 64.0;
  static const double textTrackHeight = 48.0;
  static const double audioTrackHeight = 48.0;
  static const double filterTrackHeight = 48.0;
  static const double stickerTrackHeight = 48.0;
  static const double timeRulerHeight = 24.0;
  static const double trackLabelWidth = 64.0;
  static const double zoomControlHeight = 38.0;

  // ============================================
  // 플레이헤드 설정
  // ============================================
  /// 플레이헤드 상단 오프셋 (헤드 원)
  static const double playheadTopOffset = 52.0;

  /// 플레이헤드 상단 위치 (수직선)
  static const double playheadTopPosition = 50.0;

  /// 플레이헤드 너비
  static const double playheadWidth = 2.0;

  /// 플레이헤드 헤드 크기
  static const double playheadHeadSize = 12.0;

  // ============================================
  // 드래그 설정
  // ============================================
  /// 롱프레스 드래그 활성화 시간 (밀리초)
  static const int longPressDelayMs = 500;

  /// 트림 핸들 너비
  static const double trimHandleWidth = 12.0;

  /// 트림 핸들 터치 영역 확장
  static const double trimHandleTouchPadding = 8.0;

  // ============================================
  // 유틸리티 메서드
  // ============================================

  /// 시간(초)을 픽셀로 변환
  static double timeToPixels(double seconds, double zoom) {
    return seconds * pixelsPerSecond * zoom;
  }

  /// 픽셀을 시간(초)으로 변환
  static double pixelsToTime(double pixels, double zoom) {
    return pixels / (pixelsPerSecond * zoom);
  }

  /// 속도 값 clamp
  static double clampSpeed(double speed) {
    return speed.clamp(speedMin, speedMax);
  }

  /// 줌 값 clamp
  static double clampZoom(double zoom) {
    return zoom.clamp(zoomMin, zoomMax);
  }

  /// 트랙 타입에 따른 높이 반환
  static double getTrackHeight(TrackType track) {
    switch (track) {
      case TrackType.video:
        return videoTrackHeight;
      case TrackType.text:
        return textTrackHeight;
      case TrackType.audio:
        return audioTrackHeight;
      case TrackType.filter:
        return filterTrackHeight;
      case TrackType.sticker:
        return stickerTrackHeight;
    }
  }
}

/// 화면 비율 타입
enum AspectRatioType {
  landscape('16:9', 16 / 9, '유튜브 등 가로 영상'),
  portrait('9:16', 9 / 16, '쇼츠, 릴스 등 세로 영상'),
  square('1:1', 1.0, '인스타그램 피드');

  final String label;
  final double ratio;
  final String description;

  const AspectRatioType(this.label, this.ratio, this.description);
}

/// 트랙 타입
enum TrackType {
  video('영상'),
  text('텍스트'),
  audio('오디오'),
  filter('필터'),
  sticker('스티커');

  final String label;

  const TrackType(this.label);
}
