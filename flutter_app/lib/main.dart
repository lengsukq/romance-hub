import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/routes/app_router.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
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

/// 主题：简洁 · 浪漫 · 大圆角 · 现代化（见 docs/UI_DESIGN_RULES.md）
ThemeData _buildAppTheme() {
  const Color primary = Color(0xFFD4A5A5); // 豆沙粉
  const Color surface = Color(0xFFFBF8F8);  // 偏暖白
  const Color surfaceContainer = Color(0xFFFDFCFC);
  const Color onSurface = Color(0xFF3D3636);
  const Color onSurfaceVariant = Color(0xFF7A7373);
  const Color outline = Color(0xFFE8E2E2);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFDF2F2),
      onPrimaryContainer: onSurface,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      error: const Color(0xFFC97A7A),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: outline, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainer,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: onSurfaceVariant),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: const BorderSide(color: outline),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceContainer,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: onSurfaceVariant,
        fontSize: 15,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurface,
      contentTextStyle: const TextStyle(color: surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final AuthNotifier authNotifier;

  const MyApp({
    super.key,
    required this.router,
    required this.authNotifier,
  });

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
        theme: _buildAppTheme(),
        routerConfig: router,
      ),
    );
  }
}
