import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/config_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';

/// 用户信息页面
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final UserService _userService = UserService();
  UserModel? _userInfo;
  UserModel? _loverInfo;
  bool _isLoading = true;
  String _baseUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await AppConfig.getBaseUrl();
    if (mounted) setState(() => _baseUrl = url);
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfigDialog(
        initialUrl: _baseUrl,
        onSave: (url) async {
          await AppConfig.setBaseUrl(url);
          await ApiService().updateBaseUrl(url);
          if (mounted) {
            setState(() => _baseUrl = url);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('云阁已更新')),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userResponse = await _userService.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        setState(() {
          _userInfo = userResponse.data;
        });
      }

      final loverResponse = await _userService.getLoverInfo();
      if (loverResponse.isSuccess && loverResponse.data != null) {
        setState(() {
          _loverInfo = loverResponse.data;
        });
      }
    } catch (e) {
      AppLogger.e('加载用户信息失败', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: '确认退出',
      message: '确定要退出登录吗？',
      confirmText: '确定',
      cancelText: '取消',
    );

    if (confirm == true && mounted) {
      await context.read<AuthNotifier>().invalidate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('吾心'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go(AppRoutes.config),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionTitle(context, '云阁'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_rounded, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        '云阁地址',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showConfigDialog,
                        icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                        label: const Text('配置'),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _baseUrl.isEmpty ? '未配置云阁' : _baseUrl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_userInfo != null) ...[
            _buildSectionTitle(context, '吾之信息'),
            if (_userInfo!.avatar != null && _userInfo!.avatar!.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    backgroundImage: NetworkImage(_userInfo!.avatar!),
                  ),
                ),
              ),
            _buildInfoCard(context, '用户名', _userInfo!.username.isEmpty ? '未设置' : _userInfo!.username),
            _buildInfoCard(context, '邮箱', _userInfo!.userEmail),
            _buildInfoCard(context, '积分', '${_userInfo!.score}'),
            if (_userInfo!.describeBySelf != null)
              _buildInfoCard(context, '一言', _userInfo!.describeBySelf!),
            const SizedBox(height: 20),
          ],
          if (_loverInfo != null) ...[
            _buildSectionTitle(context, '良人信息'),
            _buildInfoCard(context, '用户名', _loverInfo!.username.isEmpty ? '未设置' : _loverInfo!.username),
            _buildInfoCard(context, '邮箱', _loverInfo!.userEmail),
            if (_loverInfo!.describeBySelf != null)
              _buildInfoCard(context, '一言', _loverInfo!.describeBySelf!),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
