import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/data/providers/app_state_provider.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/timeline_clip.dart';
import '../widgets/time_ruler_widget.dart';
import '../widgets/track_label_widget.dart';
import '../widgets/playhead_widget.dart';
import '../widgets/timeline_track_widget.dart';
import '../widgets/speed_panel.dart';
import '../widgets/sticker_panel.dart';
import '../widgets/filter_panel.dart';
import '../widgets/audio_panel.dart';
import '../widgets/preview_overlay.dart';
import '../widgets/export_panel.dart';
import '../widgets/text_panel.dart';

/// 에디터 워크스페이스 화면
class EditorWorkspaceScreen extends ConsumerStatefulWidget {
  const EditorWorkspaceScreen({super.key});

  @override
  ConsumerState<EditorWorkspaceScreen> createState() => _EditorWorkspaceScreenState();
}

class _EditorWorkspaceScreenState extends ConsumerState<EditorWorkspaceScreen> {
  String _projectTitle = '새 프로젝트';
  bool _isEditingTitle = false;
  bool _isPlaying = false;
  double _currentTime = 0;

  // 스크롤 컨트롤러 (센터 플레이헤드 방식)
  late ScrollController _timelineScrollController;

  // 타임라인 스크롤 오프셋 (현재 시간 위치)
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _timelineScrollController = ScrollController();
    _timelineScrollController.addListener(_onScroll);

    final project = ref.read(currentProjectProvider);
    if (project != null) {
      _projectTitle = project.name;
    }

