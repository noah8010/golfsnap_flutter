import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/timeline_provider.dart';
import '../../domain/models/timeline_clip.dart';

/// 텍스트 설정 모델
class TextSettings {
  final String content;
  final String font;
  final double fontSize;
  final Color color;
  final TextAlign align;
  final bool bold;
  final bool italic;
  final bool underline;
  final TextAnimationType animation;
  final Offset position; // 0-100 퍼센트

  const TextSettings({
    this.content = '',
    this.font = 'noto-sans',
    this.fontSize = 32,
    this.color = Colors.white,
    this.align = TextAlign.center,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.animation = TextAnimationType.fadeIn,
    this.position = const Offset(50, 50),
  });

  TextSettings copyWith({
    String? content,
    String? font,
    double? fontSize,
    Color? color,
    TextAlign? align,
    bool? bold,
    bool? italic,
    bool? underline,
    TextAnimationType? animation,
    Offset? position,
  }) {
    return TextSettings(
      content: content ?? this.content,
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      align: align ?? this.align,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      animation: animation ?? this.animation,
      position: position ?? this.position,
    );
  }
}

/// 폰트 목록
class FontOption {
  final String id;
  final String name;
  final String preview;

  const FontOption({
    required this.id,
    required this.name,
    required this.preview,
  });
}

const List<FontOption> fonts = [
  FontOption(id: 'noto-sans', name: 'Noto Sans', preview: 'Aa'),
  FontOption(id: 'nanum-gothic', name: '나눔고딕', preview: '가나'),
  FontOption(id: 'nanum-myeongjo', name: '나눔명조', preview: '가나'),
  FontOption(id: 'roboto', name: 'Roboto', preview: 'Aa'),
  FontOption(id: 'montserrat', name: 'Montserrat', preview: 'Aa'),
  FontOption(id: 'playfair', name: 'Playfair', preview: 'Aa'),
];

/// 색상 프리셋
const List<Color> colorPresets = [
  Color(0xFFFFFFFF), // White
  Color(0xFF000000), // Black
  Color(0xFFFF0000), // Red
  Color(0xFF00FF00), // Green
  Color(0xFF0000FF), // Blue
  Color(0xFFFFFF00), // Yellow
  Color(0xFFFF00FF), // Magenta
  Color(0xFF00FFFF), // Cyan
  Color(0xFFFFA500), // Orange
  Color(0xFF800080), // Purple
];

/// 텍스트 패널
///
/// React TextPanel 컴포넌트를 Flutter로 변환
/// 풀스크린 오버레이 형태의 텍스트 편집 UI
class TextPanel extends ConsumerStatefulWidget {
  final TextSettings? initialSettings;
  final VoidCallback? onClose;
  final Function(TextSettings)? onAdd;

  const TextPanel({
    super.key,
    this.initialSettings,
    this.onClose,
    this.onAdd,
  });

  @override
  ConsumerState<TextPanel> createState() => _TextPanelState();
}

