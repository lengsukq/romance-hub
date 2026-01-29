import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romance_hub_flutter/core/utils/validation_utils.dart';
import 'package:romance_hub_flutter/features/auth/services/auth_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 双账号注册页面（与 Web 端一致）
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _describeBySelfController = TextEditingController();
  final _loverEmailController = TextEditingController();
  final _loverUsernameController = TextEditingController();
  final _loverDescribeBySelfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  final AuthService _authService = AuthService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _avatarFile;
  File? _loverAvatarFile;
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _userEmailController.dispose();
    _describeBySelfController.dispose();
    _loverEmailController.dispose();
    _loverUsernameController.dispose();
    _loverDescribeBySelfController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(bool isLover) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isLover) {
            _loverAvatarFile = File(image.path);
          } else {
            _avatarFile = File(image.path);
          }
        });
      }
    } catch (e) {
      AppLogger.e('选择图片失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择图片失败')),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userEmail = _userEmailController.text.trim();
    final lover = _loverEmailController.text.trim();
    if (userEmail == lover) {
      setState(() {
        _errorMessage = '用户邮箱与关联者邮箱不可相同';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 头像可选：后端上传需登录，注册时未登录则传 null，后端使用默认头像
      String? avatarUrl;
      if (_avatarFile != null) {
        final uploadRes = await _uploadService.uploadImage(_avatarFile!);
        if (uploadRes.isSuccess && uploadRes.data != null) {
          avatarUrl = uploadRes.data;
        }
        // 上传失败（如未登录）时继续注册，后端会使用随机默认头像
      }

      String? loverAvatarUrl;
      if (_loverAvatarFile != null) {
        final uploadRes = await _uploadService.uploadImage(_loverAvatarFile!);
        if (uploadRes.isSuccess && uploadRes.data != null) {
          loverAvatarUrl = uploadRes.data;
        }
      }

      final response = await _authService.register(
        userEmail: userEmail,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        describeBySelf: _describeBySelfController.text.trim(),
        lover: lover,
        loverUsername: _loverUsernameController.text.trim(),
        loverDescribeBySelf: _loverDescribeBySelfController.text.trim(),
        avatar: avatarUrl,
        loverAvatar: loverAvatarUrl,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
          context.go('/login');
        } else {
          setState(() {
            _errorMessage = response.msg;
          });
        }
      }
    } catch (e) {
      AppLogger.e('注册失败', e);
      if (mounted) {
        setState(() {
          _errorMessage = '注册失败: ${e.toString()}';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('双账号注册'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '将同时为您和关联者创建账号，两个账号使用相同密码，便于情侣间互动使用',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // 主账号信息
                _sectionTitle('主账号信息', Colors.pink),
                const SizedBox(height: 12),
                _avatarPicker(
                  file: _avatarFile,
                  onTap: () => _pickAvatar(false),
                ),
                const SizedBox(height: 4),
                const Text(
                  '选填，不选则使用默认头像',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '昵称',
                    hintText: '请输入昵称',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入昵称';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _userEmailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入邮箱',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入邮箱';
                    if (!ValidationUtils.isValidEmail(v.trim())) return '请输入正确的邮箱';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _describeBySelfController,
                  decoration: const InputDecoration(
                    labelText: '一言',
                    hintText: '请输入一言',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入一言';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 关联者账号信息
                _sectionTitle('关联者账号信息', Colors.deepPurple),
                const SizedBox(height: 12),
                _avatarPicker(
                  file: _loverAvatarFile,
                  onTap: () => _pickAvatar(true),
                ),
                const SizedBox(height: 4),
                const Text(
                  '选填，不选则使用默认头像',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _loverEmailController,
                  decoration: const InputDecoration(
                    labelText: '关联者邮箱',
                    hintText: '请输入关联者邮箱',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入关联者邮箱';
                    if (!ValidationUtils.isValidEmail(v.trim())) return '请输入正确的邮箱';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _loverUsernameController,
                  decoration: const InputDecoration(
                    labelText: '关联者昵称',
                    hintText: '请输入关联者昵称',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入关联者昵称';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _loverDescribeBySelfController,
                  decoration: const InputDecoration(
                    labelText: '关联者一言',
                    hintText: '请输入关联者一言',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入关联者一言';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 共享密码
                _sectionTitle('共享密码', Colors.orange),
                const SizedBox(height: 8),
                const Text(
                  '两个账号将使用相同的登录密码',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请输入密码';
                    if (!ValidationUtils.isValidPassword(v)) return '密码至少 6 位';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password2Controller,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '请再次输入一致的密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword2 ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword2,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请再次输入密码';
                    if (v != _passwordController.text) return '两次密码不一致';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '注册双账号',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('已有账号？去登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _avatarPicker({required File? file, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: file != null ? FileImage(file) : null,
          child: file == null
              ? const Icon(Icons.add_a_photo, size: 36, color: Colors.grey)
              : null,
        ),
      ),
    );
  }
}
