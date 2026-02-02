import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/timeline_clip.dart';

/// 필터 조절 패널
///
/// React FilterPanel 컴포넌트를 Flutter로 변환
/// 선택된 클립의 필터(밝기, 대비, 채도, 온도) 조절
class FilterPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const FilterPanel({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _temperature = 0;
  FilterPresetType? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final selectedClip = ref.read(timelineProvider).selectedClip;
    if (selectedClip != null && selectedClip.track == TrackType.filter) {
      _brightness = selectedClip.filterBrightness;
      _contrast = selectedClip.filterContrast;
      _saturation = selectedClip.filterSaturation;
      _temperature = selectedClip.filterTemperature;
      _selectedPreset = selectedClip.filterPreset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                  '필터 조절',
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
          ),

          const SizedBox(height: 16),

          // 프리셋 선택
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: FilterPresetType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = FilterPresetType.values[index];
                final isSelected = _selectedPreset == preset;

                return ChoiceChip(
                  label: Text(preset.label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedPreset = preset;
                      _applyPreset(preset);
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 슬라이더들
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSlider(
                    label: '밝기',
                    value: _brightness,
                    icon: Icons.brightness_6,
                    onChanged: (v) => setState(() => _brightness = v),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: '대비',
                    value: _contrast,
                    icon: Icons.contrast,
                    onChanged: (v) => setState(() => _contrast = v),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: '채도',
                    value: _saturation,
                    icon: Icons.color_lens,
                    onChanged: (v) => setState(() => _saturation = v),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: '온도',
                    value: _temperature,
                    icon: Icons.thermostat,
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                ],
              ),
            ),
          ),

          // 비디오 없음 경고
          if (videoBounds == null)
            Container(
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
            ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetValues,
                    child: const Text('초기화'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: videoBounds != null ? _applyFilter : null,
                    child: const Text('적용'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: -100,
          max: 100,
          divisions: 200,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _applyPreset(FilterPresetType preset) {
    switch (preset) {
      case FilterPresetType.none:
        _brightness = 0;
        _contrast = 0;
        _saturation = 0;
        _temperature = 0;
        break;
      case FilterPresetType.vivid:
        _brightness = 10;
        _contrast = 20;
        _saturation = 30;
        _temperature = 0;
        break;
      case FilterPresetType.warm:
        _brightness = 5;
        _contrast = 5;
        _saturation = 10;
        _temperature = 40;
        break;
      case FilterPresetType.cool:
        _brightness = 0;
        _contrast = 10;
        _saturation = -10;
        _temperature = -40;
        break;
      case FilterPresetType.vintage:
        _brightness = -5;
        _contrast = 15;
        _saturation = -20;
        _temperature = 20;
        break;
      case FilterPresetType.bw:
        _brightness = 5;
        _contrast = 25;
        _saturation = -100;
        _temperature = 0;
        break;
      case FilterPresetType.cinema:
        _brightness = -10;
        _contrast = 30;
        _saturation = -10;
        _temperature = -10;
        break;
    }
    setState(() {});
  }

  void _resetValues() {
    setState(() {
      _brightness = 0;
      _contrast = 0;
      _saturation = 0;
      _temperature = 0;
      _selectedPreset = FilterPresetType.none;
    });
  }

  void _applyFilter() {
    final timelineState = ref.read(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    if (videoBounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 영상 클립을 추가하세요.')),
      );
      return;
    }

    // 기존 필터 클립이 있는지 확인
    final existingFilter = timelineState.clips
        .where((c) => c.track == TrackType.filter)
        .toList();

    if (existingFilter.isNotEmpty) {
      // 기존 필터 업데이트
      ref.read(timelineProvider.notifier).updateClip(
        existingFilter.first.id,
        existingFilter.first.copyWith(
          filterBrightness: _brightness,
          filterContrast: _contrast,
          filterSaturation: _saturation,
          filterTemperature: _temperature,
          filterPreset: _selectedPreset,
        ),
      );
    } else {
      // 새 필터 클립 추가
      final clip = TimelineClip(
        id: 'filter-${DateTime.now().millisecondsSinceEpoch}',
        clipId: 'filter-${DateTime.now().millisecondsSinceEpoch}',
        track: TrackType.filter,
        position: videoBounds.$1,
        duration: videoBounds.$2 - videoBounds.$1,
        filterBrightness: _brightness,
        filterContrast: _contrast,
        filterSaturation: _saturation,
        filterTemperature: _temperature,
        filterPreset: _selectedPreset,
      );

      ref.read(timelineProvider.notifier).addClip(clip);
    }

    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('필터가 적용되었습니다.')),
    );
  }
}

/// FilterPanel을 BottomSheet으로 표시하는 유틸리티 함수
void showFilterPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const FilterPanel(),
  );
}
