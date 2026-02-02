import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/timeline_clip.dart';

/// 타임라인 상태
class TimelineState {
  final List<TimelineClip> clips;
  final String? selectedClipId;
  final double scrollOffset;
  final double zoom;
  final double currentTime;
  final bool isPlaying;

  const TimelineState({
    this.clips = const [],
    this.selectedClipId,
    this.scrollOffset = 0,
    this.zoom = 1.0,
    this.currentTime = 0,
    this.isPlaying = false,
  });

  TimelineState copyWith({
    List<TimelineClip>? clips,
    String? selectedClipId,
    bool clearSelection = false,
    double? scrollOffset,
    double? zoom,
    double? currentTime,
    bool? isPlaying,
  }) {
    return TimelineState(
      clips: clips ?? this.clips,
      selectedClipId: clearSelection ? null : (selectedClipId ?? this.selectedClipId),
      scrollOffset: scrollOffset ?? this.scrollOffset,
      zoom: zoom ?? this.zoom,
      currentTime: currentTime ?? this.currentTime,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  /// 선택된 클립
  TimelineClip? get selectedClip {
    if (selectedClipId == null) return null;
    try {
      return clips.firstWhere((c) => c.id == selectedClipId);
    } catch (_) {
      return null;
    }
  }

  /// 비디오 클립만 필터링
  List<TimelineClip> get videoClips =>
      clips.where((c) => c.track == TrackType.video).toList();

  /// 비디오 총 길이 (마지막 클립 끝 위치)
  double get videoTotalDuration {
    final vClips = videoClips;
    if (vClips.isEmpty) return 0;
    return vClips.map((c) => c.endPosition).reduce((a, b) => a > b ? a : b);
  }

  /// 전체 타임라인 길이
  double get totalDuration {
    if (clips.isEmpty) return 60;
    final maxEnd = clips.map((c) => c.endPosition).reduce((a, b) => a > b ? a : b);
    return maxEnd > 10 ? maxEnd : 10;
  }

  /// 비디오 클립 범위 (시작, 끝) 반환
  /// 비디오 클립이 없으면 null 반환
  (double, double)? get videoBounds {
    final vClips = videoClips;
    if (vClips.isEmpty) return null;
    final start = vClips.map((c) => c.position).reduce((a, b) => a < b ? a : b);
    final end = vClips.map((c) => c.endPosition).reduce((a, b) => a > b ? a : b);
    return (start, end);
  }
}

/// 타임라인 상태 관리 Notifier
///
/// React의 useTimeline 훅을 Flutter Riverpod으로 변환
class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier() : super(const TimelineState()) {
    _initMockData();
  }

  /// Mock 데이터 초기화
  void _initMockData() {
    final mockClips = [
      TimelineClip(
        id: 'clip-1',
        clipId: 'media-1',
        track: TrackType.video,
        position: 0,
        duration: 15,
        startTime: 0,
        endTime: 15,
        speed: 1.0,
      ),
      TimelineClip(
        id: 'clip-2',
        clipId: 'media-2',
        track: TrackType.video,
        position: 15,
        duration: 22,
        startTime: 0,
        endTime: 22,
        speed: 1.0,
      ),
      TimelineClip(
        id: 'clip-3',
        clipId: 'media-3',
        track: TrackType.video,
        position: 37,
        duration: 18,
        startTime: 0,
        endTime: 18,
        speed: 1.0,
      ),
    ];
    state = state.copyWith(clips: mockClips);
  }

  /// 외부 클립 목록으로 초기화
  void initializeClips(List<TimelineClip> clips) {
    // 비디오 범위 내로 조정
    final adjusted = _adjustClipsToVideoBounds(clips);
    state = state.copyWith(clips: adjusted, clearSelection: true);
  }

  // ============================================
  // 선택 관리
  // ============================================

  void selectClip(String? clipId) {
    if (clipId == null) {
      state = state.copyWith(clearSelection: true);
    } else {
      state = state.copyWith(selectedClipId: clipId);
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  // ============================================
  // UI 상태 관리
  // ============================================

  void setScrollOffset(double offset) {
    state = state.copyWith(scrollOffset: offset);
  }

  void setZoom(double zoom) {
    final clampedZoom = TimelineConfig.clampZoom(zoom);
    state = state.copyWith(zoom: clampedZoom);
  }

  void setCurrentTime(double time) {
    state = state.copyWith(currentTime: time);
  }

  void setIsPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  // ============================================
  // 클립 CRUD
  // ============================================

  void addClip(TimelineClip clip) {
    state = state.copyWith(clips: [...state.clips, clip]);
  }

  void updateClipWith(String clipId, TimelineClip Function(TimelineClip) update) {
    state = state.copyWith(
      clips: state.clips.map((c) => c.id == clipId ? update(c) : c).toList(),
    );
  }

  void updateClip(String clipId, TimelineClip newClip) {
    state = state.copyWith(
      clips: state.clips.map((c) => c.id == clipId ? newClip : c).toList(),
    );
  }

  void deleteClip(String clipId) {
    final clip = state.clips.firstWhere((c) => c.id == clipId);

    // 삭제 후 리플 편집 적용
    var updatedClips = state.clips
        .where((c) => c.id != clipId)
        .map((c) {
          // 같은 트랙의 뒤 클립들 앞으로 이동 (리플 편집)
          if (c.track == clip.track && c.position > clip.position) {
            return c.copyWith(position: c.position - clip.duration);
          }
          return c;
        })
        .toList();

    // 비디오 클립 삭제 시 다른 트랙 범위 재조정
    if (clip.track == TrackType.video) {
      updatedClips = _adjustNonVideoClips(updatedClips);
    }

    state = state.copyWith(clips: updatedClips, clearSelection: true);
  }

  void duplicateClip(String clipId) {
    final clip = state.clips.firstWhere((c) => c.id == clipId);
    final newId = 'clip-${DateTime.now().millisecondsSinceEpoch}';

    final newClip = clip.copyWith(
      id: newId,
      clipId: '${clip.clipId}-copy',
      position: clip.endPosition,
    );

    // 뒤 클립들 밀기 (리플 편집)
    final updatedClips = state.clips.map((c) {
      if (c.track == clip.track && c.position >= newClip.position) {
        return c.copyWith(position: c.position + newClip.duration);
      }
      return c;
    }).toList();

    state = state.copyWith(clips: [...updatedClips, newClip]);
  }

  // ============================================
  // 클립 분할
  // ============================================

  bool splitClip(String clipId, double splitPoint) {
    final clipIndex = state.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return false;

    final clip = state.clips[clipIndex];
    final currentSpeed = clip.speed;
    final minDuration = TimelineConfig.minClipDuration;

    // 분할 가능 여부 확인
    if (splitPoint <= minDuration || splitPoint >= clip.duration - minDuration) {
      return false;
    }

    // 원본 영상 구간 계산
    final sourceStart = clip.sourceStartTime;
    final sourceEnd = clip.sourceEndTime;
    final sourceLength = sourceEnd - sourceStart;

    // splitPoint를 원본 구간으로 변환
    final ratio = splitPoint / clip.duration;
    final sourceMidPoint = sourceStart + (sourceLength * ratio);

    // 클립 1: 앞부분
    final clip1 = clip.copyWith(
      id: '${clip.id}-a',
      duration: splitPoint,
      startTime: sourceStart,
      endTime: sourceMidPoint,
    );

    // 클립 2: 뒷부분
    final clip2 = clip.copyWith(
      id: '${clip.id}-b',
      position: clip.position + splitPoint,
      duration: clip.duration - splitPoint,
      startTime: sourceMidPoint,
      endTime: sourceEnd,
    );

    final newClips = [...state.clips];
    newClips.removeAt(clipIndex);
    newClips.insertAll(clipIndex, [clip1, clip2]);

    state = state.copyWith(clips: newClips, clearSelection: true);
    return true;
  }

  // ============================================
  // 속도 조절
  // ============================================

  void updateClipSpeed(String clipId, double speed) {
    final nextSpeed = TimelineConfig.clampSpeed(speed);
    final clipIndex = state.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return;

    final clip = state.clips[clipIndex];

    // 원본 구간 길이 계산
    final sourceLength = clip.sourceLength;

    // 속도에 따른 새 duration
    final newDuration = (sourceLength / nextSpeed).clamp(
      TimelineConfig.minClipDuration,
      double.infinity,
    );
    final durationDelta = newDuration - clip.duration;

    var updated = state.clips.asMap().entries.map((entry) {
      final idx = entry.key;
      final c = entry.value;

      if (idx == clipIndex) {
        return c.copyWith(speed: nextSpeed, duration: newDuration);
      }

      // 같은 트랙의 뒤 클립들 이동 (리플 편집)
      if (c.track == clip.track && c.position > clip.position && durationDelta != 0) {
        return c.copyWith(position: c.position + durationDelta);
      }

      return c;
    }).toList();

    // 비디오 범위 재조정
    updated = _adjustNonVideoClips(updated);

    state = state.copyWith(clips: updated);
  }

  // ============================================
  // 트림 (시작점)
  // ============================================

  void trimClipStart(String clipId, double newStartTime) {
    final clipIndex = state.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return;

    final clip = state.clips[clipIndex];

    // 텍스트/오디오/필터/스티커: 위치 이동
    if (clip.track != TrackType.video) {
      _trimNonVideoClipStart(clipIndex, newStartTime);
      return;
    }

    // 비디오: 원본 영상 길이 제한 + 리플 편집
    _trimVideoClipStart(clipIndex, newStartTime);
  }

  void _trimNonVideoClipStart(int clipIndex, double deltaPosition) {
    final clip = state.clips[clipIndex];
    final videoEnd = state.videoTotalDuration;

    final newPosition = (clip.position + deltaPosition).clamp(0.0, videoEnd - TimelineConfig.minClipDuration);
    final actualDelta = newPosition - clip.position;
    final newDuration = (clip.duration - actualDelta).clamp(TimelineConfig.minClipDuration, videoEnd);

    // 범위 검증
    final maxPosition = (videoEnd - newDuration).clamp(0.0, double.infinity);
    final finalPosition = newPosition.clamp(0.0, maxPosition);

    state = state.copyWith(
      clips: state.clips.asMap().entries.map((entry) {
        if (entry.key == clipIndex) {
          return entry.value.copyWith(position: finalPosition, duration: newDuration);
        }
        return entry.value;
      }).toList(),
    );
  }

  void _trimVideoClipStart(int clipIndex, double newStartTime) {
    final clip = state.clips[clipIndex];
    final currentStart = clip.sourceStartTime;
    final currentEnd = clip.sourceEndTime;
    final currentSpeed = clip.speed;

    // 트림 제한: 원본 startTime 이전 불가
    if (newStartTime < currentStart ||
        newStartTime >= currentEnd - TimelineConfig.minClipDuration) {
      return;
    }

    // 새 duration 계산
    final sourceLength = currentEnd - newStartTime;
    final newDuration = sourceLength / currentSpeed;
    final durationDelta = newDuration - clip.duration;

    // 첫 번째 클립인지 확인
    final sameTrackClips = state.clips.where((c) => c.track == clip.track).toList();
    final isFirstClip = sameTrackClips.every((c) => c.position >= clip.position);

    var updated = state.clips.asMap().entries.map((entry) {
      final idx = entry.key;
      final c = entry.value;

      if (idx == clipIndex) {
        return c.copyWith(
          startTime: newStartTime,
          duration: newDuration,
          position: isFirstClip ? 0 : c.position,
        );
      }

      // 같은 트랙의 뒤 클립들 이동
      if (c.track == clip.track && c.position > clip.position) {
        return c.copyWith(position: c.position + durationDelta);
      }

      return c;
    }).toList();

    updated = _adjustNonVideoClips(updated);
    state = state.copyWith(clips: updated);
  }

  // ============================================
  // 트림 (끝점)
  // ============================================

  void trimClipEnd(String clipId, double newEndTime) {
    final clipIndex = state.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return;

    final clip = state.clips[clipIndex];

    if (clip.track != TrackType.video) {
      _trimNonVideoClipEnd(clipIndex, newEndTime);
      return;
    }

    _trimVideoClipEnd(clipIndex, newEndTime);
  }

  void _trimNonVideoClipEnd(int clipIndex, double deltaDuration) {
    final clip = state.clips[clipIndex];
    final videoEnd = state.videoTotalDuration;

    var newDuration = (clip.duration + deltaDuration).clamp(
      TimelineConfig.minClipDuration,
      videoEnd,
    );

    // 비디오 끝 초과 방지
    if (clip.position + newDuration > videoEnd) {
      newDuration = videoEnd - clip.position;
    }

    state = state.copyWith(
      clips: state.clips.asMap().entries.map((entry) {
        if (entry.key == clipIndex) {
          return entry.value.copyWith(
            duration: newDuration.clamp(TimelineConfig.minClipDuration, double.infinity),
          );
        }
        return entry.value;
      }).toList(),
    );
  }

  void _trimVideoClipEnd(int clipIndex, double newEndTime) {
    final clip = state.clips[clipIndex];
    final currentStart = clip.sourceStartTime;
    final currentEnd = clip.sourceEndTime;
    final currentSpeed = clip.speed;

    // 트림 제한: 원본 endTime 초과 불가
    if (newEndTime <= currentStart + TimelineConfig.minClipDuration ||
        newEndTime > currentEnd) {
      return;
    }

    // 새 duration 계산
    final sourceLength = newEndTime - currentStart;
    final newDuration = sourceLength / currentSpeed;
    final durationDelta = newDuration - clip.duration;

    var updated = state.clips.asMap().entries.map((entry) {
      final idx = entry.key;
      final c = entry.value;

      if (idx == clipIndex) {
        return c.copyWith(endTime: newEndTime, duration: newDuration);
      }

      // 같은 트랙의 뒤 클립들 이동
      if (c.track == clip.track && c.position > clip.position) {
        return c.copyWith(position: c.position + durationDelta);
      }

      return c;
    }).toList();

    updated = _adjustNonVideoClips(updated);
    state = state.copyWith(clips: updated);
  }

  // ============================================
  // 클립 이동
  // ============================================

  void moveClip(String clipId, double newPosition) {
    final clip = state.clips.firstWhere((c) => c.id == clipId);

    if (clip.track == TrackType.video) {
      _moveVideoClip(clipId, newPosition);
    } else {
      _moveNonVideoClip(clipId, newPosition);
    }
  }

  void _moveVideoClip(String clipId, double newPosition) {
    final videoClips = state.videoClips..sort((a, b) => a.position.compareTo(b.position));
    final currentIndex = videoClips.indexWhere((c) => c.id == clipId);
    if (currentIndex == -1) return;

    // 새 위치에 해당하는 인덱스 찾기
    int targetIndex = currentIndex;
    double cumulativePosition = 0;

    for (int i = 0; i < videoClips.length; i++) {
      final midPoint = cumulativePosition + videoClips[i].duration / 2;
      if (newPosition < midPoint) {
        targetIndex = i;
        break;
      }
      cumulativePosition += videoClips[i].duration;
      targetIndex = i + 1;
    }

    // 순서 변경이 필요한 경우
    if (targetIndex != currentIndex) {
      final newVideoClips = [...videoClips];
      final movedClip = newVideoClips.removeAt(currentIndex);
      newVideoClips.insert(
        targetIndex > currentIndex ? targetIndex - 1 : targetIndex,
        movedClip,
      );

      // position 재계산
      double position = 0;
      final updatedVideoClips = newVideoClips.map((c) {
        final updated = c.copyWith(position: position);
        position += c.duration;
        return updated;
      }).toList();

      // 전체 타임라인에 반영
      state = state.copyWith(
        clips: state.clips.map((c) {
          if (c.track == TrackType.video) {
            return updatedVideoClips.firstWhere((vc) => vc.id == c.id, orElse: () => c);
          }
          return c;
        }).toList(),
      );
    }
  }

  void _moveNonVideoClip(String clipId, double newPosition) {
    final clip = state.clips.firstWhere((c) => c.id == clipId);
    final videoEnd = state.videoTotalDuration;

    if (videoEnd == 0) return;

    // 비디오 범위 내로 제한
    final minPosition = 0.0;
    final maxPosition = (videoEnd - clip.duration).clamp(0.0, double.infinity);
    final finalPosition = newPosition.clamp(minPosition, maxPosition);

    state = state.copyWith(
      clips: state.clips.map((c) {
        if (c.id == clipId) {
          return c.copyWith(position: finalPosition);
        }
        return c;
      }).toList(),
    );
  }

  // ============================================
  // 헬퍼 메서드
  // ============================================

  /// 비디오 이외 클립을 비디오 범위 내로 조정
  List<TimelineClip> _adjustNonVideoClips(List<TimelineClip> clips) {
    final videoClips = clips.where((c) => c.track == TrackType.video).toList();
    if (videoClips.isEmpty) return clips;

    final videoEnd = videoClips.map((c) => c.endPosition).reduce((a, b) => a > b ? a : b);

    return clips.map((c) {
      if (c.track != TrackType.video) {
        if (c.position + c.duration > videoEnd) {
          final maxPosition = (videoEnd - c.duration).clamp(0.0, double.infinity);
          return c.copyWith(position: c.position.clamp(0.0, maxPosition));
        }
      }
      return c;
    }).toList();
  }

  /// 클립 목록을 비디오 범위 내로 조정
  List<TimelineClip> _adjustClipsToVideoBounds(List<TimelineClip> clips) {
    final videoClips = clips.where((c) => c.track == TrackType.video).toList();
    if (videoClips.isEmpty) return clips;

    final videoEnd = videoClips.map((c) => c.endPosition).reduce((a, b) => a > b ? a : b);

    return clips.map((clip) {
      if (clip.track != TrackType.video) {
        final minPosition = 0.0;
        final maxPosition = (videoEnd - clip.duration).clamp(0.0, double.infinity);
        final adjustedPosition = clip.position.clamp(minPosition, maxPosition);

        if (adjustedPosition != clip.position) {
          return clip.copyWith(position: adjustedPosition);
        }
      }
      return clip;
    }).toList();
  }
}

/// 타임라인 Provider
final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) => TimelineNotifier(),
);

/// 선택된 클립 Provider
final selectedClipProvider = Provider<TimelineClip?>((ref) {
  return ref.watch(timelineProvider).selectedClip;
});

/// 비디오 클립 목록 Provider
final videoClipsProvider = Provider<List<TimelineClip>>((ref) {
  return ref.watch(timelineProvider).videoClips;
});

/// 전체 타임라인 길이 Provider
final totalDurationProvider = Provider<double>((ref) {
  return ref.watch(timelineProvider).totalDuration;
});

/// 현재 줌 레벨 Provider
final zoomProvider = Provider<double>((ref) {
  return ref.watch(timelineProvider).zoom;
});

/// 재생 상태 Provider
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(timelineProvider).isPlaying;
});

/// 현재 시간 Provider
final currentTimeProvider = Provider<double>((ref) {
  return ref.watch(timelineProvider).currentTime;
});
