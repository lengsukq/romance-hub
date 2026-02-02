import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';

/// 吾之信息编辑弹框：头像上传、用户名、一言，保存后 pop(true)
class EditUserInfoDialog extends StatefulWidget {
  final UserModel initialUser;

  const EditUserInfoDialog({
    super.key,
    required this.initialUser,
  });

  /// 显示弹框，保存成功时返回 true
  static Future<bool?> show(BuildContext context, UserModel initialUser) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditUserInfoDialog(initialUser: initialUser),
    );
  }

  @override
  State<EditUserInfoDialog> createState() => _EditUserInfoDialogState();
}

class _EditUserInfoDialogState extends State<EditUserInfoDialog> {
  final UserService _userService = UserService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _usernameController;
  late final TextEditingController _describeController;
  late final TextEditingController _avatarController;

  File? _pickedAvatarFile;
  bool _isUploadingAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;
    _usernameController = TextEditingController(text: u.username);
    _describeController = TextEditingController(text: u.describeBySelf ?? '');
    _avatarController = TextEditingController(text: u.avatar ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _describeController.dispose();
    _avatarController.dispose();
    super.dispose();
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
      AppLogger.i('[吾之信息-头像上传] isSuccess=${uploadRes.isSuccess}, code=${uploadRes.code}, msg=${uploadRes.msg}, url=${uploadRes.data ?? "(空)"}');
      if (uploadRes.isSuccess && uploadRes.data != null && uploadRes.data!.isNotEmpty) {
        setState(() {
          _avatarController.text = uploadRes.data!;
          _isUploadingAvatar = false;
        });
        SnackBarUtils.showSuccess(context, '头像上传成功，请点击保存');
      } else {
        setState(() => _isUploadingAvatar = false);
        SnackBarUtils.showError(context, uploadRes.msg.isNotEmpty ? uploadRes.msg : '头像上传失败，未拿到图片地址');
      }
    } catch (e) {
      AppLogger.e('选择或上传头像失败', e);
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        SnackBarUtils.showError(context, '选择或上传头像失败');
      }
    }
  }

  Future<void> _save() async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    final username = _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim();
    final describeBySelf = _describeController.text.trim().isEmpty ? null : _describeController.text.trim();
    final avatar = _avatarController.text.trim().isEmpty ? null : _avatarController.text.trim();

    AppLogger.i('[吾之信息-上传] username=$username, describeBySelf=$describeBySelf, avatar=${avatar != null ? avatar : "(空)"}');

    try {
      final response = await _userService.updateUserInfo(
        username: username,
        describeBySelf: describeBySelf,
        avatar: avatar,
      );

      AppLogger.i('[吾之信息-上传响应] isSuccess=${response.isSuccess}, code=${response.code}, msg=${response.msg}');

      if (!mounted) return;
      if (response.isSuccess) {
        SnackBarUtils.showSuccess(context, '保存成功');
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isSaving = false);
        SnackBarUtils.showError(context, response.msg);
      }
    } catch (e) {
      AppLogger.e('保存用户信息失败', e);
      if (mounted) {
        setState(() => _isSaving = false);
        SnackBarUtils.showError(context, '保存失败');
      }
    }
  }

  ImageProvider? get _avatarImageProvider {
    if (_pickedAvatarFile != null) return FileImage(_pickedAvatarFile!);
    if (_avatarController.text.isNotEmpty) {
      return NetworkImage(_avatarController.text);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      title: const Text('编辑吾之信息'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        backgroundImage: _avatarImageProvider,
                        child: _pickedAvatarFile == null && _avatarController.text.isEmpty
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _describeController,
                decoration: InputDecoration(
                  labelText: '一言',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
