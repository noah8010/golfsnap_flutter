import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/project.dart';

/// 현재 화면 상태
enum AppScreen {
  home,
  create,
  newProject,
  editor,
}

/// 앱 전역 상태
class AppState {
  final AppScreen currentScreen;
  final List<Project> projects;
  final Project? currentProject;
  final bool isShareMode;

  const AppState({
    this.currentScreen = AppScreen.create,
    this.projects = const [],
    this.currentProject,
    this.isShareMode = false,
  });

  AppState copyWith({
    AppScreen? currentScreen,
    List<Project>? projects,
    Project? currentProject,
    bool? isShareMode,
  }) {
    return AppState(
      currentScreen: currentScreen ?? this.currentScreen,
      projects: projects ?? this.projects,
      currentProject: currentProject ?? this.currentProject,
      isShareMode: isShareMode ?? this.isShareMode,
    );
  }
}

/// 앱 상태 Notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _initMockData();
  }

  void _initMockData() {
    // Mock 프로젝트 데이터
    final mockProjects = [
      Project(
        id: 'project-1',
        name: '드라이버 스윙 연습',
        thumbnail: 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=400&h=400&fit=crop',
        aspectRatio: AspectRatioType.landscape,
        duration: 45,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Project(
        id: 'project-2',
        name: '아이언 샷 분석',
        thumbnail: 'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=400&h=400&fit=crop',
        aspectRatio: AspectRatioType.portrait,
        duration: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    state = state.copyWith(projects: mockProjects);
  }

  void setCurrentScreen(AppScreen screen) {
    state = state.copyWith(currentScreen: screen);
  }

  void setCurrentProject(Project? project) {
    state = state.copyWith(currentProject: project);
  }

  void setShareMode(bool isShareMode) {
    state = state.copyWith(isShareMode: isShareMode);
  }

  void addProject(Project project) {
    state = state.copyWith(projects: [...state.projects, project]);
  }

  void updateProject(String id, Project Function(Project) update) {
    state = state.copyWith(
      projects: state.projects.map((p) => p.id == id ? update(p) : p).toList(),
    );
  }

  void deleteProject(String id) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != id).toList(),
    );
  }

  void duplicateProject(String id) {
    final project = state.projects.firstWhere((p) => p.id == id);
    final newProject = project.copyWith(
      id: 'project-${DateTime.now().millisecondsSinceEpoch}',
      name: '${project.name} (복사본)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    addProject(newProject);
  }
}

/// 앱 상태 Provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

/// 현재 화면 Provider
final currentScreenProvider = Provider<AppScreen>((ref) {
  return ref.watch(appStateProvider).currentScreen;
});

/// 프로젝트 목록 Provider
final projectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(appStateProvider).projects;
});

/// 현재 프로젝트 Provider
final currentProjectProvider = Provider<Project?>((ref) {
  return ref.watch(appStateProvider).currentProject;
});
