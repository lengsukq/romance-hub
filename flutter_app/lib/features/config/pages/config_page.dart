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
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.getUserInfo();
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('加载用户信息失败', e);
      setState(() {
        _isLoading = false;
      });
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
      if (uploadRes.isSuccess && uploadRes.data != null && mounted) {
        setState(() {
          _avatarController.text = uploadRes.data!;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传成功，请点击保存')),
        );
      } else {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(uploadRes.msg)),
          );
        }
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
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.updateUserInfo(
        username: _usernameController.text.isEmpty ? null : _usernameController.text,
        describeBySelf: _describeController.text.isEmpty ? null : _describeController.text,
        avatar: _avatarController.text.isEmpty ? null : _avatarController.text,
      );

      if (response.isSuccess) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
          _pickedAvatarFile = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
          _loadUserInfo();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('保存用户信息失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userInfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('用户信息'),
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
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _avatarImageProvider,
                              child: _pickedAvatarFile == null &&
                                      _avatarController.text.isEmpty
                                  ? (_isUploadingAvatar
                                      ? const Padding(
                                          padding: EdgeInsets.all(24),
                                          child: CircularProgressIndicator(),
                                        )
                                      : const Icon(Icons.add_a_photo, size: 40))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isUploadingAvatar ? '上传中…' : '点击头像从相册选择',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _describeController,
                      decoration: const InputDecoration(
                        labelText: '个人描述',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _avatarController,
                      decoration: const InputDecoration(
                        labelText: '头像URL（可选，或从相册上传）',
                        border: OutlineInputBorder(),
                        hintText: '上传后自动填充，也可手动输入',
                      ),
                    ),
                  ] else ...[
                    _buildInfoRow('用户名', _userInfo?.username ?? '未设置'),
                    _buildInfoRow('邮箱', _userInfo?.userEmail ?? ''),
                    _buildInfoRow('积分', '${_userInfo?.score ?? 0}'),
                    if (_userInfo?.describeBySelf != null && _userInfo!.describeBySelf!.isNotEmpty)
                      _buildInfoRow('个人描述', _userInfo!.describeBySelf!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('其他设置'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              subtitle: const Text('RomanceHub Flutter 客户端'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('关于'),
                    content: const Text('RomanceHub Flutter 客户端\n版本: 1.0.0'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
