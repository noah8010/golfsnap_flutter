# 🎬 GolfSnap Flutter - 인수인계 문서

> **작성일**: 2026-02-02
> **프로젝트 성격**: UI/UX 검증용 인터랙티브 프로토타입
> **완성도**: ~85% (프로토타입 범위 기준)

---

## 📋 목차

1. [프로젝트 개요](#-프로젝트-개요)
2. [프로토타입 범위](#-프로토타입-범위)
3. [구현 완료된 기능](#-구현-완료된-기능)
4. [아키텍처](#-아키텍처)
5. [핵심 파일 가이드](#-핵심-파일-가이드)
6. [시작하기](#-시작하기)
7. [다음 개발자를 위한 팁](#-다음-개발자를-위한-팁)

---

## 🎯 프로젝트 개요

**GolfSnap Flutter**는 골프 영상 편집 앱의 Flutter 프로토타입입니다.

### 프로젝트 목적
React/TypeScript로 개발된 프로젝트를 Flutter로 변환하는 작업을 진행 중입니다.
**UI/UX 검증 및 기능 흐름 확인**을 목적으로 하는 인터랙티브 프로토타입입니다.

### 프로젝트 이력
- **기존 프로젝트**: `E:\flutter_projects\golfsnap_m` (React/TypeScript)
- **현재 프로젝트**: `E:\flutter_projects\golfsnap_flutter` (Flutter)
- **참고 프로토타입**: [golfsnap_00](https://github.com/noah8010/golfsnap_00) (React - GitHub)

### 기술 스택
- **Framework**: Flutter 3.x (SDK ^3.5.0)
- **상태 관리**: Riverpod (flutter_riverpod)
- **라우팅**: GoRouter
- **UI**: Material Design 3

### 배포
- **URL**: https://noah8010.github.io/golfsnap_flutter/
- **자동 배포**: GitHub Actions (main 브랜치 push 시)

---

## ⚠️ 프로토타입 범위

### ✅ **구현하는 것 (프로토타입 범위)**

이 프로젝트는 **"기능이 어떻게 동작하는지"와 "UI를 어떻게 조작하는지"를 눈으로 확인**할 수 있는 수준으로 구현합니다.

#### 1. UI/UX 검증
- 모든 화면 및 컴포넌트 UI
- 사용자 인터랙션 (탭, 드래그, 스크롤 등)
- 화면 전환 및 애니메이션
- 상태 변화 시각화

#### 2. 기능 시뮬레이션
- 타임라인 편집 (클립 조작, 트림, 분할 등)
- 속도 조절, 필터, 스티커 적용
- 내보내기 진행 상태
- 모든 편집 패널 인터랙션

#### 3. 상태 관리
- Riverpod 기반 상태 관리
- 클립 CRUD 로직
- 리플 편집 (Ripple Edit) 로직
- 비디오 범위 기반 클립 조정

### ❌ **구현하지 않는 것 (프로토타입 범위 밖)**

#### 1. 실제 비디오 렌더링
- FFmpeg 통합 ❌
- 실제 비디오 인코딩/디코딩 ❌
- 비디오 파일 저장 ❌

**→ 대신**: 내보내기 진행률 시뮬레이션 ([export_panel.dart:261-298](lib/features/editor/presentation/widgets/export_panel.dart#L261-L298))

#### 2. 실제 갤러리 연동
- photo_manager 통합 ❌
- 실제 디바이스 갤러리 접근 ❌
- 파일 시스템 읽기/쓰기 ❌

**→ 대신**: Mock 데이터 사용 ([pubspec.yaml:31](pubspec.yaml#L31) 참고)

#### 3. 실제 비디오 재생
- video_player 통합 ❌
- 실제 영상 재생 ❌
- 오디오 재생 ❌

**→ 대신**: 썸네일 표시 및 플레이 시뮬레이션

#### 4. 영구 저장
- 프로젝트 DB 저장 ❌
- 로컬 파일 저장 ❌

**→ 대신**: 메모리 상태만 유지 (새로고침 시 초기화)

---

## ✅ 구현 완료된 기능

### 1. 핵심 플로우 (100%)

#### 대시보드
- 프로젝트 목록 표시
- 새 프로젝트 생성
- 프로젝트 카드 UI

#### 화면 비율 선택
- 16:9 (가로/유튜브)
- 9:16 (세로/릴스)
- 1:1 (정사각형/인스타그램)

#### 미디어 선택
- 날짜별 그룹화 UI
- Mock 미디어 표시
- 다중 선택 (최대 20개)

#### 에디터 워크스페이스
- 5트랙 타임라인
- 프리뷰 영역
- 편집 패널
- 내보내기 UI

### 2. 타임라인 에디터 (90%)

#### 코어 시스템
- **[TimelineConfig](lib/core/constants/app_constants.dart#L44-L156)**: 타임라인 상수 체계화
  - 줌 설정 (0.5x ~ 3.0x, 0.25 단위)
  - 속도 설정 (0.1x ~ 8.0x, 0.1 단위)
  - 트랙 높이, 플레이헤드, 드래그 설정
  - 유틸리티 메서드 (`timeToPixels`, `pixelsToTime`)

#### 상태 관리
- **[TimelineProvider](lib/features/editor/data/providers/timeline_provider.dart)**: 661줄의 완전한 상태 관리
  - **클립 CRUD**: 생성, 읽기, 수정, 삭제
  - **클립 분할 (Split)**: 원본 영상 구간 계산 로직 포함
  - **속도 조절**: 리플 편집 자동 적용
  - **트림 (Trim)**: 시작점/끝점, 비디오/비비디오 구분 처리
  - **클립 이동**: 비디오는 순서 재배치, 비비디오는 범위 제한
  - **리플 편집 (Ripple Edit)**: 뒤 클립들 자동 이동
  - **비디오 범위 기반 조정**: 텍스트/오디오/필터/스티커 자동 범위 제한

#### 데이터 모델
- **[TimelineClip](lib/features/editor/domain/models/timeline_clip.dart)**: 5개 트랙 완전 지원
  ```dart
  // 영상 트랙
  speed, volume, startTime, endTime (트림 구간)

  // 텍스트 트랙
  textContent, textFont, textFontSize, textColor,
  textAlign, textBold, textItalic, textUnderline,
  textAnimation, textPosition

  // 오디오 트랙
  audioVolume, audioMuted, audioBgm

  // 필터 트랙
  filterBrightness, filterContrast, filterSaturation,
  filterTemperature, filterPreset

  // 스티커 트랙
  stickerId, stickerName, stickerEmoji,
  stickerAnimation, stickerScale, stickerPosition
  ```

- **[StickerItem](lib/features/editor/domain/models/sticker_item.dart)**: 16개 기본 스티커
  - 골프: ⛳ 🏌️ 🏆
  - 축하: 👏 🎉 ⭐ 👍
  - 감정: 😄 😮 😤 ❤️
  - 효과: 🔥 ⚡ 💯 💥

### 3. 에디터 UI 위젯 (100%)

#### 타임라인 위젯 (6개)
- **[TimeRulerWidget](lib/features/editor/presentation/widgets/time_ruler_widget.dart)**: 시간 눈금자
- **[TrackLabelWidget](lib/features/editor/presentation/widgets/track_label_widget.dart)**: 트랙 레이블 (5개)
- **[PlayheadWidget](lib/features/editor/presentation/widgets/playhead_widget.dart)**: 센터 고정 플레이헤드
- **[TimelineTrackWidget](lib/features/editor/presentation/widgets/timeline_track_widget.dart)**: 트랙 컨테이너
- **[TimelineClipWidget](lib/features/editor/presentation/widgets/timeline_clip_widget.dart)**: 클립 렌더링
- **[TrimHandleWidget](lib/features/editor/presentation/widgets/trim_handle_widget.dart)**: 트림 핸들

#### 편집 패널 (6개)
- **[SpeedPanel](lib/features/editor/presentation/widgets/speed_panel.dart)**: 속도 조절 (0.1x ~ 8.0x)
- **[FilterPanel](lib/features/editor/presentation/widgets/filter_panel.dart)**: 밝기/대비/채도/온도 + 프리셋
- **[AudioPanel](lib/features/editor/presentation/widgets/audio_panel.dart)**: BGM 선택, 볼륨 조절
- **[StickerPanel](lib/features/editor/presentation/widgets/sticker_panel.dart)**: 16개 스티커 + 카테고리 필터
- **[PreviewOverlay](lib/features/editor/presentation/widgets/preview_overlay.dart)**: 텍스트/스티커 프리뷰
- **[ExportPanel](lib/features/editor/presentation/widgets/export_panel.dart)**: 내보내기 (시뮬레이션)
  - 품질 선택: 480p, 720p, 1080p, 4K
  - 진행률 표시
  - 완료 알림

### 4. 편집 기능

#### 클립 조작
- ✅ 클립 선택 (단일 선택)
- ✅ 클립 이동 (드래그)
  - 비디오: 순서 재배치 + 리플 편집
  - 비비디오: 비디오 범위 내 자유 이동
- ✅ 클립 트림 (시작점/끝점 핸들)
- ✅ 클립 분할 (플레이헤드 위치)
- ✅ 클립 복제
- ✅ 클립 삭제 (리플 편집)

#### 영상 편집
- ✅ 속도 조절 (0.1x ~ 8.0x, 0.1 단위)
- ✅ 필터 적용 (밝기/대비/채도/온도)
- ✅ 필터 프리셋 (선명/따뜻함/차가움/빈티지/흑백/시네마)

#### 텍스트/스티커
- ✅ 텍스트 추가/수정
- ✅ 스티커 추가 (16개 기본 제공)
- ✅ 프리뷰 오버레이 (위치 표시)

#### 오디오
- ✅ BGM 선택 (4개 기본 제공)
- ✅ 볼륨 조절

#### 재생 & 타임라인
- ✅ 줌 컨트롤 (0.5x ~ 3.0x)
- ✅ 센터 고정 플레이헤드
- ✅ 스크롤 기반 시간 네비게이션
- ✅ 시간 표시 (현재 시간 / 전체 길이)

#### 내보내기
- ✅ 품질 선택 UI (480p/720p/1080p/4K)
- ✅ 진행률 표시 (시뮬레이션)
- ❌ 실제 비디오 렌더링 (프로토타입 범위 밖)

---

## 🏗️ 아키텍처

### 프로젝트 구조

```
lib/
├── main.dart                                           # 앱 진입점
├── core/
│   ├── constants/
│   │   └── app_constants.dart                          # AppConstants, TimelineConfig
│   ├── theme/
│   │   ├── app_colors.dart                             # 색상 팔레트
│   │   └── app_theme.dart                              # ThemeData
│   └── router/
│       └── app_router.dart                             # GoRouter 라우트
└── features/
    ├── dashboard/                                      # 대시보드
    │   ├── data/providers/app_state_provider.dart      # 프로젝트 목록 상태
    │   ├── domain/models/project.dart                  # Project 모델
    │   └── presentation/screens/create_dashboard_screen.dart
    ├── project_creation/                               # 화면 비율 선택
    │   └── presentation/screens/aspect_ratio_screen.dart
    ├── media_selection/                                # 미디어 선택
    │   ├── domain/models/media_item.dart               # MediaItem 모델
    │   └── presentation/screens/media_selection_screen.dart
    └── editor/                                         # 에디터
        ├── data/providers/
        │   └── timeline_provider.dart                  # 타임라인 상태 관리 (661줄)
        ├── domain/models/
        │   ├── timeline_clip.dart                      # TimelineClip 모델 (302줄)
        │   └── sticker_item.dart                       # StickerItem 모델 (182줄)
        └── presentation/
            ├── screens/
            │   └── editor_workspace_screen.dart        # 메인 에디터 화면 (820줄)
            └── widgets/                                # 12개 위젯
                ├── timeline_clip_widget.dart           # 클립 렌더링
                ├── playhead_widget.dart                # 플레이헤드
                ├── time_ruler_widget.dart              # 시간 눈금자
                ├── track_label_widget.dart             # 트랙 레이블
                ├── timeline_track_widget.dart          # 트랙 컨테이너
                ├── trim_handle_widget.dart             # 트림 핸들
                ├── speed_panel.dart                    # 속도 패널
                ├── filter_panel.dart                   # 필터 패널
                ├── audio_panel.dart                    # 오디오 패널
                ├── sticker_panel.dart                  # 스티커 패널
                ├── preview_overlay.dart                # 프리뷰 오버레이
                └── export_panel.dart                   # 내보내기 패널
```

### 라우트

| 경로 | 화면 | 설명 |
|------|------|------|
| `/create` | CreateDashboardScreen | 대시보드 (메인) |
| `/new-project/aspect-ratio` | AspectRatioScreen | 화면 비율 선택 |
| `/new-project/media-selection` | MediaSelectionScreen | 미디어 선택 |
| `/editor` | EditorWorkspaceScreen | 에디터 |

### 주요 Provider

```dart
// 전역 상태
projectsProvider                    // 프로젝트 목록
currentProjectProvider              // 현재 프로젝트
selectedAspectRatioProvider         // 선택된 화면 비율
selectedMediaProvider               // 선택된 미디어 목록

// 타임라인 상태
timelineProvider                    // 타임라인 전체 상태
selectedClipProvider                // 선택된 클립
videoClipsProvider                  // 비디오 클립 목록
totalDurationProvider               // 전체 길이
zoomProvider                        // 줌 레벨
isPlayingProvider                   // 재생 상태
currentTimeProvider                 // 현재 시간
```

### 디자인 시스템

#### 색상 팔레트
```dart
// Primary
AppColors.primary      // #22C55E (Golf Green)

// Secondary
AppColors.secondary    // #3B82F6 (Accent Blue)

// Grayscale
AppColors.gray50       // #F9FAFB
AppColors.gray100      // #F3F4F6
AppColors.gray200      // #E5E7EB
AppColors.gray400      // #9CA3AF
AppColors.gray600      // #4B5563
AppColors.gray800      // #1F2937
AppColors.gray900      // #111827

// Status
AppColors.error        // #EF4444
AppColors.success      // #10B981
```

#### 트랙 색상
```dart
Video   → #3B82F6 (Blue)
Text    → #F59E0B (Amber)
Audio   → #10B981 (Emerald)
Filter  → #A855F7 (Purple)
Sticker → #EC4899 (Pink)
```

---

## 📚 핵심 파일 가이드

### 1. 상수 및 설정

#### [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)

**TimelineConfig 클래스** (44-156줄)
```dart
// 줌 설정
static const double zoomMin = 0.5;
static const double zoomMax = 3.0;
static const double zoomStep = 0.25;

// 속도 설정
static const double speedMin = 0.1;
static const double speedMax = 8.0;
static const double speedStep = 0.1;

// 유틸리티
static double timeToPixels(double seconds, double zoom);
static double pixelsToTime(double pixels, double zoom);
```

### 2. 데이터 모델

#### [lib/features/editor/domain/models/timeline_clip.dart](lib/features/editor/domain/models/timeline_clip.dart)

**TimelineClip 클래스** (76-301줄)
```dart
// 공통 속성
final String id;
final String clipId;        // 원본 미디어 ID
final TrackType track;      // video, text, audio, filter, sticker
final double position;      // 타임라인상 시작 위치 (초)
final double duration;      // 타임라인상 길이 (초)

// 트림/분할용
final double? startTime;    // 원본 영상 시작 지점
final double? endTime;      // 원본 영상 끝 지점

// 트랙별 속성
final double speed;         // Video: 속도
final String? textContent;  // Text: 내용
final BgmItem? audioBgm;    // Audio: BGM
final double filterBrightness;  // Filter: 밝기
final String? stickerEmoji; // Sticker: 이모지

// 헬퍼
double get endPosition => position + duration;
String get label;           // UI 표시용 라벨
Color get trackColor;       // 트랙 색상
```

### 3. 상태 관리

#### [lib/features/editor/data/providers/timeline_provider.dart](lib/features/editor/data/providers/timeline_provider.dart)

**TimelineState 클래스** (5-79줄)
```dart
final List<TimelineClip> clips;
final String? selectedClipId;
final double zoom;
final double currentTime;
final bool isPlaying;

// 계산 속성
TimelineClip? get selectedClip;
List<TimelineClip> get videoClips;
double get totalDuration;
(double, double)? get videoBounds;  // (start, end)
```

**TimelineNotifier 클래스** (84-625줄)
```dart
// 클립 CRUD
void addClip(TimelineClip clip);
void updateClip(String clipId, TimelineClip newClip);
void deleteClip(String clipId);
void duplicateClip(String clipId);

// 클립 조작
bool splitClip(String clipId, double splitPoint);
void updateClipSpeed(String clipId, double speed);
void trimClipStart(String clipId, double newStartTime);
void trimClipEnd(String clipId, double newEndTime);
void moveClip(String clipId, double newPosition);

// UI 상태
void setZoom(double zoom);
void setCurrentTime(double time);
void togglePlayPause();
void selectClip(String? clipId);

// 헬퍼
List<TimelineClip> _adjustNonVideoClips(List<TimelineClip> clips);
```

### 4. 메인 화면

#### [lib/features/editor/presentation/screens/editor_workspace_screen.dart](lib/features/editor/presentation/screens/editor_workspace_screen.dart)

**EditorWorkspaceScreen** (20-820줄)

```dart
// 주요 상태
String _projectTitle;
bool _isPlaying;
double _currentTime;
ScrollController _timelineScrollController;

// 레이아웃 구조
build() {
  return Column([
    _buildTopBar(),           // 뒤로가기, 제목, 내보내기
    _buildPreviewArea(),      // 프리뷰 플레이어 (45%)
    _buildTimelineArea(),     // 타임라인 (55%)
  ]);
}

// 타임라인 영역
_buildTimelineArea() {
  return Column([
    _buildZoomControls(),     // 줌 컨트롤
    Row([
      TrackLabelsColumn(),    // 트랙 레이블
      TimelineTracksColumn(), // 트랙 + 클립들
      PlayheadWidget(),       // 센터 고정 플레이헤드
    ]),
    _buildBottomToolbar(),    // 선택해제/분할/속도/복제/삭제
  ]);
}

// 이벤트 핸들러
void _onClipTap(String clipId);
void _onClipDoubleTap(TimelineClip clip);
void _onClipMove(String clipId, double newPosition);
void _onTrimStart(String clipId, double delta);
void _onTrimEnd(String clipId, double delta);

// 편집 패널
void _showSpeedPanel(BuildContext context);
void _showFilterPanel(BuildContext context);
void _showAudioPanel(BuildContext context);
void _showStickerPanel(BuildContext context);
void _showExportDialog(BuildContext context);
```

### 5. 내보내기

#### [lib/features/editor/presentation/widgets/export_panel.dart](lib/features/editor/presentation/widgets/export_panel.dart)

**ExportPanel** (24-299줄)
```dart
// 품질 옵션
enum ExportQuality {
  low('저화질', '480p'),
  medium('중화질', '720p'),
  high('고화질', '1080p'),
  ultra('최고화질', '4K'),
}

// 내보내기 시뮬레이션 (261-298줄)
Future<void> _startExport() async {
  // TODO: 실제 구현은 프로토타입 범위 밖
  // 현재는 진행률 시뮬레이션만 구현
  for (int i = 0; i <= 100; i += 5) {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _exportProgress = i / 100);
  }
  // 완료 알림
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

## 🚀 시작하기

### 요구사항
- Flutter SDK 3.5.0 이상
- Dart SDK 3.5.0 이상

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/noah8010/golfsnap_flutter.git
cd golfsnap_flutter

# 의존성 설치
flutter pub get

# 웹에서 실행 (권장)
flutter run -d chrome

# Android 실행 (한글 경로 주의)
flutter run -d android
```

### 빌드

```bash
# 웹 빌드
flutter build web --release --base-href "/golfsnap_flutter/"

# Android APK 빌드
flutter build apk --release
```

### 배포

main 브랜치에 push하면 자동으로 GitHub Pages에 배포됩니다.
- URL: https://noah8010.github.io/golfsnap_flutter/

---

## 💡 다음 개발자를 위한 팁

### 코드 파악 순서

1. **상수 및 설정 이해**
   - [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
   - TimelineConfig 클래스의 유틸리티 메서드 확인

2. **데이터 모델 파악**
   - [lib/features/editor/domain/models/timeline_clip.dart](lib/features/editor/domain/models/timeline_clip.dart)
   - 5개 트랙의 속성 구조 이해

3. **상태 관리 로직 이해**
   - [lib/features/editor/data/providers/timeline_provider.dart](lib/features/editor/data/providers/timeline_provider.dart)
   - 클립 CRUD, 분할, 속도 조절, 트림, 이동 로직 확인

4. **UI 구조 파악**
   - [lib/features/editor/presentation/screens/editor_workspace_screen.dart](lib/features/editor/presentation/screens/editor_workspace_screen.dart)
   - 레이아웃 및 이벤트 핸들러 확인

5. **위젯 세부 구현**
   - [lib/features/editor/presentation/widgets/](lib/features/editor/presentation/widgets/)
   - 각 위젯의 역할 및 인터랙션 확인

### 주요 개념

#### 리플 편집 (Ripple Edit)
클립 길이가 변경되면 뒤에 있는 클립들이 자동으로 이동합니다.

```dart
// 예: 속도 조절 시
void updateClipSpeed(String clipId, double speed) {
  // 1. 속도에 따라 duration 재계산
  final newDuration = sourceLength / speed;
  final durationDelta = newDuration - clip.duration;

  // 2. 같은 트랙의 뒤 클립들 이동 (리플 편집)
  if (c.track == clip.track && c.position > clip.position) {
    return c.copyWith(position: c.position + durationDelta);
  }
}
```

#### 비디오 범위 기반 조정
텍스트/오디오/필터/스티커는 비디오 클립 범위 내로 자동 제한됩니다.

```dart
List<TimelineClip> _adjustNonVideoClips(List<TimelineClip> clips) {
  final videoEnd = /* 비디오 클립의 끝 위치 */;

  return clips.map((c) {
    if (c.track != TrackType.video) {
      // 비디오 범위를 벗어나면 위치 조정
      if (c.position + c.duration > videoEnd) {
        return c.copyWith(position: /* 조정된 위치 */);
      }
    }
    return c;
  }).toList();
}
```

#### 센터 고정 플레이헤드
타임라인을 스크롤하면 플레이헤드는 화면 중앙에 고정되어 있습니다.

```dart
// 타임라인 너비 = 콘텐츠 너비 + 좌우 패딩
final centerOffset = (screenWidth - trackLabelWidth) / 2;
final timelineWidth = contentWidth + centerOffset * 2;

// 플레이헤드는 항상 centerOffset 위치에 고정
PlayheadWidget(centerOffset: centerOffset);
```

### 프로토타입 개발 가이드

#### ✅ 프로토타입에서 해야 할 것
- UI 컴포넌트 추가
- 인터랙션 시뮬레이션
- 상태 관리 로직 개선
- 애니메이션 및 전환 효과
- Mock 데이터 확장

#### ❌ 프로토타입에서 하지 말아야 할 것
- 실제 비디오 렌더링 구현
- FFmpeg 통합
- 실제 파일 시스템 접근
- 실제 갤러리 통합
- 영구 저장소 구현

### 디버깅 팁

#### 타임라인 상태 확인
```dart
// 현재 상태 로그
final state = ref.read(timelineProvider);
print('Clips: ${state.clips.length}');
print('Total Duration: ${state.totalDuration}');
print('Selected: ${state.selectedClipId}');
```

#### 클립 위치 계산 확인
```dart
// 픽셀 <-> 시간 변환
final pixels = TimelineConfig.timeToPixels(5.0, 1.0);  // 5초 → 50px
final time = TimelineConfig.pixelsToTime(50.0, 1.0);   // 50px → 5초
```

### 알려진 이슈

#### 1. Windows 한글 경로 문제
Android 빌드 시 한글 사용자명 경로에서 Kotlin 컴파일 오류 발생

**해결책**:
- 영문 경로에서 빌드
- 환경변수 설정: `GRADLE_USER_HOME=C:\gradle`

#### 2. photo_manager 비활성화
한글 경로 이슈로 임시 비활성화 ([pubspec.yaml:31](pubspec.yaml#L31))

**현재 상태**: Mock 데이터 사용

---

## 📊 프로젝트 통계

### 코드 라인 수
- **총 라인**: ~3,500줄
- **TimelineProvider**: 661줄
- **EditorWorkspaceScreen**: 820줄
- **TimelineClip**: 302줄
- **ExportPanel**: 311줄

### 파일 수
- **총 파일**: 27개
- **모델**: 4개
- **Provider**: 2개
- **화면**: 4개
- **위젯**: 12개

### 완성도
- **핵심 플로우**: 100%
- **타임라인 편집**: 90%
- **UI 위젯**: 100%
- **프로토타입 전체**: ~85%

---

## 📝 참고 문서

- [CLAUDE.md](CLAUDE.md) - Claude AI 작업 가이드
- [README.md](README.md) - 프로젝트 소개
- [React 프로토타입](https://github.com/noah8010/golfsnap_00)
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Riverpod 문서](https://riverpod.dev/)

---

## ✉️ 문의

프로젝트 관련 문의사항은 GitHub Issues를 통해 남겨주세요.

---

**작성자**: GolfSnap Team
**최종 수정**: 2026-02-02
