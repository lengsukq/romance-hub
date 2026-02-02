import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 配置页面
class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final UserService _userService = UserService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();
  UserModel? _userInfo;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingAvatar = false;

  final _usernameController = TextEditingController();
  final _describeController = TextEditingController();
  final _avatarController = TextEditingController();
  File? _pickedAvatarFile;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _describeController.dispose();
    _avatarController.dispose();
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
}
