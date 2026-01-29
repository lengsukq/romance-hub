import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/config_dialog.dart';

/// 用户信息页面
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
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
              const SnackBar(content: Text('后端地址已更新')),
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

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('吾心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.config),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('云阁'),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '当前地址',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showConfigDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('配置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _baseUrl.isEmpty ? '未配置云阁' : _baseUrl,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_userInfo != null) ...[
            _buildSectionTitle('吾之信息'),
            if (_userInfo!.avatar != null && _userInfo!.avatar!.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage(_userInfo!.avatar!),
                  ),
                ),
              ),
            _buildInfoCard(
              title: '用户名',
              value: _userInfo!.username.isEmpty ? '未设置' : _userInfo!.username,
            ),
            _buildInfoCard(
              title: '邮箱',
              value: _userInfo!.userEmail,
            ),
            _buildInfoCard(
              title: '积分',
              value: '${_userInfo!.score}',
            ),
            if (_userInfo!.describeBySelf != null)
              _buildInfoCard(
                title: '一言',
                value: _userInfo!.describeBySelf!,
              ),
            const SizedBox(height: 16),
          ],
          if (_loverInfo != null) ...[
            _buildSectionTitle('良人信息'),
            _buildInfoCard(
              title: '用户名',
              value: _loverInfo!.username.isEmpty ? '未设置' : _loverInfo!.username,
            ),
            _buildInfoCard(
              title: '邮箱',
              value: _loverInfo!.userEmail,
            ),
            if (_loverInfo!.describeBySelf != null)
              _buildInfoCard(
                title: '一言',
                value: _loverInfo!.describeBySelf!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
