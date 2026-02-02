# GolfSnap Flutter

골프 영상 편집 앱 - Flutter 버전

React/TypeScript로 개발된 골프 영상 편집 앱을 Flutter로 변환하는 프로젝트입니다.

## 프로젝트 이력

- **기존 프로젝트**: `E:\flutter_projects\golfsnap_m` (React/TypeScript)
- **현재 프로젝트**: `E:\flutter_projects\golfsnap_flutter` (Flutter)
- **참고 프로토타입**: [golfsnap_00](https://github.com/noah8010/golfsnap_00) (React)

## ⚠️ 프로토타입 프로젝트

**이 프로젝트는 UI/UX 검증을 위한 인터랙티브 프로토타입입니다.**

실제 비디오 렌더링, 갤러리 연동, 비디오 재생 기능은 구현하지 않습니다.
모든 편집 기능은 UI 조작과 시뮬레이션을 통해 동작 방식을 확인할 수 있습니다.

### 구현된 기능 (시뮬레이션)
- ✅ 타임라인 편집 UI (5트랙: 영상/텍스트/오디오/필터/스티커)
- ✅ 클립 조작 (선택/이동/트림/분할/복제/삭제)
- ✅ 속도 조절, 필터, 스티커, 오디오 패널
- ✅ 내보내기 진행 시뮬레이션

### 구현하지 않는 기능
- ❌ 실제 비디오 렌더링
- ❌ 실제 갤러리 연동
- ❌ 실제 비디오 재생

## 주요 기능

- **대시보드**: 프로젝트 목록 관리, 새 프로젝트 생성
- **화면 비율 선택**: 16:9 (가로), 9:16 (세로/릴스), 1:1 (정사각형)
- **미디어 선택**: 날짜별 그룹화, 메타데이터 표시 (스윙 분석 데이터)
- **에디터**: 5트랙 타임라인 (영상, 텍스트, 오디오, 필터, 스티커)

## 기술 스택

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── core/
│   ├── constants/               # 앱 상수
│   ├── theme/                   # 테마 및 색상
│   └── router/                  # 라우팅 설정
└── features/
    ├── dashboard/               # 대시보드 (만들기)
    │   ├── data/providers/      # 상태 관리
    │   ├── domain/models/       # 프로젝트 모델
    │   └── presentation/screens/
    ├── project_creation/        # 프로젝트 생성
    │   └── presentation/screens/
    ├── media_selection/         # 미디어 선택
    │   ├── domain/models/       # 미디어 모델
    │   └── presentation/screens/
    └── editor/                  # 에디터
        ├── domain/models/       # 타임라인 클립 모델
        └── presentation/screens/
```

## 시작하기

### 요구사항

- Flutter SDK 3.5.0 이상
- Dart SDK 3.5.0 이상

### 설치

```bash
# 의존성 설치
flutter pub get

# 웹 실행
flutter run -d chrome

# Android 실행
flutter run -d android

# iOS 실행
flutter run -d ios
```

### 빌드

```bash
# 웹 빌드
flutter build web --release

# Android APK 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 배포

GitHub Pages에 자동 배포됩니다:
- **URL**: https://noah8010.github.io/golfsnap_flutter/

## 관련 프로젝트

- [GolfSnap React](https://github.com/noah8010/golfsnap_00) - React 프로토타입 버전

## 라이선스

MIT License
