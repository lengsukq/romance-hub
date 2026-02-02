import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';
import 'package:romance_hub_flutter/features/user/widgets/cloud_section_card.dart';
import 'package:romance_hub_flutter/features/user/widgets/edit_user_info_dialog.dart';
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
  int _avatarCacheKey = 0;

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userResponse = await _userService.getUserInfo();
      AppLogger.i('[吾之信息-获取] isSuccess=${userResponse.isSuccess}, code=${userResponse.code}, msg=${userResponse.msg}');
      if (userResponse.data != null) {
        final u = userResponse.data!;
        AppLogger.i('[吾之信息-获取数据] userId=${u.userId}, username=${u.username}, avatar=${u.avatar ?? "(空)"}, describeBySelf=${u.describeBySelf ?? "(空)"}');
      }
      if (!mounted) return;
      if (userResponse.isSuccess && userResponse.data != null) {
        setState(() {
          _userInfo = userResponse.data;
          _avatarCacheKey = DateTime.now().millisecondsSinceEpoch;
        });
      }

      final loverResponse = await _userService.getLoverInfo();
      if (!mounted) return;
      if (loverResponse.isSuccess && loverResponse.data != null) {
        setState(() => _loverInfo = loverResponse.data);
      }
    } catch (e) {
      AppLogger.e('加载用户信息失败', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _avatarUrlWithCacheBuster(String? url) {
    if (url == null || url.isEmpty) return null;
    return '$url${url.contains('?') ? '&' : '?'}t=$_avatarCacheKey';
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('吾心'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go(AppRoutes.config),
            tooltip: '设置',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: '退出',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '吾心',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ClassicVerses.xiSang,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionTitle(title: '云阁', verse: ClassicVerses.jianJia),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: CloudSectionCard(baseUrl: _baseUrl, onConfig: _showConfigDialog),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionTitle(title: '设置', verse: '与良人共用'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _SettingsTile(
                title: '图床设置',
                subtitle: '未设置则无法上传图片',
                icon: Icons.cloud_rounded,
                onTap: () => context.go(AppRoutes.config),
              ),
            ),
          ),
          if (_userInfo != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SectionTitle(title: '吾之信息', verse: ClassicVerses.ziJin),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final saved = await EditUserInfoDialog.show(context, _userInfo!);
                        if (saved == true && mounted) _loadUserInfo();
                      },
                      icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                      label: Text('编辑', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: UserAvatar(avatarUrl: _avatarUrlWithCacheBuster(_userInfo!.avatar)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  InfoRowCard(
                    label: '用户名',
                    value: _userInfo!.username.isEmpty ? '未设置' : _userInfo!.username,
                  ),
                  InfoRowCard(label: '邮箱', value: _userInfo!.userEmail),
                  InfoRowCard(label: '积分', value: '${_userInfo!.score}'),
                  if (_userInfo!.describeBySelf != null)
                    InfoRowCard(label: '一言', value: _userInfo!.describeBySelf!),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          if (_loverInfo != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SectionTitle(title: '良人信息', verse: ClassicVerses.chouMou),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  InfoRowCard(
                    label: '用户名',
                    value: _loverInfo!.username.isEmpty ? '未设置' : _loverInfo!.username,
                  ),
                  InfoRowCard(label: '邮箱', value: _loverInfo!.userEmail),
                  if (_loverInfo!.describeBySelf != null)
                    InfoRowCard(label: '一言', value: _loverInfo!.describeBySelf!),
                ]),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// 设置入口长条：与首页入口风格一致
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
