import 'timeline_clip.dart';

/// 스티커 카테고리
enum StickerCategory {
  golf('골프'),
  celebration('축하'),
  emotion('감정'),
  effect('효과');

  final String label;
  const StickerCategory(this.label);
}

/// 스티커 아이템 모델
///
/// 사용 가능한 스티커 목록을 정의하는 모델
class StickerItem {
  final String id;
  final String name;
  final String emoji;
  final StickerAnimationType animation;
  final StickerCategory category;

  const StickerItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.animation,
    required this.category,
  });

  StickerItem copyWith({
    String? id,
    String? name,
    String? emoji,
    StickerAnimationType? animation,
    StickerCategory? category,
  }) {
    return StickerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      animation: animation ?? this.animation,
      category: category ?? this.category,
    );
  }
}

/// 기본 제공 스티커 목록
class DefaultStickers {
  DefaultStickers._();

  static const List<StickerItem> all = [
    // 골프 카테고리
    StickerItem(
      id: 'golf-1',
      name: '골프공',
      emoji: '⛳',
      animation: StickerAnimationType.bounce,
      category: StickerCategory.golf,
    ),
    StickerItem(
      id: 'golf-2',
      name: '골프채',
      emoji: '🏌️',
      animation: StickerAnimationType.spin,
      category: StickerCategory.golf,
    ),
    StickerItem(
      id: 'golf-3',
      name: '트로피',
      emoji: '🏆',
      animation: StickerAnimationType.sparkle,
      category: StickerCategory.golf,
    ),

    // 축하 카테고리
    StickerItem(
      id: 'celebration-1',
      name: '박수',
      emoji: '👏',
      animation: StickerAnimationType.pulse,
      category: StickerCategory.celebration,
    ),
    StickerItem(
      id: 'celebration-2',
      name: '폭죽',
      emoji: '🎉',
      animation: StickerAnimationType.explode,
      category: StickerCategory.celebration,
    ),
    StickerItem(
      id: 'celebration-3',
      name: '별',
      emoji: '⭐',
      animation: StickerAnimationType.sparkle,
      category: StickerCategory.celebration,
    ),
    StickerItem(
      id: 'celebration-4',
      name: '엄지척',
      emoji: '👍',
      animation: StickerAnimationType.bounce,
      category: StickerCategory.celebration,
    ),

    // 감정 카테고리
    StickerItem(
      id: 'emotion-1',
      name: '웃음',
      emoji: '😄',
      animation: StickerAnimationType.bounce,
      category: StickerCategory.emotion,
    ),
    StickerItem(
      id: 'emotion-2',
      name: '놀람',
      emoji: '😮',
      animation: StickerAnimationType.shake,
      category: StickerCategory.emotion,
    ),
    StickerItem(
      id: 'emotion-3',
      name: '화남',
      emoji: '😤',
      animation: StickerAnimationType.shake,
      category: StickerCategory.emotion,
    ),
    StickerItem(
      id: 'emotion-4',
      name: '사랑',
      emoji: '❤️',
      animation: StickerAnimationType.pulse,
      category: StickerCategory.emotion,
    ),

    // 효과 카테고리
    StickerItem(
      id: 'effect-1',
      name: '불꽃',
      emoji: '🔥',
      animation: StickerAnimationType.float,
      category: StickerCategory.effect,
    ),
    StickerItem(
      id: 'effect-2',
      name: '번개',
      emoji: '⚡',
      animation: StickerAnimationType.sparkle,
      category: StickerCategory.effect,
    ),
    StickerItem(
      id: 'effect-3',
      name: '100점',
      emoji: '💯',
      animation: StickerAnimationType.zoomIn,
      category: StickerCategory.effect,
    ),
    StickerItem(
      id: 'effect-4',
      name: '폭발',
      emoji: '💥',
      animation: StickerAnimationType.explode,
      category: StickerCategory.effect,
    ),
  ];

  /// 카테고리별 스티커 필터링
  static List<StickerItem> byCategory(StickerCategory category) {
    return all.where((s) => s.category == category).toList();
  }

  /// ID로 스티커 찾기
  static StickerItem? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
