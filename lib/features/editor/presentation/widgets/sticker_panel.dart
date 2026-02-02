import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/sticker_item.dart';
import '../../domain/models/timeline_clip.dart';

/// 스티커 선택 패널
///
/// React StickerPanel 컴포넌트를 Flutter로 변환
/// 스티커 선택 + 스케일/위치 조절 기능
class StickerPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final TimelineClip? editingClip;

  const StickerPanel({
    super.key,
    this.onClose,
    this.editingClip,
  });

  @override
  ConsumerState<StickerPanel> createState() => _StickerPanelState();
}

class _StickerPanelState extends ConsumerState<StickerPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StickerItem? _selectedSticker;
  double _scale = 1.0;
  Offset _position = const Offset(50, 50);
  double _duration = 3.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: StickerCategory.values.length,
      vsync: this,
    );

    // 편집 모드인 경우 기존 값 로드
    if (widget.editingClip != null) {
      final clip = widget.editingClip!;
      _selectedSticker = DefaultStickers.findById(clip.stickerId ?? '');
      _scale = clip.stickerScale;
      _position = clip.stickerPosition ?? const Offset(50, 50);
      _duration = clip.duration;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          _buildHeader(),

          // 스티커 프리뷰 (선택된 경우)
          if (_selectedSticker != null) _buildPreview(),

          // 카테고리 탭
          _buildCategoryTabs(),

          // 스티커 그리드
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: StickerCategory.values.map((category) {
                final stickers = DefaultStickers.byCategory(category);
                return _buildStickerGrid(stickers);
              }).toList(),
            ),
          ),

          // 스케일/위치 슬라이더 (선택된 경우)
          if (_selectedSticker != null) _buildControls(),

          // 비디오 없음 경고
          if (videoBounds == null) _buildWarning(),

          // 하단 버튼
          _buildActionButtons(videoBounds != null),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.editingClip != null ? '스티커 수정' : '스티커 추가',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Grid lines
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
          // Sticker at position
          Positioned(
            left: _position.dx / 100 * 300, // 예상 너비
            top: _position.dy / 100 * 160,
            child: Transform.translate(
              offset: const Offset(-24, -24), // 중앙 정렬
              child: Transform.scale(
                scale: _scale,
                child: Text(
                  _selectedSticker!.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          // Info overlay
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _selectedSticker!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_selectedSticker!.animation.label} | ${_duration.toStringAsFixed(1)}초',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: const Color(0xFFEC4899), // Pink for sticker
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: const Color(0xFFEC4899),
      tabs: StickerCategory.values.map((category) {
        return Tab(text: category.label);
      }).toList(),
    );
  }

  Widget _buildStickerGrid(List<StickerItem> stickers) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        final isSelected = _selectedSticker?.id == sticker.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedSticker = sticker),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEC4899).withValues(alpha: 0.1)
                  : AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFEC4899) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sticker.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  sticker.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? const Color(0xFFEC4899)
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scale
          _buildSlider(
            label: '크기',
            value: _scale,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            valueLabel: '${(_scale * 100).toInt()}%',
            onChanged: (value) => setState(() => _scale = value),
            leftLabel: '50%',
            centerLabel: '100%',
            rightLabel: '200%',
          ),
          const SizedBox(height: 16),

          // Position X
          _buildSlider(
            label: '가로 (X)',
            value: _position.dx,
            min: 0,
            max: 100,
            divisions: 100,
            valueLabel: '${_position.dx.toInt()}%',
            onChanged: (value) => setState(() => _position = Offset(value, _position.dy)),
            leftLabel: '왼쪽',
            centerLabel: '중앙',
            rightLabel: '오른쪽',
          ),
          const SizedBox(height: 16),

          // Position Y
          _buildSlider(
            label: '세로 (Y)',
            value: _position.dy,
            min: 0,
            max: 100,
            divisions: 100,
            valueLabel: '${_position.dy.toInt()}%',
            onChanged: (value) => setState(() => _position = Offset(_position.dx, value)),
            leftLabel: '위',
            centerLabel: '중앙',
            rightLabel: '아래',
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
    required String leftLabel,
    required String centerLabel,
    required String rightLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEC4899), // Pink
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFFEC4899),
          inactiveColor: AppColors.gray200,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(centerLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(rightLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '영상 클립을 먼저 추가해주세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool hasVideo) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: hasVideo && _selectedSticker != null
            ? _addOrUpdateSticker
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC4899),
          minimumSize: const Size.fromHeight(48),
        ),
        child: Text(
          _selectedSticker != null
              ? widget.editingClip != null
                  ? '${_selectedSticker!.emoji} ${_selectedSticker!.name} 수정'
                  : '${_selectedSticker!.emoji} ${_selectedSticker!.name} 추가'
              : '스티커를 선택하세요',
        ),
      ),
    );
  }

  void _addOrUpdateSticker() {
    if (_selectedSticker == null) return;

    final timelineState = ref.read(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    if (videoBounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 영상 클립을 추가하세요.')),
      );
      return;
    }

    if (widget.editingClip != null) {
      // 수정 모드
      final updatedClip = widget.editingClip!.copyWith(
        stickerId: _selectedSticker!.id,
        stickerName: _selectedSticker!.name,
        stickerEmoji: _selectedSticker!.emoji,
        stickerAnimation: _selectedSticker!.animation,
        stickerScale: _scale,
        stickerPosition: _position,
      );
      ref.read(timelineProvider.notifier).updateClip(
        widget.editingClip!.id,
        updatedClip,
      );
    } else {
      // 추가 모드
      final clip = TimelineClip(
        id: 'sticker-${DateTime.now().millisecondsSinceEpoch}',
        clipId: _selectedSticker!.id,
        track: TrackType.sticker,
        position: videoBounds.$1,
        duration: _duration.clamp(0.5, videoBounds.$2 - videoBounds.$1),
        stickerId: _selectedSticker!.id,
        stickerName: _selectedSticker!.name,
        stickerEmoji: _selectedSticker!.emoji,
        stickerAnimation: _selectedSticker!.animation,
        stickerScale: _scale,
        stickerPosition: _position,
      );

      ref.read(timelineProvider.notifier).addClip(clip);
    }

    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editingClip != null
              ? '${_selectedSticker!.emoji} ${_selectedSticker!.name} 스티커가 수정되었습니다.'
              : '${_selectedSticker!.emoji} ${_selectedSticker!.name} 스티커가 추가되었습니다.',
        ),
      ),
    );
  }
}

/// Grid painter for preview background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// StickerPanel을 BottomSheet으로 표시하는 유틸리티 함수
void showStickerPanel(BuildContext context, {TimelineClip? editingClip}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StickerPanel(editingClip: editingClip),
  );
}
