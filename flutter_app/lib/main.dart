import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/routes/app_router.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/services/whisper_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.getBaseUrl(); // 初始化配置
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<GiftService>(create: (_) => GiftService()),
        Provider<WhisperService>(create: (_) => WhisperService()),
        Provider<FavouriteService>(create: (_) => FavouriteService()),
        Provider<UserService>(create: (_) => UserService()),
      ],
      child: MaterialApp.router(
        title: 'RomanceHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
