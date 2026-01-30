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
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';
import 'package:romance_hub_flutter/features/user/widgets/cloud_section_card.dart';
import 'package:romance_hub_flutter/features/user/widgets/info_row_card.dart';
import 'package:romance_hub_flutter/features/user/widgets/section_title.dart';
import 'package:romance_hub_flutter/features/user/widgets/user_avatar.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/config_dialog.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';

/// 用户信息页面（吾心）：符合锦书 UI 准则，组件原子化
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
            SnackBarUtils.showSuccess(context, '已更新云阁');
          }
        },
      ),
    );
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    try {
      final userResponse = await _userService.getUserInfo();
      if (userResponse.isSuccess && userResponse.data != null) {
        setState(() => _userInfo = userResponse.data);
      }

      final loverResponse = await _userService.getLoverInfo();
      if (loverResponse.isSuccess && loverResponse.data != null) {
        setState(() => _loverInfo = loverResponse.data);
      }
    } catch (e) {
      AppLogger.e('加载用户信息失败', e);
    } finally {
      setState(() => _isLoading = false);
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
      return const Scaffold(body: LoadingWidget());
    }

    final colorScheme = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          SectionTitle(title: '云阁', verse: ClassicVerses.jianJia),
          CloudSectionCard(baseUrl: _baseUrl, onConfig: _showConfigDialog),
          const SizedBox(height: 24),
          if (_userInfo != null) ...[
            SectionTitle(title: '吾之信息', verse: ClassicVerses.ziJin),
            UserAvatar(avatarUrl: _userInfo!.avatar),
            InfoRowCard(
              label: '用户名',
              value: _userInfo!.username.isEmpty ? '未设置' : _userInfo!.username,
            ),
            InfoRowCard(label: '邮箱', value: _userInfo!.userEmail),
            InfoRowCard(label: '积分', value: '${_userInfo!.score}'),
            if (_userInfo!.describeBySelf != null)
              InfoRowCard(label: '一言', value: _userInfo!.describeBySelf!),
            const SizedBox(height: 24),
          ],
          if (_loverInfo != null) ...[
            SectionTitle(title: '良人信息', verse: ClassicVerses.chouMou),
            InfoRowCard(
              label: '用户名',
              value: _loverInfo!.username.isEmpty ? '未设置' : _loverInfo!.username,
            ),
            InfoRowCard(label: '邮箱', value: _loverInfo!.userEmail),
            if (_loverInfo!.describeBySelf != null)
              InfoRowCard(label: '一言', value: _loverInfo!.describeBySelf!),
          ],
        ],
      ),
    );
  }
}
