import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/screens/create_dashboard_screen.dart';
import '../../features/project_creation/presentation/screens/aspect_ratio_screen.dart';
import '../../features/media_selection/presentation/screens/media_selection_screen.dart';
import '../../features/editor/presentation/screens/editor_workspace_screen.dart';

/// 앱 라우터 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/create',
    routes: [
      // 대시보드 (만들기) 화면
      GoRoute(
        path: '/create',
        name: 'create',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // 화면 비율 선택
      GoRoute(
        path: '/new-project/aspect-ratio',
        name: 'aspectRatio',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AspectRatioScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      ),

      // 미디어 선택
      GoRoute(
        path: '/new-project/media-selection',
        name: 'mediaSelection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MediaSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      ),

      // 에디터 화면
      GoRoute(
        path: '/editor',
        name: 'editor',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditorWorkspaceScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
});
