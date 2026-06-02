import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/routes/app_router.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/theme/app_theme.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/services/whisper_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.getBaseUrl(); // 初始化配置

  final authNotifier = AuthNotifier();
  ApiService.setOn401(() => authNotifier.refresh());
  final router = createAppRouter(authNotifier);

  runApp(MyApp(router: router, authNotifier: authNotifier));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final AuthNotifier authNotifier;

  const MyApp({super.key, required this.router, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>(create: (_) => authNotifier),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<GiftService>(create: (_) => GiftService()),
        Provider<WhisperService>(create: (_) => WhisperService()),
        Provider<FavouriteService>(create: (_) => FavouriteService()),
        Provider<UserService>(create: (_) => UserService()),
      ],
      child: MaterialApp.router(
        title: '锦书',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }
}
