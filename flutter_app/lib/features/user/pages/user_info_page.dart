import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/utils/date_utils.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
        context.go('/login');
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
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/config'),
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
          if (_userInfo != null) ...[
            _buildSectionTitle('我的信息'),
            _buildInfoCard(
              title: '用户名',
              value: _userInfo!.username ?? '未设置',
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
                title: '个人描述',
                value: _userInfo!.describeBySelf!,
              ),
            const SizedBox(height: 16),
          ],
          if (_loverInfo != null) ...[
            _buildSectionTitle('关联者信息'),
            _buildInfoCard(
              title: '用户名',
              value: _loverInfo!.username ?? '未设置',
            ),
            _buildInfoCard(
              title: '邮箱',
              value: _loverInfo!.userEmail,
            ),
            if (_loverInfo!.describeBySelf != null)
              _buildInfoCard(
                title: '个人描述',
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