class _TextPanelState extends ConsumerState<TextPanel>
    with SingleTickerProviderStateMixin {
  late TextSettings _settings;
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings ?? const TextSettings();
    _textController.text = _settings.content;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_textController.text.trim().isEmpty) return;

    final finalSettings = _settings.copyWith(content: _textController.text);
    widget.onAdd?.call(finalSettings);
    widget.onClose?.call() ?? Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2c3441),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Text Input
                  _buildTextInput(),
                  const SizedBox(height: 24),

                  // Tabs
                  _buildTabs(),
                  const SizedBox(height: 24),

                  // Tab Content
                  _buildTabContent(),
                ],
              ),
            ),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF4a5568))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '텍스트 추가',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      maxLines: 4,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: '텍스트를 입력하세요',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFF3d4554),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4a5568)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4a5568)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _settings = _settings.copyWith(content: value);
        });
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: '스타일'),
          Tab(text: '애니메이션'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        if (_tabController.index == 0) {
          return _buildStyleTab();
        } else {
          return _buildAnimationTab();
        }
      },
    );
  }

  Widget _buildStyleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font Selection
        _buildSectionHeader('폰트'),
        const SizedBox(height: 12),
        _buildFontGrid(),
        const SizedBox(height: 24),

        // Font Size
        _buildSectionHeader('크기', value: '${_settings.fontSize.toInt()}px'),
        const SizedBox(height: 12),
        _buildFontSizeSlider(),
        const SizedBox(height: 24),

        // Text Align
        _buildSectionHeader('정렬'),
        const SizedBox(height: 12),
        _buildAlignButtons(),
        const SizedBox(height: 24),

        // Text Style
        _buildSectionHeader('스타일'),
        const SizedBox(height: 12),
        _buildStyleButtons(),
        const SizedBox(height: 24),

        // Color
        _buildSectionHeader('색상'),
        const SizedBox(height: 12),
        _buildColorGrid(),
      ],
    );
  }

  Widget _buildAnimationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('등장 효과'),
        const SizedBox(height: 12),
        _buildAnimationGrid(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        if (value != null)
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildFontGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: fonts.length,
      itemBuilder: (context, index) {
        final font = fonts[index];
        final isSelected = _settings.font == font.id;

        return GestureDetector(
          onTap: () => setState(() => _settings = _settings.copyWith(font: font.id)),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFF3d4554),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  font.preview,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  font.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSizeSlider() {
    return Slider(
      value: _settings.fontSize,
      min: 16,
      max: 72,
      divisions: 28,
      activeColor: AppColors.primary,
      inactiveColor: const Color(0xFF3d4554),
      onChanged: (value) {
        setState(() => _settings = _settings.copyWith(fontSize: value));
      },
    );
  }

  Widget _buildAlignButtons() {
    return Row(
      children: [
        _buildAlignButton(TextAlign.left, Icons.format_align_left),
        const SizedBox(width: 8),
        _buildAlignButton(TextAlign.center, Icons.format_align_center),
        const SizedBox(width: 8),
        _buildAlignButton(TextAlign.right, Icons.format_align_right),
      ],
    );
  }

  Widget _buildAlignButton(TextAlign align, IconData icon) {
    final isSelected = _settings.align == align;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _settings = _settings.copyWith(align: align)),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFF3d4554),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButtons() {
    return Row(
      children: [
        _buildStyleButton('B', _settings.bold, () {
          setState(() => _settings = _settings.copyWith(bold: !_settings.bold));
        }),
        const SizedBox(width: 8),
        _buildStyleButton('I', _settings.italic, () {
          setState(() => _settings = _settings.copyWith(italic: !_settings.italic));
        }, italic: true),
        const SizedBox(width: 8),
        _buildStyleButton('U', _settings.underline, () {
          setState(() => _settings = _settings.copyWith(underline: !_settings.underline));
        }, underline: true),
      ],
    );
  }

  Widget _buildStyleButton(String label, bool isActive, VoidCallback onTap,
      {bool italic = false, bool underline = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFF3d4554),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                decoration: underline ? TextDecoration.underline : TextDecoration.none,
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: colorPresets.length,
      itemBuilder: (context, index) {
        final color = colorPresets[index];
        final isSelected = _settings.color == color;

        return GestureDetector(
          onTap: () => setState(() => _settings = _settings.copyWith(color: color)),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : const Color(0xFF4a5568),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color == Colors.white ? Colors.black : Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildAnimationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: TextAnimationType.values.length,
      itemBuilder: (context, index) {
        final animation = TextAnimationType.values[index];
        final isSelected = _settings.animation == animation;

        return GestureDetector(
          onTap: () => setState(() => _settings = _settings.copyWith(animation: animation)),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFF3d4554),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                animation.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF4a5568))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onClose ?? () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3d4554),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('취소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _textController.text.trim().isEmpty ? null : _handleAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: Text(
                widget.initialSettings != null ? '수정' : '추가',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// TextPanel을 풀스크린으로 표시하는 유틸리티 함수
void showTextPanel(
  BuildContext context, {
  TextSettings? initialSettings,
  Function(TextSettings)? onAdd,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TextPanel(
        initialSettings: initialSettings,
        onAdd: onAdd,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.black54,
    ),
  );
}
