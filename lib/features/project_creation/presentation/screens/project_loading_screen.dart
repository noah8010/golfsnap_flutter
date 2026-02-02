import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/providers/app_state_provider.dart';
import '../../../media_selection/domain/models/media_item.dart';
import '../../../media_selection/presentation/screens/media_selection_screen.dart';
import 'aspect_ratio_screen.dart';

/// 로딩 단계
enum LoadingStep {
  analyzing,
  generating,
  subtitles,
  stickers,
  complete,
}

/// 프로젝트 로딩 화면 (Step 3)
///
/// 타임라인 생성 시뮬레이션을 표시하고 완료 후 에디터로 이동합니다.
class ProjectLoadingScreen extends ConsumerStatefulWidget {
  const ProjectLoadingScreen({super.key});

  @override
  ConsumerState<ProjectLoadingScreen> createState() => _ProjectLoadingScreenState();
}

class _ProjectLoadingScreenState extends ConsumerState<ProjectLoadingScreen> {
  LoadingStep _currentStep = LoadingStep.analyzing;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final steps = [
      (step: LoadingStep.analyzing, duration: 1000, progress: 20.0),
      (step: LoadingStep.generating, duration: 1500, progress: 50.0),
      (step: LoadingStep.subtitles, duration: 1200, progress: 75.0),
      (step: LoadingStep.stickers, duration: 1000, progress: 95.0),
      (step: LoadingStep.complete, duration: 500, progress: 100.0),
    ];

    for (final stepInfo in steps) {
      if (!mounted) return;

      setState(() {
        _currentStep = stepInfo.step;
      });

      // Animate progress
      final targetProgress = stepInfo.progress;
      final duration = stepInfo.duration;
      const frameCount = 20;
      final frameDelay = duration ~/ frameCount;
      final progressIncrement = (targetProgress - _progress) / frameCount;

      for (int i = 0; i < frameCount; i++) {
        if (!mounted) return;
        await Future.delayed(Duration(milliseconds: frameDelay));
        setState(() {
          _progress = (_progress + progressIncrement).clamp(0.0, 100.0);
        });
      }
    }

    // 완료 후 잠시 대기 후 에디터로 이동
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _onComplete();
    }
  }

  void _onComplete() {
    // 프로젝트 생성
    final aspectRatio = ref.read(selectedAspectRatioProvider);
    final selectedMedia = ref.read(selectedMediaProvider);

    if (aspectRatio != null && selectedMedia.isNotEmpty) {
      ref.read(appStateProvider.notifier).createNewProject(
        aspectRatio: aspectRatio,
        selectedMedia: selectedMedia,
      );
    }

    // 에디터로 이동
    context.go('/editor');
  }

  String _getStepMessage() {
    switch (_currentStep) {
      case LoadingStep.analyzing:
        return '미디어 분석 중...';
      case LoadingStep.generating:
        return '타임라인 생성 중...';
      case LoadingStep.subtitles:
        return '자동 자막 생성 중...';
      case LoadingStep.stickers:
        return '추천 스티커 배치 중...';
      case LoadingStep.complete:
        return '완료!';
    }
  }

  Widget _getStepIcon() {
    switch (_currentStep) {
      case LoadingStep.subtitles:
        return const Icon(Icons.text_fields, size: 48, color: AppColors.primary);
      case LoadingStep.stickers:
        return const Icon(Icons.emoji_emotions, size: 48, color: AppColors.primary);
      case LoadingStep.complete:
        return const Icon(Icons.auto_awesome, size: 48, color: AppColors.primary);
      default:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = ref.watch(selectedAspectRatioProvider);
    final selectedMedia = ref.watch(selectedMediaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey(_currentStep),
                  child: _getStepIcon(),
                ),
              ),
              const SizedBox(height: 32),

              // Message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getStepMessage(),
                  key: ValueKey(_currentStep.toString() + '-text'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Details
              Text(
                '${selectedMedia.length}개의 미디어로 ${aspectRatio?.label ?? ''} 프로젝트를 생성하고 있습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Progress Bar
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.gray200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '진행률',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_progress.toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Feature List
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _FeatureItem(
                      label: '미디어 분석',
                      isDone: _progress >= 20,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      label: '타임라인 생성',
                      isDone: _progress >= 50,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      label: '자동 자막 생성',
                      isDone: _progress >= 75,
                    ),
                    const SizedBox(height: 12),
                    _FeatureItem(
                      label: '추천 스티커 배치',
                      isDone: _progress >= 95,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 기능 항목 위젯
class _FeatureItem extends StatelessWidget {
  final String label;
  final bool isDone;

  const _FeatureItem({
    required this.label,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.gray200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: isDone ? AppColors.textPrimary : AppColors.gray400,
            fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
