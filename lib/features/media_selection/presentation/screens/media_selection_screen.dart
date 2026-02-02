import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/media_item.dart';
import '../../../project_creation/presentation/screens/aspect_ratio_screen.dart';

/// Mock 미디어 데이터
final mockMediaItems = [
  MediaItem(
    id: 'media-1',
    type: MediaType.video,
    uri: 'video-1.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=400&fit=crop',
    duration: 15,
    width: 1920,
    height: 1080,
    createdAt: DateTime.now(),
    hasMetadata: true,
    metadata: const MediaMetadata(clubType: '드라이버', swingSpeed: 105, location: '남서울CC'),
  ),
  MediaItem(
    id: 'media-2',
    type: MediaType.image,
    uri: 'image-1.jpg',
    thumbnail: 'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=400&h=400&fit=crop',
    width: 1920,
    height: 1080,
    createdAt: DateTime.now(),
    hasMetadata: false,
  ),
  MediaItem(
    id: 'media-3',
    type: MediaType.video,
    uri: 'video-2.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1592919505780-303950717480?w=400&h=400&fit=crop',
    duration: 22,
    width: 1920,
    height: 1080,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    hasMetadata: true,
    metadata: const MediaMetadata(clubType: '7번 아이언', swingSpeed: 85, location: '용인CC'),
  ),
  MediaItem(
    id: 'media-4',
    type: MediaType.image,
    uri: 'image-2.jpg',
    thumbnail: 'https://images.unsplash.com/photo-1596727362302-b8d891c42ab8?w=400&h=400&fit=crop',
    width: 1920,
    height: 1080,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    hasMetadata: true,
    metadata: const MediaMetadata(clubType: '퍼터', location: '용인CC'),
  ),
  MediaItem(
    id: 'media-5',
    type: MediaType.video,
    uri: 'video-3.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1530028828-25e8270e98fb?w=400&h=400&fit=crop',
    duration: 18,
    width: 1920,
    height: 1080,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    hasMetadata: false,
  ),
  MediaItem(
    id: 'media-6',
    type: MediaType.video,
    uri: 'video-4.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1622630998477-20aa696ecb05?w=400&h=400&fit=crop',
    duration: 12,
    width: 1920,
    height: 1080,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    hasMetadata: true,
    metadata: const MediaMetadata(clubType: '드라이버', swingSpeed: 110, location: '파주CC'),
  ),
];

/// 선택된 미디어 Provider
final selectedMediaProvider = StateProvider<List<MediaItem>>((ref) => []);

/// 선택된 탭 Provider
final selectedTabProvider = StateProvider<String>((ref) => 'all');

/// 미디어 선택 화면
class MediaSelectionScreen extends ConsumerStatefulWidget {
  final bool isShareMode;

  const MediaSelectionScreen({
    super.key,
    this.isShareMode = false,
  });

  @override
  ConsumerState<MediaSelectionScreen> createState() => _MediaSelectionScreenState();
}

class _MediaSelectionScreenState extends ConsumerState<MediaSelectionScreen> {
  bool _showEditModeDialog = false;

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final selectedMedia = ref.watch(selectedMediaProvider);
    final aspectRatio = ref.watch(selectedAspectRatioProvider);

    // 필터링된 미디어
    final filteredMedia = mockMediaItems.where((item) {
      if (selectedTab == 'all') return true;
      if (selectedTab == 'video') return item.type == MediaType.video;
      if (selectedTab == 'image') return item.type == MediaType.image;
      return true;
    }).toList();

