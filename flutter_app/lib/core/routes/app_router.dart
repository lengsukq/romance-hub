import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
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

/// 应用路由配置（路径与命名统一使用 [AppRoutes]）
final appRouter = GoRouter(
  initialLocation: AppRoutes.initialLocation,
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
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.nameHome,
      builder: (context, state) => const MainScaffold(
        child: HomePage(),
      ),
      routes: [
        GoRoute(
          path: 'tasks',
          name: AppRoutes.nameTaskList,
          builder: (context, state) => const MainScaffold(
            child: TaskListPage(),
          ),
        ),
        GoRoute(
          path: 'task/:taskId',
          name: AppRoutes.nameTaskDetail,
          builder: (context, state) {
            final taskId = int.parse(state.pathParameters['taskId']!);
            return MainScaffold(
              child: TaskDetailPage(taskId: taskId),
            );
          },
        ),
        GoRoute(
          path: 'post-task',
          name: AppRoutes.namePostTask,
          builder: (context, state) => const MainScaffold(
            child: PostTaskPage(),
          ),
        ),
        GoRoute(
          path: 'gifts',
          name: AppRoutes.nameGiftList,
          builder: (context, state) => const MainScaffold(
            child: GiftListPage(),
          ),
        ),
        GoRoute(
          path: 'my-gifts',
          name: AppRoutes.nameMyGiftList,
          builder: (context, state) => const MainScaffold(
            child: MyGiftListPage(),
          ),
        ),
        GoRoute(
          path: 'add-gift',
          name: AppRoutes.nameAddGift,
          builder: (context, state) => const MainScaffold(
            child: AddGiftPage(),
          ),
        ),
        GoRoute(
          path: 'whispers',
          name: AppRoutes.nameWhisperList,
          builder: (context, state) {
            final type = state.uri.queryParameters['type'] ?? 'my';
            return MainScaffold(
              child: WhisperListPage(type: type),
            );
          },
        ),
        GoRoute(
          path: 'post-whisper',
          name: AppRoutes.namePostWhisper,
          builder: (context, state) => const MainScaffold(
            child: PostWhisperPage(),
          ),
        ),
        GoRoute(
          path: 'favourites',
          name: AppRoutes.nameFavouriteList,
          builder: (context, state) {
            final type = state.uri.queryParameters['type'] ?? 'task';
            return MainScaffold(
              child: FavouriteListPage(type: type),
            );
          },
        ),
        GoRoute(
          path: 'user-info',
          name: AppRoutes.nameUserInfo,
          builder: (context, state) => const MainScaffold(
            child: UserInfoPage(),
          ),
        ),
        GoRoute(
          path: 'config',
          name: AppRoutes.nameConfig,
          builder: (context, state) => const MainScaffold(
            child: ConfigPage(),
          ),
        ),
      ],
    ),
  ],
);
