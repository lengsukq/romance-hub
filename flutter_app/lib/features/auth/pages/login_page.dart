import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/shared/widgets/config_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/debug_panel_dialog.dart';
import 'package:romance_hub_flutter/core/constants/love_verses.dart';
import 'package:romance_hub_flutter/shared/widgets/year_2026_badge.dart';

/// 登录页面
/// 支持配置后端服务器地址
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _baseUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  int _heartTapCount = 0;
  DateTime? _heartTapTime;
  static const _debugTapCount = 5;
  static const _debugTapWindow = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  /// 加载已保存的后端地址
  Future<void> _loadBaseUrl() async {
    final baseUrl = await AppConfig.getBaseUrl();
    setState(() {
      _baseUrlController.text = baseUrl;
    });
  }

  /// 连点爱心 5 次打开调试面板
  void _onHeartTap() {
    final now = DateTime.now();
    if (_heartTapTime != null && now.difference(_heartTapTime!) > _debugTapWindow) {
      _heartTapCount = 0;
    }
    _heartTapTime = now;
    _heartTapCount++;
    if (_heartTapCount >= _debugTapCount) {
      _heartTapCount = 0;
      _heartTapTime = null;
      _showDebugPanel();
    }
  }

  void _showDebugPanel() {
    showDialog(
      context: context,
      builder: (context) => DebugPanelDialog(
        currentBaseUrl: _baseUrlController.text,
        onUrlUpdated: () => _loadBaseUrl(),
      ),
    );
  }

  /// 显示配置对话框
  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfigDialog(
        initialUrl: _baseUrlController.text,
        onSave: (url) async {
          await AppConfig.setBaseUrl(url);
          await ApiService().updateBaseUrl(url);
          setState(() {
            _baseUrlController.text = url;
          });
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('云阁已更新')),
            );
          }
        },
      ),
    );
  }

  /// 执行登录
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final response = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          // 登录成功，更新登录态；确认 cookie 可读后再跳转，避免首次进私语等请求未带上 cookie
          context.read<AuthNotifier>().setLoggedIn(true);
          await ApiService().hasCookie();
          if (mounted) context.go(AppRoutes.home);
        } else {
          setState(() {
            _errorMessage = response.msg;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '登录失败: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2026 马年专属标识 + 按日诗意副标题
                  const Year2026Badge(label: '2026', large: true),
                  const SizedBox(height: 8),
                  Text(
                    LoveVerses.getShortVerseOfDay(DateTime.now()).text,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 品牌区：图标 + 标题 + 副标题（连点爱心 5 次可打开调试面板）
                  GestureDetector(
                    onTap: _onHeartTap,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '锦书',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ) ?? TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '两心相知，一事一诺',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ) ?? TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),

                  // 云阁配置卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cloud_rounded, size: 22, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                '云阁配置',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _showConfigDialog,
                                icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                                label: const Text('配置'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  foregroundColor: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _baseUrlController,
                            decoration: InputDecoration(
                              labelText: '云阁地址',
                              hintText: 'https://r-d.lengsu.top/',
                              prefixIcon: Icon(Icons.link_rounded, color: colorScheme.onSurfaceVariant),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.url,
                            enabled: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _baseUrlController.text.isEmpty ? '未配置云阁' : '当前：${_baseUrlController.text}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 登入表单卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '登入',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: '昵称或邮箱',
                              hintText: '请输入昵称或邮箱',
                              prefixIcon: Icon(Icons.person_rounded, color: colorScheme.onSurfaceVariant),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入昵称或邮箱';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: '密码',
                              hintText: '请输入密码',
                              prefixIcon: Icon(Icons.lock_rounded, color: colorScheme.onSurfaceVariant),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入密码';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                    ),
                                  )
                                : const Text('登入'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 注册入口
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: Text(
                        '未有账号？去注册',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
