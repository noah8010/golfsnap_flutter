import '../../../../core/constants/app_constants.dart';
import '../../../editor/domain/models/timeline_clip.dart';

/// 프로젝트 모델
class Project {
  final String id;
  final String name;
  final String? thumbnail;
  final AspectRatioType aspectRatio;
  final int duration; // 초 단위
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimelineClip> timeline;

  const Project({
    required this.id,
    required this.name,
    this.thumbnail,
    required this.aspectRatio,
    this.duration = 0,
    required this.createdAt,
    required this.updatedAt,
    this.timeline = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? thumbnail,
    AspectRatioType? aspectRatio,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimelineClip>? timeline,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeline: timeline ?? this.timeline,
    );
  }
}