    // 날짜별 그룹화
    final groupedMedia = _groupByDate(filteredMedia);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Column(
          children: [
            // Status Bar Spacer
            Container(
              height: AppConstants.statusBarHeight,
              color: AppColors.surface,
            ),

            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.chevron_left, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '미디어 선택',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.go('/create'),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Row(
                      children: [
                        _TabButton(
                          label: '전체',
                          isSelected: selectedTab == 'all',
                          onTap: () => ref.read(selectedTabProvider.notifier).state = 'all',
                        ),
                        const SizedBox(width: 8),
                        _TabButton(
                          label: '영상',
                          isSelected: selectedTab == 'video',
                          onTap: () => ref.read(selectedTabProvider.notifier).state = 'video',
                        ),
                        const SizedBox(width: 8),
                        _TabButton(
                          label: '이미지',
                          isSelected: selectedTab == 'image',
                          onTap: () => ref.read(selectedTabProvider.notifier).state = 'image',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Media Grid (날짜별 그룹화)
            Expanded(
              child: ListView.builder(
                itemCount: groupedMedia.length,
                itemBuilder: (context, index) {
                  final entry = groupedMedia.entries.elementAt(index);
                  final dateLabel = entry.key;
                  final items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Container(
                        color: AppColors.gray50,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              dateLabel,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.gray700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${items.length}개',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),

                      // Media Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(2),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, itemIndex) {
                          final media = items[itemIndex];
                          final selectionIndex = selectedMedia.indexWhere((m) => m.id == media.id);
                          final isSelected = selectionIndex >= 0;

                          return _MediaTile(
                            media: media,
                            isSelected: isSelected,
                            selectionOrder: isSelected ? selectionIndex + 1 : null,
                            onTap: () {
                              final current = ref.read(selectedMediaProvider);
                              if (isSelected) {
                                ref.read(selectedMediaProvider.notifier).state =
                                    current.where((m) => m.id != media.id).toList();
                              } else {
                                ref.read(selectedMediaProvider.notifier).state = [...current, media];
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Metadata Legend
            Container(
              color: AppColors.gray50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info, color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '스윙 분석 데이터 포함',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedMedia.isNotEmpty
                              ? '${selectedMedia.length}개 선택됨'
                              : '미디어를 선택하세요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '화면 비율: ${aspectRatio?.label ?? '미선택'}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedMedia.isEmpty ? null : _handleNextClick,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppColors.primary.withValues(alpha:0.4),
                        ),
                        child: Text(widget.isShareMode ? '다음' : '타임라인 생성'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

          // Edit Mode Dialog
          if (_showEditModeDialog) _buildEditModeDialog(),
        ],
      ),
    );
  }

  void _handleNextClick() {
    final selectedMedia = ref.read(selectedMediaProvider);

    // 공유 모드이고 2개 이상 선택된 경우 편집 모드 선택 다이얼로그 표시
    if (widget.isShareMode && selectedMedia.length >= 2) {
      setState(() {
        _showEditModeDialog = true;
      });
    } else {
      context.push('/editor');
    }
  }

  void _handleEditModeChoice(bool useEditMode) {
    setState(() {
      _showEditModeDialog = false;
    });

    if (useEditMode) {
      // 편집 모드로 전환
      context.push('/editor');
    }
    // 취소하면 다이얼로그만 닫고 미디어 선택 화면 유지
  }

  Widget _buildEditModeDialog() {
    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => setState(() {
            _showEditModeDialog = false;
          }),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),

        // Dialog
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '편집 모드로 전환',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '여러 개의 미디어를 선택하셨습니다.\n편집 모드로 전환하시겠습니까?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleEditModeChoice(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gray100,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleEditModeChoice(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('편집하기'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List<MediaItem>> _groupByDate(List<MediaItem> items) {
    final Map<String, List<MediaItem>> groups = {};
    final now = DateTime.now();

    for (final item in items) {
      String label;
      final diff = now.difference(item.createdAt);

      if (diff.inDays == 0) {
        label = '오늘';
      } else if (diff.inDays == 1) {
        label = '어제';
      } else {
        final month = item.createdAt.month;
        final day = item.createdAt.day;
        final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
        final weekday = weekdays[item.createdAt.weekday % 7];
        label = '$month월 $day일 ($weekday)';
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(item);
    }

    return groups;
  }
}

/// 탭 버튼 위젯
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.gray100,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 미디어 타일 위젯
class _MediaTile extends StatelessWidget {
  final MediaItem media;
  final bool isSelected;
  final int? selectionOrder;
  final VoidCallback onTap;

  const _MediaTile({
    required this.media,
    required this.isSelected,
    this.selectionOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          Image.network(
            media.thumbnail ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.gray200),
          ),

          // Selection Overlay
          if (isSelected)
            Container(
              color: AppColors.secondary.withValues(alpha:0.3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
              ),
            ),

          // Metadata Mark
          if (media.hasMetadata)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 12),
              ),
            ),

          // Video Duration
          if (media.type == MediaType.video && media.duration != null)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      _formatDuration(media.duration!),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // Selection Order
          if (isSelected && selectionOrder != null)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$selectionOrder',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Check Icon
          if (isSelected)
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
