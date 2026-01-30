/// 미디어 아이템 타입
enum MediaType { video, image }

/// 미디어 아이템 모델
class MediaItem {
  final String id;
  final MediaType type;
  final String uri;
  final String? thumbnail;
  final int? duration; // 비디오인 경우 초 단위
  final int width;
  final int height;
  final DateTime createdAt;
  final bool hasMetadata;
  final MediaMetadata? metadata;

  const MediaItem({
    required this.id,
    required this.type,
    required this.uri,
    this.thumbnail,
    this.duration,
    required this.width,
    required this.height,
    required this.createdAt,
    this.hasMetadata = false,
    this.metadata,
  });

  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? uri,
    String? thumbnail,
    int? duration,
    int? width,
    int? height,
    DateTime? createdAt,
    bool? hasMetadata,
    MediaMetadata? metadata,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      uri: uri ?? this.uri,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      hasMetadata: hasMetadata ?? this.hasMetadata,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 미디어 메타데이터 (골프 스윙 분석 데이터)
class MediaMetadata {
  final String? clubType;
  final double? swingSpeed;
  final String? location;

  const MediaMetadata({
    this.clubType,
    this.swingSpeed,
    this.location,
  });
}