    // 선택된 미디어로 초기 클립 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeClipsFromMedia();
    });
  }

  @override
  void dispose() {
    _timelineScrollController.removeListener(_onScroll);
    _timelineScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final timelineState = ref.read(timelineProvider);
    final newTime = TimelineConfig.pixelsToTime(
      _timelineScrollController.offset,
      timelineState.zoom,
    );
    setState(() {
      _scrollOffset = _timelineScrollController.offset;
      _currentTime = newTime;
    });
  }

  void _initializeClipsFromMedia() {
    final selectedMedia = ref.read(selectedMediaProvider);
    final timelineNotifier = ref.read(timelineProvider.notifier);

    // 이미 클립이 있으면 초기화하지 않음
    if (ref.read(timelineProvider).clips.isNotEmpty) return;

    double position = 0;
    for (int i = 0; i < selectedMedia.length; i++) {
      final media = selectedMedia[i];
      final clip = TimelineClip(
        id: 'clip-${i + 1}',
        clipId: media.id,
        track: TrackType.video,
        position: position,
        duration: media.duration?.inSeconds.toDouble() ?? 5.0,
        thumbnail: media.thumbnailPath,
        sourceUri: media.path,
        startTime: 0,
        endTime: media.duration?.inSeconds.toDouble() ?? 5.0,
      );
      timelineNotifier.addClip(clip);
      position += clip.duration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(currentProjectProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Status Bar Spacer
            Container(
              height: AppConstants.statusBarHeight,
              color: AppColors.surface,
            ),

            // Top Bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/create'),
                    icon: const Icon(Icons.chevron_left, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 4),

                  // Project Title
                  Expanded(
                    child: _isEditingTitle
                        ? TextField(
                            autofocus: true,
                            controller: TextEditingController(text: _projectTitle),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _projectTitle = value;
                                _isEditingTitle = false;
                              });
                            },
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _isEditingTitle = true),
                            child: Text(
                              _projectTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Export Button
                  ElevatedButton(
                    onPressed: () {
                      _showExportDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('만들기'),
                  ),
                ],
              ),
            ),

            // Preview Player
            Expanded(
              flex: 45,
              child: Container(
                color: AppColors.gray900,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: project?.aspectRatio.ratio ?? 16 / 9,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final previewSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );

                        return Stack(
                          children: [
                            // Thumbnail or Placeholder
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.gray800,
                                image: project?.thumbnail != null
                                    ? DecorationImage(
                                        image: NetworkImage(project!.thumbnail!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: project?.thumbnail == null
                                  ? const Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: AppColors.gray600,
                                        size: 64,
                                      ),
                                    )
                                  : null,
                            ),

                            // Text/Sticker Overlay
                            PreviewOverlay(
                              currentTime: _currentTime,
                              previewSize: previewSize,
                            ),

                            // Play/Pause Overlay
                            GestureDetector(
                              onTap: () => setState(() => _isPlaying = !_isPlaying),
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _isPlaying ? 0 : 1,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Icon(
                                        _isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Time Display
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_formatTime(_currentTime)} / ${_formatTime(_totalDuration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),

                            // Aspect Ratio Badge
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  project?.aspectRatio.label ?? '16:9',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Timeline Area
            Expanded(
              flex: 55,
              child: _buildTimelineArea(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 타임라인 영역 빌드
  Widget _buildTimelineArea(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = (screenWidth - TimelineConfig.trackLabelWidth) / 2;

    // 타임라인 전체 너비 계산
    final totalDuration = timelineState.totalDuration;
    final contentWidth = TimelineConfig.timeToPixels(totalDuration, timelineState.zoom);
    // 좌우 패딩 추가 (센터 플레이헤드 방식)
    final timelineWidth = contentWidth + centerOffset * 2;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // 줌 컨트롤
          _buildZoomControls(timelineState),

          // 타임라인 콘텐츠
          Expanded(
            child: Row(
              children: [
                // 트랙 레이블
                TrackLabelsColumn(
                  onTextTrackTap: () => _showTextPanel(context),
                  onAudioTrackTap: () => _showAudioPanel(context),
                  onFilterTrackTap: () => _showFilterPanel(context),
                  onStickerTrackTap: () => _showStickerPanel(context),
                ),

                // 타임라인 트랙 영역
                Expanded(
                  child: Stack(
                    children: [
                      // 스크롤 가능한 타임라인
                      SingleChildScrollView(
                        controller: _timelineScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: timelineWidth,
                          child: Column(
                            children: [
                              // 타임 룰러
                              TimeRulerWidget(
                                totalDuration: totalDuration,
                                zoom: timelineState.zoom,
                                leftPadding: centerOffset,
                              ),

                              // 트랙들
                              Expanded(
                                child: TimelineTracksColumn(
                                  clips: timelineState.clips,
                                  selectedClipId: timelineState.selectedClipId,
                                  zoom: timelineState.zoom,
                                  leftPadding: centerOffset,
                                  width: timelineWidth,
                                  onClipTap: _onClipTap,
                                  onClipDoubleTap: _onClipDoubleTap,
                                  onClipMove: _onClipMove,
                                  onTrimStart: _onTrimStart,
                                  onTrimEnd: _onTrimEnd,
                                  onEmptyTap: _onEmptyTap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 센터 고정 플레이헤드
                      PlayheadWidget(centerOffset: centerOffset),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 하단 툴바
          _buildBottomToolbar(context, timelineState),
        ],
      ),
    );
  }

  /// 줌 컨트롤 빌드
  Widget _buildZoomControls(TimelineState timelineState) {
    return Container(
      height: TimelineConfig.zoomControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final newZoom = TimelineConfig.clampZoom(
                timelineState.zoom - TimelineConfig.zoomStep,
              );
              ref.read(timelineProvider.notifier).setZoom(newZoom);
            },
            icon: const Icon(Icons.zoom_out, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Slider(
              value: timelineState.zoom,
              min: TimelineConfig.zoomMin,
              max: TimelineConfig.zoomMax,
              divisions: ((TimelineConfig.zoomMax - TimelineConfig.zoomMin) /
                      TimelineConfig.zoomStep)
                  .round(),
              onChanged: (value) {
                ref.read(timelineProvider.notifier).setZoom(value);
              },
            ),
          ),
          IconButton(
            onPressed: () {
              final newZoom = TimelineConfig.clampZoom(
                timelineState.zoom + TimelineConfig.zoomStep,
              );
              ref.read(timelineProvider.notifier).setZoom(newZoom);
            },
            icon: const Icon(Icons.zoom_in, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Text(
            '${(timelineState.zoom * 100).toInt()}%',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  /// 하단 툴바 빌드
  Widget _buildBottomToolbar(BuildContext context, TimelineState timelineState) {
    final hasSelection = timelineState.selectedClipId != null;
    final selectedClip = timelineState.selectedClip;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarButton(
            icon: Icons.check_box_outlined,
            label: '선택해제',
            enabled: hasSelection,
            onTap: () {
              ref.read(timelineProvider.notifier).selectClip(null);
            },
          ),
          _ToolbarButton(
            icon: Icons.content_cut,
            label: '분할',
            enabled: hasSelection && selectedClip?.track == TrackType.video,
            onTap: () => _splitSelectedClip(),
          ),
          _ToolbarButton(
            icon: Icons.speed,
            label: '속도',
            enabled: hasSelection && selectedClip?.track == TrackType.video,
            onTap: () => _showSpeedPanel(context),
          ),
          _ToolbarButton(
            icon: Icons.copy,
            label: '복제',
            enabled: hasSelection,
            onTap: () => _duplicateSelectedClip(),
          ),
          _ToolbarButton(
            icon: Icons.delete_outline,
            label: '삭제',
            enabled: hasSelection,
            onTap: () => _deleteSelectedClip(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 클립 이벤트 핸들러
  // ============================================

  void _onClipTap(String clipId) {
    ref.read(timelineProvider.notifier).selectClip(clipId);
  }

  void _onClipDoubleTap(TimelineClip clip) {
    // 더블탭: 트랙 타입에 따른 편집 패널 표시
    switch (clip.track) {
      case TrackType.video:
        _showSpeedPanel(context);
        break;
      case TrackType.text:
        _showTextEditPanel(context, clip);
        break;
      case TrackType.audio:
        _showAudioPanel(context);
        break;
      case TrackType.filter:
        _showFilterPanel(context);
        break;
      case TrackType.sticker:
        _showStickerPanel(context);
        break;
    }
  }

  void _onClipMove(String clipId, double newPosition) {
    ref.read(timelineProvider.notifier).moveClip(clipId, newPosition);
  }

  void _onTrimStart(String clipId, double delta) {
    final clip = ref.read(timelineProvider).clips.firstWhere((c) => c.id == clipId);
    final newStartTime = clip.sourceStartTime +
        TimelineConfig.pixelsToTime(delta, ref.read(timelineProvider).zoom);
    ref.read(timelineProvider.notifier).trimClipStart(clipId, newStartTime);
  }

  void _onTrimEnd(String clipId, double delta) {
    final clip = ref.read(timelineProvider).clips.firstWhere((c) => c.id == clipId);
    final newEndTime = clip.sourceEndTime +
        TimelineConfig.pixelsToTime(delta, ref.read(timelineProvider).zoom);
    ref.read(timelineProvider.notifier).trimClipEnd(clipId, newEndTime);
  }

  void _onEmptyTap() {
    ref.read(timelineProvider.notifier).selectClip(null);
  }

  // ============================================
  // 클립 조작 메서드
  // ============================================

  void _splitSelectedClip() {
    final timelineState = ref.read(timelineProvider);
    final selectedClipId = timelineState.selectedClipId;
    if (selectedClipId == null) return;

    // 현재 플레이헤드 위치에서 분할
    final splitPoint = _currentTime;
    final success = ref.read(timelineProvider.notifier).splitClip(
      selectedClipId,
      splitPoint,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분할 위치가 클립 범위를 벗어났습니다.')),
      );
    }
  }

  void _duplicateSelectedClip() {
    final timelineState = ref.read(timelineProvider);
    final selectedClipId = timelineState.selectedClipId;
    if (selectedClipId == null) return;

    ref.read(timelineProvider.notifier).duplicateClip(selectedClipId);
  }

  void _deleteSelectedClip() {
    final timelineState = ref.read(timelineProvider);
    final selectedClipId = timelineState.selectedClipId;
    if (selectedClipId == null) return;

    ref.read(timelineProvider.notifier).deleteClip(selectedClipId);
  }

  // ============================================
  // 헬퍼 메서드
  // ============================================

  String _formatTime(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  double get _totalDuration => ref.watch(timelineProvider).totalDuration;

  void _showExportDialog(BuildContext context) {
    showExportPanel(context);
  }

  void _showTextPanel(BuildContext context) {
    showTextPanel(
      context,
      onAdd: (settings) => _addTextClip(settings),
    );
  }

  void _showTextEditPanel(BuildContext context, TimelineClip clip) {
    // 기존 텍스트 클립 설정을 TextSettings로 변환
    final initialSettings = TextSettings(
      content: clip.textContent ?? '',
      font: clip.textFont ?? 'noto-sans',
      fontSize: clip.textFontSize ?? 32,
      color: clip.textColor ?? Colors.white,
      align: clip.textAlign ?? TextAlign.center,
      bold: clip.textBold,
      italic: clip.textItalic,
      underline: clip.textUnderline,
      animation: clip.textAnimation ?? TextAnimationType.fadeIn,
      position: clip.textPosition ?? const Offset(50, 50),
    );

    showTextPanel(
      context,
      initialSettings: initialSettings,
      onAdd: (settings) {
        // TextSettings를 TimelineClip으로 변환하여 업데이트
        ref.read(timelineProvider.notifier).updateClip(
          clip.id,
          clip.copyWith(
            textContent: settings.content,
            textFont: settings.font,
            textFontSize: settings.fontSize,
            textColor: settings.color,
            textAlign: settings.align,
            textBold: settings.bold,
            textItalic: settings.italic,
            textUnderline: settings.underline,
            textAnimation: settings.animation,
            textPosition: settings.position,
          ),
        );
      },
    );
  }

  void _addTextClip(TextSettings settings) {
    final timelineState = ref.read(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    if (videoBounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 영상 클립을 추가하세요.')),
      );
      return;
    }

    final clip = TimelineClip(
      id: 'text-${DateTime.now().millisecondsSinceEpoch}',
      clipId: 'text-${DateTime.now().millisecondsSinceEpoch}',
      track: TrackType.text,
      position: videoBounds.$1,
      duration: (videoBounds.$2 - videoBounds.$1).clamp(1.0, 5.0),
      textContent: settings.content,
      textFont: settings.font,
      textFontSize: settings.fontSize,
      textColor: settings.color,
      textAlign: settings.align,
      textBold: settings.bold,
      textItalic: settings.italic,
      textUnderline: settings.underline,
      textAnimation: settings.animation,
      textPosition: settings.position,
    );

    ref.read(timelineProvider.notifier).addClip(clip);
  }

  void _showAudioPanel(BuildContext context) {
    showAudioPanel(context);
  }

  void _showFilterPanel(BuildContext context) {
    showFilterPanel(context);
  }

  void _showStickerPanel(BuildContext context) {
    showStickerPanel(context);
  }

  void _showSpeedPanel(BuildContext context) {
    showSpeedPanel(context);
  }

  void _showComingSoonPanel(BuildContext context, String feature) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(feature, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('이 기능은 개발 중입니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}


/// 툴바 버튼 위젯
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.textPrimary : AppColors.gray400;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

