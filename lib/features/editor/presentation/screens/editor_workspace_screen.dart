import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/data/providers/app_state_provider.dart';

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
  final double _totalDuration = 30;

  @override
  void initState() {
    super.initState();
    final project = ref.read(currentProjectProvider);
    if (project != null) {
      _projectTitle = project.name;
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
                    child: Stack(
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
                                    color: Colors.white.withOpacity(0.2),
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
                              color: Colors.black.withOpacity(0.6),
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
                              color: Colors.black.withOpacity(0.7),
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
                    ),
                  ),
                ),
              ),
            ),

            // Timeline Area
            Expanded(
              flex: 55,
              child: Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    // Timeline Header (Zoom Controls)
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.zoom_out, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                          Expanded(
                            child: Slider(
                              value: 1.0,
                              min: 0.5,
                              max: 3.0,
                              onChanged: (value) {},
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.zoom_in, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ),

                    // Timeline Content
                    Expanded(
                      child: Row(
                        children: [
                          // Track Labels
                          Container(
                            width: 64,
                            color: AppColors.gray100,
                            child: Column(
                              children: [
                                const SizedBox(height: 24), // Time ruler space
                                _TrackLabel(label: '영상', height: 64),
                                _TrackLabel(
                                  label: '텍스트',
                                  height: 48,
                                  onTap: () => _showTextPanel(context),
                                ),
                                _TrackLabel(
                                  label: '오디오',
                                  height: 48,
                                  onTap: () => _showAudioPanel(context),
                                ),
                                _TrackLabel(
                                  label: '필터',
                                  height: 48,
                                  onTap: () => _showFilterPanel(context),
                                ),
                                _TrackLabel(
                                  label: '스티커',
                                  height: 48,
                                  onTap: () => _showStickerPanel(context),
                                ),
                              ],
                            ),
                          ),

                          // Timeline Tracks
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 600, // TODO: Dynamic width
                                child: Stack(
                                  children: [
                                    // Center Playhead
                                    Positioned(
                                      left: MediaQuery.of(context).size.width / 2 - 32,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 2,
                                        color: AppColors.error,
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        // Time Ruler
                                        Container(
                                          height: 24,
                                          color: AppColors.gray50,
                                          child: CustomPaint(
                                            painter: _TimeRulerPainter(),
                                            size: const Size(600, 24),
                                          ),
                                        ),

                                        // Video Track
                                        _TimelineTrack(
                                          height: 64,
                                          children: [
                                            _TimelineClipWidget(
                                              left: 50,
                                              width: 200,
                                              color: AppColors.primary,
                                              label: '클립 1',
                                            ),
                                            _TimelineClipWidget(
                                              left: 260,
                                              width: 150,
                                              color: AppColors.primary,
                                              label: '클립 2',
                                            ),
                                          ],
                                        ),

                                        // Text Track
                                        _TimelineTrack(
                                          height: 48,
                                          children: [
                                            _TimelineClipWidget(
                                              left: 100,
                                              width: 100,
                                              color: AppColors.secondary,
                                              label: '텍스트',
                                            ),
                                          ],
                                        ),

                                        // Audio Track
                                        _TimelineTrack(
                                          height: 48,
                                          children: const [],
                                        ),

                                        // Filter Track
                                        _TimelineTrack(
                                          height: 48,
                                          children: const [],
                                        ),

                                        // Sticker Track
                                        _TimelineTrack(
                                          height: 48,
                                          children: [
                                            _TimelineClipWidget(
                                              left: 150,
                                              width: 80,
                                              color: Colors.orange,
                                              label: '👍',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Toolbar
                    Container(
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
                            label: '선택',
                            onTap: () {},
                          ),
                          _ToolbarButton(
                            icon: Icons.content_cut,
                            label: '분할',
                            onTap: () {},
                          ),
                          _ToolbarButton(
                            icon: Icons.speed,
                            label: '속도',
                            onTap: () => _showSpeedPanel(context),
                          ),
                          _ToolbarButton(
                            icon: Icons.copy,
                            label: '복제',
                            onTap: () {},
                          ),
                          _ToolbarButton(
                            icon: Icons.delete_outline,
                            label: '삭제',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('만들기'),
        content: const Text('내보내기 기능은 개발 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showTextPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('텍스트 추가', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: '텍스트를 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioPanel(BuildContext context) {
    _showComingSoonPanel(context, '오디오');
  }

  void _showFilterPanel(BuildContext context) {
    _showComingSoonPanel(context, '필터');
  }

  void _showStickerPanel(BuildContext context) {
    _showComingSoonPanel(context, '스티커');
  }

  void _showSpeedPanel(BuildContext context) {
    _showComingSoonPanel(context, '속도 조절');
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

/// 트랙 레이블 위젯
class _TrackLabel extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;

  const _TrackLabel({
    required this.label,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 타임라인 트랙 위젯
class _TimelineTrack extends StatelessWidget {
  final double height;
  final List<Widget> children;

  const _TimelineTrack({
    required this.height,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        children: children,
      ),
    );
  }
}

/// 타임라인 클립 위젯
class _TimelineClipWidget extends StatelessWidget {
  final double left;
  final double width;
  final Color color;
  final String label;

  const _TimelineClipWidget({
    required this.left,
    required this.width,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// 타임 룰러 페인터
class _TimeRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray400
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 12; i++) {
      final x = i * 50.0;
      final isMain = i % 2 == 0;

      canvas.drawLine(
        Offset(x, isMain ? 0 : size.height / 2),
        Offset(x, size.height),
        paint,
      );

      if (isMain) {
        textPainter.text = TextSpan(
          text: '${i ~/ 2}s',
          style: const TextStyle(
            color: AppColors.gray500,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 4, 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
