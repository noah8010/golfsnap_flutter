import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';

/// 내보내기 품질 옵션
enum ExportQuality {
  low('저화질', '480p', '빠른 공유용'),
  medium('중화질', '720p', '일반 SNS용'),
  high('고화질', '1080p', '고품질 영상'),
  ultra('최고화질', '4K', '전문 콘텐츠용');

  final String label;
  final String resolution;
  final String description;

  const ExportQuality(this.label, this.resolution, this.description);
}

/// 내보내기 패널
///
/// React ExportPanel 컴포넌트를 Flutter로 변환
/// 영상 내보내기 품질 선택 및 내보내기 실행
class ExportPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onExport;

  const ExportPanel({
    super.key,
    this.onClose,
    this.onExport,
  });

  @override
  ConsumerState<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<ExportPanel> {
  ExportQuality _selectedQuality = ExportQuality.high;
  bool _isExporting = false;
  double _exportProgress = 0;

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final hasContent = timelineState.clips.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영상 내보내기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _isExporting
                      ? null
                      : (widget.onClose ?? () => Navigator.pop(context)),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 프로젝트 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.movie,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '총 ${timelineState.clips.where((c) => c.track.name == 'video').length}개 클립',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatDuration(timelineState.totalDuration)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 품질 선택
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내보내기 품질',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: ExportQuality.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final quality = ExportQuality.values[index];
                final isSelected = _selectedQuality == quality;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.gray50,
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  leading: Radio<ExportQuality>(
                    value: quality,
                    groupValue: _selectedQuality,
                    onChanged: _isExporting
                        ? null
                        : (value) => setState(() => _selectedQuality = value!),
                    activeColor: AppColors.primary,
                  ),
                  title: Row(
                    children: [
                      Text(
                        quality.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quality.resolution,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    quality.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  onTap: _isExporting
                      ? null
                      : () => setState(() => _selectedQuality = quality),
                );
              },
            ),
          ),

          // 내보내기 진행 상태
          if (_isExporting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _exportProgress,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '내보내기 중... ${(_exportProgress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: hasContent && !_isExporting ? _startExport : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(_isExporting ? '내보내는 중...' : '내보내기'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '${mins}분 ${secs}초';
  }

  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0;
    });

    // 실제 내보내기 대신 시뮬레이션
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _exportProgress = i / 100;
      });
    }

    if (!mounted) return;

    setState(() {
      _isExporting = false;
    });

    widget.onExport?.call();
    widget.onClose?.call() ?? Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedQuality.resolution} 품질로 내보내기가 완료되었습니다.'),
          action: SnackBarAction(
            label: '갤러리에서 보기',
            onPressed: () {
              // 갤러리 열기 기능
            },
          ),
        ),
      );
    }
  }
}

/// ExportPanel을 BottomSheet으로 표시하는 유틸리티 함수
void showExportPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const ExportPanel(),
  );
}
