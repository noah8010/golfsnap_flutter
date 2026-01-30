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

  // Timeline Constants
  static const double timelinePixelsPerSecond = 50.0;
  static const double timelineMinZoom = 0.5;
  static const double timelineMaxZoom = 3.0;
  static const double timelineMinClipDuration = 0.1;
  static const double timelineTrackHeight = 48.0;
  static const double timelineVideoTrackHeight = 64.0;

  // Media Selection
  static const int maxMediaSelection = 20;

  // Aspect Ratios
  static const Map<String, double> aspectRatios = {
    '16:9': 16 / 9,
    '9:16': 9 / 16,
    '1:1': 1.0,
  };
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
