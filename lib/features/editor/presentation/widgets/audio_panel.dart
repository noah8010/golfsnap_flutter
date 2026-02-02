import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/timeline_clip.dart';

/// BGM 목록 (예시 데이터)
class BgmLibrary {
  BgmLibrary._();

  static const List<BgmItem> items = [
    BgmItem(id: 'bgm-1', name: 'Upbeat Golf', volume: 80),
    BgmItem(id: 'bgm-2', name: 'Chill Vibes', volume: 80),
    BgmItem(id: 'bgm-3', name: 'Energetic Sports', volume: 80),
    BgmItem(id: 'bgm-4', name: 'Relaxing Nature', volume: 80),
    BgmItem(id: 'bgm-5', name: 'Epic Moments', volume: 80),
    BgmItem(id: 'bgm-6', name: 'Acoustic Guitar', volume: 80),
  ];
}

/// 오디오/BGM 패널
///
/// React AudioPanel 컴포넌트를 Flutter로 변환
/// BGM 선택 및 볼륨 조절
class AudioPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const AudioPanel({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<AudioPanel> createState() => _AudioPanelState();
}

class _AudioPanelState extends ConsumerState<AudioPanel> {
  BgmItem? _selectedBgm;
  double _volume = 80;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final clips = ref.read(timelineProvider).clips;
    final audioClip = clips.where((c) => c.track == TrackType.audio).firstOrNull;
    if (audioClip != null) {
      _selectedBgm = audioClip.audioBgm;
      _volume = audioClip.audioVolume;
      _isMuted = audioClip.audioMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final videoBounds = timelineState.videoBounds;

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
                  '배경음악',
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

          // 볼륨 컨트롤
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: _isMuted ? AppColors.gray400 : AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _isMuted ? 0 : _volume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: _isMuted
                        ? null
                        : (v) => setState(() => _volume = v),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${_volume.toInt()}%',
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // BGM 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: BgmLibrary.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final bgm = BgmLibrary.items[index];
                final isSelected = _selectedBgm?.id == bgm.id;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.gray50,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.gray200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: isSelected ? Colors.white : AppColors.gray500,
                    ),
                  ),
                  title: Text(
                    bgm.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedBgm = _selectedBgm?.id == bgm.id ? null : bgm;
                    });
                  },
                );
              },
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
            child: ElevatedButton(
              onPressed: videoBounds != null ? _applyBgm : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _selectedBgm != null ? '${_selectedBgm!.name} 적용' : 'BGM 선택',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyBgm() {
    final timelineState = ref.read(timelineProvider);
    final videoBounds = timelineState.videoBounds;

    if (videoBounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 영상 클립을 추가하세요.')),
      );
      return;
    }

    // 기존 오디오 클립 제거
    final existingAudio = timelineState.clips
        .where((c) => c.track == TrackType.audio)
        .toList();
    for (final clip in existingAudio) {
      ref.read(timelineProvider.notifier).deleteClip(clip.id);
    }

    // 새 오디오 클립 추가
    if (_selectedBgm != null) {
      final clip = TimelineClip(
        id: 'audio-${DateTime.now().millisecondsSinceEpoch}',
        clipId: _selectedBgm!.id,
        track: TrackType.audio,
        position: videoBounds.$1,
        duration: videoBounds.$2 - videoBounds.$1,
        audioBgm: _selectedBgm!.copyWith(volume: _volume),
        audioVolume: _volume,
        audioMuted: _isMuted,
      );

      ref.read(timelineProvider.notifier).addClip(clip);
    }

    widget.onClose?.call() ?? Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedBgm != null
              ? '${_selectedBgm!.name} BGM이 추가되었습니다.'
              : 'BGM이 제거되었습니다.',
        ),
      ),
    );
  }
}

/// AudioPanel을 BottomSheet으로 표시하는 유틸리티 함수
void showAudioPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AudioPanel(),
  );
}
