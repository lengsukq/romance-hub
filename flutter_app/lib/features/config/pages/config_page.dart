import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romance_hub_flutter/core/models/image_bed_model.dart';
import 'package:romance_hub_flutter/core/models/notification_config_model.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/config_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';

/// 配置页面
class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final UserService _userService = UserService();
  final UploadService _uploadService = UploadService();
  final ConfigService _configService = ConfigService();
  final ImagePicker _imagePicker = ImagePicker();
  UserModel? _userInfo;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingAvatar = false;
  List<ImageBedModel> _imageBeds = [];
  bool _imageBedsLoading = true;
  List<NotificationConfigModel> _notifications = [];
  bool _notificationsLoading = true;
  Map<String, String> _systemConfigs = {};
  bool _systemConfigsLoading = true;

  final _usernameController = TextEditingController();
  final _describeController = TextEditingController();
  final _avatarController = TextEditingController();
  final _webUrlController = TextEditingController();
  final _coupleSinceController = TextEditingController();
  File? _pickedAvatarFile;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadImageBeds();
    _loadNotifications();
    _loadSystemConfigs();
  }

  Future<void> _loadImageBeds() async {
    if (!mounted) return;
    setState(() => _imageBedsLoading = true);
    final res = await _configService.getImageBeds();
    if (!mounted) return;
    setState(() {
      _imageBeds = res.data ?? [];
      _imageBedsLoading = false;
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _notificationsLoading = true);
    final res = await _configService.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = res.data ?? [];
      _notificationsLoading = false;
    });
  }

  Future<void> _loadSystemConfigs() async {
    if (!mounted) return;
    setState(() => _systemConfigsLoading = true);
    final res = await _configService.getSystemConfigs();
    if (!mounted) return;
    setState(() {
      _systemConfigs = res.data ?? {};
      _webUrlController.text = _systemConfigs['WEB_URL'] ?? '';
      _coupleSinceController.text = _systemConfigs['COUPLE_SINCE'] ?? '';
      _systemConfigsLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _describeController.dispose();
    _avatarController.dispose();
    _webUrlController.dispose();
    _coupleSinceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.getUserInfo();
      if (!mounted) return;
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userInfo = response.data;
          _usernameController.text = response.data!.username;
          _describeController.text = response.data!.describeBySelf ?? '';
          _avatarController.text = response.data!.avatar ?? '';
          _pickedAvatarFile = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('加载用户信息失败', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;

      setState(() {
        _pickedAvatarFile = File(image.path);
        _isUploadingAvatar = true;
      });

      final uploadRes = await _uploadService.uploadImage(File(image.path));
      if (!mounted) return;
      if (uploadRes.isSuccess && uploadRes.data != null) {
        setState(() {
          _avatarController.text = uploadRes.data!;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传成功，请点击保存')),
        );
      } else {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uploadRes.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('选择或上传头像失败', e);
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择或上传头像失败')),
        );
      }
    }
  }

  Future<void> _saveUserInfo() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.updateUserInfo(
        username: _usernameController.text.isEmpty ? null : _usernameController.text,
        describeBySelf: _describeController.text.isEmpty ? null : _describeController.text,
        avatar: _avatarController.text.isEmpty ? null : _avatarController.text,
      );

      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
          _pickedAvatarFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        _loadUserInfo();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('保存用户信息失败', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_isLoading && _userInfo == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveUserInfo,
              child: const Text('保存'),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('编辑'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionTitle(context, '吾之信息'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing) ...[
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              backgroundImage: _avatarImageProvider,
                              child: _pickedAvatarFile == null &&
                                      _avatarController.text.isEmpty
                                  ? (_isUploadingAvatar
                                      ? Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: CircularProgressIndicator(color: colorScheme.primary),
                                        )
                                      : Icon(Icons.add_a_photo_rounded, size: 40, color: colorScheme.onSurfaceVariant))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isUploadingAvatar ? '上传中…' : '仅支持从相册上传',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: '用户名'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _describeController,
                      decoration: const InputDecoration(labelText: '一言'),
                      maxLines: 3,
                    ),
                  ] else ...[
                    _buildInfoRow(context, '用户名', _userInfo?.username ?? '未设置'),
                    _buildInfoRow(context, '邮箱', _userInfo?.userEmail ?? ''),
                    _buildInfoRow(context, '积分', '${_userInfo?.score ?? 0}'),
                    if (_userInfo?.describeBySelf != null && _userInfo!.describeBySelf!.isNotEmpty)
                      _buildInfoRow(context, '一言', _userInfo!.describeBySelf!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, '图床设置'),
          _buildImageBedSection(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, '通知配置'),
          _buildNotificationSection(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, '系统配置'),
          _buildSystemConfigSection(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, '其他'),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
              title: const Text('关于'),
              subtitle: const Text('锦书'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('关于'),
                    content: const Text('锦书\n版本: 1.0.0'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? get _avatarImageProvider {
    if (_pickedAvatarFile != null) return FileImage(_pickedAvatarFile!);
    if (_avatarController.text.isNotEmpty) {
      return NetworkImage(_avatarController.text);
    }
    return null;
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBedSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_imageBedsLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '与良人共用。上传时由后端决定使用此处配置或服务端兜底。',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (_imageBeds.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '暂无图床，请添加并设为默认。',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ..._imageBeds.map((bed) => ListTile(
                dense: true,
                leading: Icon(Icons.cloud_rounded, color: colorScheme.primary, size: 22),
                title: Text(bed.bedName, style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  '${bed.bedType} · ${bed.apiUrl}${bed.isDefault ? " · 默认" : ""}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddImageBedDialog(context),
              icon: Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
              label: Text('添加图床', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddImageBedDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameCtrl = TextEditingController();
    final apiUrlCtrl = TextEditingController(text: 'https://api.imgbb.com/1/upload');
    final apiKeyCtrl = TextEditingController();
    String bedType = 'imgbb';
    bool isDefault = _imageBeds.isEmpty;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('添加图床'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '图床名称',
                        hintText: '如：IMGBB',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: bedType,
                      decoration: const InputDecoration(
                        labelText: '图床类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'imgbb', child: Text('imgBB')),
                        DropdownMenuItem(value: 'smms', child: Text('SM.MS')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            bedType = v;
                            apiUrlCtrl.text = v == 'imgbb'
                                ? 'https://api.imgbb.com/1/upload'
                                : 'https://sm.ms/api/v2/upload';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'API 地址',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: '必填',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isDefault,
                          onChanged: (v) => setDialogState(() => isDefault = v ?? false),
                          activeColor: colorScheme.primary,
                        ),
                        GestureDetector(
                          onTap: () => setDialogState(() => isDefault = !isDefault),
                          child: Text('设为默认（与良人共用）', style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    final bedName = nameCtrl.text.trim();
                    final apiUrl = apiUrlCtrl.text.trim();
                    final apiKey = apiKeyCtrl.text.trim();
                    if (bedName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写图床名称')),
                      );
                      return;
                    }
                    if (apiUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写 API 地址')),
                      );
                      return;
                    }
                    if (apiKey.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写 API Key')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final res = await _configService.updateImageBed(
                      bedName: bedName,
                      bedType: bedType,
                      apiUrl: apiUrl,
                      apiKey: apiKey,
                      isDefault: isDefault,
                    );
                    if (!mounted) return;
                    if (res.isSuccess) {
                      SnackBarUtils.showSuccess(context, '图床已保存，与良人共用');
                      _loadImageBeds();
                    } else {
                      SnackBarUtils.showError(context, res.msg);
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_notificationsLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '与良人共用。任务/礼物等通知将按此处配置推送。',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (_notifications.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '暂无通知配置，可添加钉钉、飞书、企业微信等。',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ..._notifications.map((n) => ListTile(
                dense: true,
                leading: Icon(Icons.notifications_rounded, color: colorScheme.primary, size: 22),
                title: Text('${n.notifyName} (${n.notifyType})', style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  n.webhookUrl ?? n.description ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showNotificationDialog(context, existing: n),
              )),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showNotificationDialog(context),
              icon: Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
              label: Text('添加通知', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemConfigSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_systemConfigsLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '与良人共用。如网站地址、在一起的日子（首页展示相守时长）等。',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _webUrlController,
              decoration: const InputDecoration(
                labelText: '网站地址 (WEB_URL)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _coupleSinceController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '在一起的日子',
                      hintText: '未设置',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    final initial = _coupleSinceController.text.trim();
                    DateTime initialDate = DateTime.now();
                    if (initial.length == 10) {
                      final parsed = DateTime.tryParse('$initial 00:00:00');
                      if (parsed != null) initialDate = parsed;
                    }
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && mounted) {
                      final value = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      _coupleSinceController.text = value;
                    }
                  },
                  child: const Text('选择日期'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final value = _webUrlController.text.trim();
                final res = await _configService.updateSystemConfig(
                  configKey: 'WEB_URL',
                  configValue: value,
                  configType: 'other',
                  description: '网站地址',
                );
                if (!mounted) return;
                if (res.isSuccess) {
                  SnackBarUtils.showSuccess(context, '已保存');
                  _loadSystemConfigs();
                } else {
                  SnackBarUtils.showError(context, res.msg);
                }
              },
              child: const Text('保存网站地址'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final value = _coupleSinceController.text.trim();
                final res = await _configService.updateSystemConfig(
                  configKey: 'COUPLE_SINCE',
                  configValue: value,
                  configType: 'other',
                  description: '在一起的日子',
                );
                if (!mounted) return;
                if (res.isSuccess) {
                  SnackBarUtils.showSuccess(context, '已保存');
                  _loadSystemConfigs();
                } else {
                  SnackBarUtils.showError(context, res.msg);
                }
              },
              child: const Text('保存在一起的日子'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationDialog(BuildContext context, {NotificationConfigModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.notifyName ?? '');
    final typeCtrl = TextEditingController(text: existing?.notifyType ?? '');
    final webhookCtrl = TextEditingController(text: existing?.webhookUrl ?? '');
    final apiKeyCtrl = TextEditingController(text: existing?.apiKey ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? '添加通知' : '编辑通知'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(
                    labelText: '通知类型',
                    hintText: '钉钉 / 飞书 / 企业微信 / 自定义',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: '如：我的钉钉',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: webhookCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Webhook 地址',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: apiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'API Key（可选）',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final notifyType = typeCtrl.text.trim();
                final notifyName = nameCtrl.text.trim();
                if (notifyType.isEmpty || notifyName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写通知类型和名称')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final res = await _configService.updateNotification(
                  notifyType: notifyType,
                  notifyName: notifyName,
                  webhookUrl: webhookCtrl.text.trim(),
                  apiKey: apiKeyCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                if (!mounted) return;
                if (res.isSuccess) {
                  SnackBarUtils.showSuccess(context, '通知配置已保存，与良人共用');
                  _loadNotifications();
                } else {
                  SnackBarUtils.showError(context, res.msg);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
