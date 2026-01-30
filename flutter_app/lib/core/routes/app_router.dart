import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/features/auth/pages/login_page.dart';
import 'package:romance_hub_flutter/features/auth/pages/register_page.dart';
import 'package:romance_hub_flutter/features/home/pages/home_page.dart';
import 'package:romance_hub_flutter/features/task/pages/task_list_page.dart';
import 'package:romance_hub_flutter/features/task/pages/task_detail_page.dart';
import 'package:romance_hub_flutter/features/task/pages/post_task_page.dart';
import 'package:romance_hub_flutter/features/gift/pages/gift_list_page.dart';
import 'package:romance_hub_flutter/features/gift/pages/my_gift_list_page.dart';
import 'package:romance_hub_flutter/features/gift/pages/add_gift_page.dart';
import 'package:romance_hub_flutter/features/whisper/pages/whisper_list_page.dart';
import 'package:romance_hub_flutter/features/whisper/pages/post_whisper_page.dart';
import 'package:romance_hub_flutter/features/favourite/pages/favourite_list_page.dart';
import 'package:romance_hub_flutter/features/user/pages/user_info_page.dart';
import 'package:romance_hub_flutter/features/config/pages/config_page.dart';
import 'package:romance_hub_flutter/shared/widgets/main_scaffold.dart';

/// 创建应用路由：根据 [AuthNotifier] 做登录态重定向，有 cookie 则保持登录
/// StatefulShellRoute 置于顶层，无父 GoRoute，避免黑屏
GoRouter createAppRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final hasCookie = await ApiService().hasCookie();
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      if (hasCookie && isAuthRoute) return AppRoutes.home;
      if (!hasCookie && !isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nameLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.nameRegister,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScaffold(navigationShell: navigationShell),
        branches: [
          // 首页（含藏心入口）
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/index',
                name: AppRoutes.nameHome,
                builder: (context, state) => const HomePage(),
              ),
              GoRoute(
                path: '/favourites',
                name: AppRoutes.nameFavouriteList,
                builder: (context, state) {
                  final type =
                      state.uri.queryParameters['type'] ?? 'task';
                  return FavouriteListPage(type: type);
                },
              ),
            ],
          ),
          // 心诺
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                name: AppRoutes.nameTaskList,
                builder: (context, state) => const TaskListPage(),
              ),
              GoRoute(
                path: '/task/:taskId',
                name: AppRoutes.nameTaskDetail,
                builder: (context, state) {
                  final taskId =
                      int.parse(state.pathParameters['taskId'] ?? '0');
                  return TaskDetailPage(taskId: taskId);
                },
              ),
              GoRoute(
                path: '/post-task',
                name: AppRoutes.namePostTask,
                builder: (context, state) => const PostTaskPage(),
              ),
            ],
          ),
          // 赠礼
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gifts',
                name: AppRoutes.nameGiftList,
                builder: (context, state) => const GiftListPage(),
              ),
              GoRoute(
                path: '/my-gifts',
                name: AppRoutes.nameMyGiftList,
                builder: (context, state) => const MyGiftListPage(),
              ),
              GoRoute(
                path: '/add-gift',
                name: AppRoutes.nameAddGift,
                builder: (context, state) => const AddGiftPage(),
              ),
            ],
          ),
          // 私语
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/whispers',
                name: AppRoutes.nameWhisperList,
                builder: (context, state) {
                  final type =
                      state.uri.queryParameters['type'] ?? 'my';
                  return WhisperListPage(type: type);
                },
              ),
              GoRoute(
                path: '/post-whisper',
                name: AppRoutes.namePostWhisper,
                builder: (context, state) => const PostWhisperPage(),
              ),
            ],
          ),
          // 吾心
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user-info',
                name: AppRoutes.nameUserInfo,
                builder: (context, state) => const UserInfoPage(),
              ),
              GoRoute(
                path: '/config',
                name: AppRoutes.nameConfig,
                builder: (context, state) => const ConfigPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
