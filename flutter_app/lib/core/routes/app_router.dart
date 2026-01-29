import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/features/auth/pages/login_page.dart';
import 'package:romance_hub_flutter/features/auth/pages/register_page.dart';
import 'package:romance_hub_flutter/features/home/pages/home_page.dart';
import 'package:romance_hub_flutter/features/task/pages/task_list_page.dart';
import 'package:romance_hub_flutter/features/task/pages/task_detail_page.dart';
import 'package:romance_hub_flutter/features/task/pages/post_task_page.dart';
import 'package:romance_hub_flutter/features/gift/pages/gift_list_page.dart';
import 'package:romance_hub_flutter/features/gift/pages/add_gift_page.dart';
import 'package:romance_hub_flutter/features/whisper/pages/whisper_list_page.dart';
import 'package:romance_hub_flutter/features/whisper/pages/post_whisper_page.dart';
import 'package:romance_hub_flutter/features/favourite/pages/favourite_list_page.dart';
import 'package:romance_hub_flutter/features/user/pages/user_info_page.dart';
import 'package:romance_hub_flutter/features/config/pages/config_page.dart';
import 'package:romance_hub_flutter/shared/widgets/main_scaffold.dart';

/// 应用路由配置
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainScaffold(
        child: HomePage(),
      ),
      routes: [
        GoRoute(
          path: 'tasks',
          name: 'taskList',
          builder: (context, state) => const MainScaffold(
            child: TaskListPage(),
          ),
        ),
        GoRoute(
          path: 'task/:taskId',
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = int.parse(state.pathParameters['taskId']!);
            return MainScaffold(
              child: TaskDetailPage(taskId: taskId),
            );
          },
        ),
        GoRoute(
          path: 'post-task',
          name: 'postTask',
          builder: (context, state) => const MainScaffold(
            child: PostTaskPage(),
          ),
        ),
        GoRoute(
          path: 'gifts',
          name: 'giftList',
          builder: (context, state) => const MainScaffold(
            child: GiftListPage(),
          ),
        ),
        GoRoute(
          path: 'add-gift',
          name: 'addGift',
          builder: (context, state) => const MainScaffold(
            child: AddGiftPage(),
          ),
        ),
        GoRoute(
          path: 'whispers',
          name: 'whisperList',
          builder: (context, state) {
            final type = state.uri.queryParameters['type'] ?? 'my';
            return MainScaffold(
              child: WhisperListPage(type: type),
            );
          },
        ),
        GoRoute(
          path: 'post-whisper',
          name: 'postWhisper',
          builder: (context, state) => const MainScaffold(
            child: PostWhisperPage(),
          ),
        ),
        GoRoute(
          path: 'favourites',
          name: 'favouriteList',
          builder: (context, state) {
            final type = state.uri.queryParameters['type'] ?? 'task';
            return MainScaffold(
              child: FavouriteListPage(type: type),
            );
          },
        ),
        GoRoute(
          path: 'user-info',
          name: 'userInfo',
          builder: (context, state) => const MainScaffold(
            child: UserInfoPage(),
          ),
        ),
        GoRoute(
          path: 'config',
          name: 'config',
          builder: (context, state) => const MainScaffold(
            child: ConfigPage(),
          ),
        ),
      ],
    ),
  ],
);
