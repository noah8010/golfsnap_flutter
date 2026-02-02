# CLAUDE.md - GolfSnap Flutter 세션 가이드

이 문서는 Claude AI가 이 프로젝트에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

**GolfSnap Flutter**는 골프 영상 편집 앱의 Flutter 버전입니다.
React/TypeScript로 개발된 프로젝트를 Flutter로 변환하는 작업을 진행 중입니다.

### 프로젝트 이력
- **기존 프로젝트**: `E:\flutter_projects\golfsnap_m` (React/TypeScript)
- **현재 프로젝트**: `E:\flutter_projects\golfsnap_flutter` (Flutter)
- **참고 프로토타입**: [golfsnap_00](https://github.com/noah8010/golfsnap_00) (React - GitHub)

### ⚠️ 프로토타입 프로젝트

**이 프로젝트는 UI/UX 검증 및 기능 흐름 확인을 위한 프로토타입입니다.**

#### 프로토타입 목적
- ✅ 각 기능들의 동작 방식을 시각적으로 확인
- ✅ 타임라인 편집 UI/UX 검증
- ✅ 사용자 인터랙션 및 화면 전환 흐름 검증
- ✅ 5트랙 타임라인 편집기 아키텍처 검증

#### 실제 구현하지 않는 기능
- ❌ **실제 비디오 렌더링** - 내보내기는 시뮬레이션만 구현
- ❌ **실제 갤러리 연동** - Mock 데이터 사용
- ❌ **실제 비디오 플레이** - 썸네일 및 플레이 시뮬레이션만 구현
- ❌ **FFmpeg 등 비디오 처리** - 프로토타입에서는 불필요

> **중요**: 실제 비디오 렌더링, 갤러리 연동, 비디오 재생 기능은 프로토타입 범위에 포함되지 않습니다.
> 모든 편집 기능은 UI 조작과 상태 관리를 통해 "어떻게 동작하는지" 확인할 수 있는 수준으로 구현합니다.

### 핵심 기능
- 대시보드: 프로젝트 관리
- 화면 비율 선택: 16:9, 9:16, 1:1
- 미디어 선택: 갤러리에서 영상/이미지 선택
- 에디터: 5트랙 타임라인 기반 편집

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Flutter 3.x |
| 상태 관리 | Riverpod (flutter_riverpod) |
| 라우팅 | GoRouter |
| UI | Material Design 3 |
| 미디어 | video_player, image_picker |

## 프로젝트 구조

```
lib/
├── main.dart                              # 앱 진입점 (ProviderScope, MaterialApp.router)
├── core/
│   ├── constants/app_constants.dart       # 앱 상수, AspectRatioType enum
│   ├── theme/
│   │   ├── app_colors.dart                # 색상 팔레트 (primary: #22C55E)
│   │   └── app_theme.dart                 # ThemeData 설정
│   └── router/app_router.dart             # GoRouter 라우트 정의
└── features/
    ├── dashboard/
    │   ├── data/providers/app_state_provider.dart  # 전역 상태 (프로젝트 목록)
    │   ├── domain/models/project.dart              # Project 모델
    │   └── presentation/screens/create_dashboard_screen.dart
    ├── project_creation/
    │   └── presentation/screens/aspect_ratio_screen.dart
    ├── media_selection/
    │   ├── domain/models/media_item.dart           # MediaItem 모델
    │   └── presentation/screens/media_selection_screen.dart
    └── editor/
        ├── domain/models/timeline_clip.dart        # TimelineClip 모델
        └── presentation/screens/editor_workspace_screen.dart
```

## 주요 라우트

| 경로 | 화면 | 설명 |
|------|------|------|
| `/create` | CreateDashboardScreen | 대시보드 (메인) |
| `/new-project/aspect-ratio` | AspectRatioScreen | 화면 비율 선택 |
| `/new-project/media-selection` | MediaSelectionScreen | 미디어 선택 |
| `/editor` | EditorWorkspaceScreen | 에디터 |

## 상태 관리

### 주요 Provider
- `projectsProvider`: 프로젝트 목록
- `currentProjectProvider`: 현재 편집 중인 프로젝트
- `selectedAspectRatioProvider`: 선택된 화면 비율
- `selectedMediaProvider`: 선택된 미디어 목록

### 상태 변경 예시
```dart
// 읽기
final projects = ref.watch(projectsProvider);

// 쓰기
ref.read(selectedAspectRatioProvider.notifier).state = AspectRatioType.landscape;
```

## 스타일 가이드

### 색상
- Primary (Golf Green): `#22C55E`
- Secondary (Accent Blue): `#3B82F6`
- Error: `#EF4444`
- Background: `#FFFFFF`
- Surface: `#FFFFFF`

### 상태바 높이
- 기본값: 44px (`AppConstants.statusBarHeight`)
- 모든 화면 상단에 SafeArea 대신 직접 spacer 적용

### 코드 컨벤션
- `withOpacity()` 대신 `withValues(alpha:)` 사용 (deprecated 방지)
- 위젯은 `_PrivateWidget` 형태로 private 클래스 사용
- 모델은 `freezed` 스타일로 immutable 구현

## 빌드 & 배포

### 로컬 실행
```bash
flutter pub get
flutter run -d chrome      # 웹
flutter run -d android     # Android
```

### 빌드
```bash
flutter build web --release --base-href "/golfsnap_flutter/"
```

### GitHub Pages 배포
- `.github/workflows/deploy.yml`로 자동 배포
- main 브랜치 push 시 자동 빌드 및 배포
- URL: https://noah8010.github.io/golfsnap_flutter/

## 알려진 이슈

1. **Windows 한글 경로 문제**
   - Android 빌드 시 한글 사용자명 경로에서 Kotlin 컴파일 오류 발생
   - 해결: 영문 경로에서 빌드하거나 `GRADLE_USER_HOME` 환경변수 설정

2. **photo_manager 비활성화**
   - 한글 경로 이슈로 임시 비활성화
   - 미디어 선택은 현재 mock 데이터 사용

## 프로토타입 범위 내 TODO

### 우선순위 높음
- [ ] 텍스트/스티커 오버레이 드래그 UI
- [ ] 클립 드래그 & 드롭 인터랙션 개선
- [ ] 트랜지션 효과 UI/프리뷰

### 우선순위 중간
- [ ] 텍스트 폰트/크기/정렬 설정 UI
- [ ] 스티커 애니메이션 프리뷰
- [ ] 키프레임 애니메이션 UI

### 우선순위 낮음
- [ ] 실행 취소/다시 실행 UI
- [ ] 클립 다중 선택 UI

### 프로토타입 범위 밖 (구현하지 않음)
- ❌ 실제 비디오 렌더링 (시뮬레이션만 구현)
- ❌ 실제 갤러리 연동 (Mock 데이터 사용)
- ❌ 실제 비디오 재생 (썸네일/시뮬레이션만 구현)
- ❌ FFmpeg 통합
- ❌ 프로젝트 영구 저장 (메모리 상태만)

## 관련 문서

- React 버전: https://github.com/noah8010/golfsnap_00
- Flutter 공식 문서: https://docs.flutter.dev/
- Riverpod 문서: https://riverpod.dev/
