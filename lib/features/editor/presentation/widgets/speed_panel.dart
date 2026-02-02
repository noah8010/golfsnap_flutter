import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';

/// 속도 조절 패널
///
/// React SpeedPanel 컴포넌트를 Flutter로 변환
/// 선택된 비디오 클립의 재생 속도를 조절
class SpeedPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const SpeedPanel({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<SpeedPanel> createState() => _SpeedPanelState();
}

class _SpeedPanelState extends ConsumerState<SpeedPanel> {
  late double _speed;

  // 프리셋 속도 값
  static const List<double> _speedPresets = [0.25, 0.5, 1.0, 1.5, 2.0, 4.0];

  @override
  void initState() {
    super.initState();
    final selectedClip = ref.read(timelineProvider).selectedClip;
    _speed = selectedClip?.speed ?? TimelineConfig.speedDefault;
  }

  @override
  Widget build(BuildContext context) {
    final selectedClip = ref.watch(timelineProvider).selectedClip;

    if (selectedClip == null || selectedClip.track != TrackType.video) {
      return _buildNoSelectionMessage();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '속도 조절',
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

          const SizedBox(height: 24),

          // 현재 속도 표시
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_speed.toStringAsFixed(2)}x',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 슬라이더
          Row(
            children: [
              Text(
                '${TimelineConfig.speedMin}x',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Expanded(
                child: Slider(
                  value: _speed,
                  min: TimelineConfig.speedMin,
                  max: TimelineConfig.speedMax,
                  divisions: ((TimelineConfig.speedMax - TimelineConfig.speedMin) /
                      TimelineConfig.speedStep)
                      .round(),
                  onChanged: (value) {
                    setState(() => _speed = value);
                  },
                  onChangeEnd: (value) {
                    _applySpeed(selectedClip.id, value);
                  },
                ),
              ),
              Text(
                '${TimelineConfig.speedMax}x',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 프리셋 버튼
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _speedPresets.map((preset) {
              final isSelected = (_speed - preset).abs() < 0.01;
              return ChoiceChip(
                label: Text('${preset}x'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _speed = preset);
                  _applySpeed(selectedClip.id, preset);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 적용 버튼
          ElevatedButton(
            onPressed: () {
              _applySpeed(selectedClip.id, _speed);

              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.speed,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '영상 클립을 선택하세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _applySpeed(String clipId, double speed) {
    ref.read(timelineProvider.notifier).updateClipSpeed(clipId, speed);
  }
}

/// SpeedPanel을 BottomSheet으로 표시하는 유틸리티 함수
void showSpeedPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const SpeedPanel(),
    ),
  );
}
