import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// 선택된 화면 비율 Provider
final selectedAspectRatioProvider = StateProvider<AspectRatioType?>((ref) => null);

/// 화면 비율 선택 화면
class AspectRatioScreen extends ConsumerWidget {
  const AspectRatioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRatio = ref.watch(selectedAspectRatioProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '화면 비율 선택',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로젝트에 사용할 화면 비율을 선택하세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Aspect Ratio Options
                    ...AspectRatioType.values.map((ratio) {
                      final isSelected = selectedRatio == ratio;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AspectRatioOption(
                          ratio: ratio,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(selectedAspectRatioProvider.notifier).state = ratio;
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedRatio == null
                        ? null
                        : () {
                            context.push('/new-project/media-selection');
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: const Text('다음'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 화면 비율 옵션 위젯
class _AspectRatioOption extends StatelessWidget {
  final AspectRatioType ratio;
  final bool isSelected;
  final VoidCallback onTap;

  const _AspectRatioOption({
    required this.ratio,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.gray200,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icon
              _RatioIcon(ratio: ratio, isSelected: isSelected),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ratio.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ratio.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Check Icon
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 비율 아이콘 위젯
class _RatioIcon extends StatelessWidget {
  final AspectRatioType ratio;
  final bool isSelected;

  const _RatioIcon({
    required this.ratio,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.secondary : AppColors.gray400;

    switch (ratio) {
      case AspectRatioType.landscape:
        return Container(
          width: 80,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AspectRatioType.portrait:
        return Container(
          width: 48,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AspectRatioType.square:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}
