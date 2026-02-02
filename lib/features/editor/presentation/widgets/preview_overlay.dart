import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/timeline_clip.dart';

/// 미리보기 오버레이 위젯
///
/// 비디오 미리보기 위에 텍스트/스티커를 렌더링
/// React PreviewOverlay 컴포넌트를 Flutter로 변환
class PreviewOverlay extends ConsumerWidget {
  final double currentTime;
  final Size previewSize;

  const PreviewOverlay({
    super.key,
    required this.currentTime,
    required this.previewSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(timelineProvider);
    final clips = timelineState.clips;

    // 현재 시간에 활성화된 클립들 필터링
    final activeTextClips = clips.where((clip) =>
        clip.track == TrackType.text &&
        clip.position <= currentTime &&
        clip.endPosition > currentTime);

    final activeStickerClips = clips.where((clip) =>
        clip.track == TrackType.sticker &&
        clip.position <= currentTime &&
        clip.endPosition > currentTime);

    return Stack(
      children: [
        // 텍스트 오버레이들
        ...activeTextClips.map((clip) => _TextOverlayItem(
          key: ValueKey('text-${clip.id}'),
          clip: clip,
          previewSize: previewSize,
        )),

        // 스티커 오버레이들
        ...activeStickerClips.map((clip) => _StickerOverlayItem(
          key: ValueKey('sticker-${clip.id}'),
          clip: clip,
          previewSize: previewSize,
        )),
      ],
    );
  }
}

/// 텍스트 오버레이 아이템
class _TextOverlayItem extends ConsumerStatefulWidget {
  final TimelineClip clip;
  final Size previewSize;

  const _TextOverlayItem({
    super.key,
    required this.clip,
    required this.previewSize,
  });

  @override
  ConsumerState<_TextOverlayItem> createState() => _TextOverlayItemState();
}

class _TextOverlayItemState extends ConsumerState<_TextOverlayItem> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final clip = widget.clip;
    final position = _dragOffset ?? clip.textPosition ?? const Offset(50, 50);

    // 백분율 위치를 실제 픽셀로 변환
    final left = (position.dx / 100) * widget.previewSize.width;
    final top = (position.dy / 100) * widget.previewSize.height;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = ((left + details.delta.dx) / widget.previewSize.width * 100)
                .clamp(0.0, 100.0);
            final newY = ((top + details.delta.dy) / widget.previewSize.height * 100)
                .clamp(0.0, 100.0);
            _dragOffset = Offset(newX, newY);
          });
        },
        onPanEnd: (_) {
          if (_dragOffset != null) {
            ref.read(timelineProvider.notifier).updateClip(
              clip.id,
              clip.copyWith(textPosition: _dragOffset),
            );
          }
        },
        child: _buildTextWidget(clip),
      ),
    );
  }

  Widget _buildTextWidget(TimelineClip clip) {
    final isSelected = ref.watch(timelineProvider).selectedClipId == clip.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Text(
        clip.textContent ?? '텍스트',
        style: TextStyle(
          color: clip.textColor ?? Colors.white,
          fontSize: clip.textFontSize ?? 24,
          fontWeight: clip.textBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: clip.textItalic ? FontStyle.italic : FontStyle.normal,
          decoration: clip.textUnderline ? TextDecoration.underline : null,
        ),
        textAlign: clip.textAlign ?? TextAlign.center,
      ),
    );
  }
}

/// 스티커 오버레이 아이템
class _StickerOverlayItem extends ConsumerStatefulWidget {
  final TimelineClip clip;
  final Size previewSize;

  const _StickerOverlayItem({
    super.key,
    required this.clip,
    required this.previewSize,
  });

  @override
  ConsumerState<_StickerOverlayItem> createState() => _StickerOverlayItemState();
}

class _StickerOverlayItemState extends ConsumerState<_StickerOverlayItem>
    with SingleTickerProviderStateMixin {
  Offset? _dragOffset;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    final animation = widget.clip.stickerAnimation;
    if (animation != null && animation != StickerAnimationType.sparkle) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clip = widget.clip;
    final position = _dragOffset ?? clip.stickerPosition ?? const Offset(50, 50);

    // 백분율 위치를 실제 픽셀로 변환
    final left = (position.dx / 100) * widget.previewSize.width;
    final top = (position.dy / 100) * widget.previewSize.height;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = ((left + details.delta.dx) / widget.previewSize.width * 100)
                .clamp(0.0, 100.0);
            final newY = ((top + details.delta.dy) / widget.previewSize.height * 100)
                .clamp(0.0, 100.0);
            _dragOffset = Offset(newX, newY);
          });
        },
        onPanEnd: (_) {
          if (_dragOffset != null) {
            ref.read(timelineProvider.notifier).updateClip(
              clip.id,
              clip.copyWith(stickerPosition: _dragOffset),
            );
          }
        },
        child: _buildAnimatedSticker(clip),
      ),
    );
  }

  Widget _buildAnimatedSticker(TimelineClip clip) {
    final isSelected = ref.watch(timelineProvider).selectedClipId == clip.id;
    final scale = clip.stickerScale;

    Widget stickerWidget = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Text(
        clip.stickerEmoji ?? '⭐',
        style: TextStyle(fontSize: 48 * scale),
      ),
    );

    // 애니메이션 적용
    final animation = clip.stickerAnimation;
    if (animation != null) {
      switch (animation) {
        case StickerAnimationType.bounce:
          stickerWidget = AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -10 * _animationController.value),
                child: child,
              );
            },
            child: stickerWidget,
          );
          break;
        case StickerAnimationType.pulse:
          stickerWidget = AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.1 * _animationController.value,
                child: child,
              );
            },
            child: stickerWidget,
          );
          break;
        case StickerAnimationType.shake:
          stickerWidget = AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: 0.1 * (0.5 - _animationController.value),
                child: child,
              );
            },
            child: stickerWidget,
          );
          break;
        case StickerAnimationType.spin:
          stickerWidget = AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * 3.14159,
                child: child,
              );
            },
            child: stickerWidget,
          );
          break;
        default:
          break;
      }
    }

    return stickerWidget;
  }
}
