import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
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
        _errorMessage = '君与良人邮箱不可相同';
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
          context.go(AppRoutes.login);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('二人同契'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '为君与良人同立契，共守一钥，便于两心相记',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 主账号信息卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle(context, '君之契', colorScheme.primary),
                        const SizedBox(height: 12),
                        _avatarPicker(context, file: _avatarFile, onTap: () => _pickAvatar(false)),
                        const SizedBox(height: 6),
                        Text(
                          '选填，不选则用默认头像',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: '昵称',
                            hintText: '请输入昵称',
                            prefixIcon: Icon(Icons.person_rounded, color: colorScheme.onSurfaceVariant),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '请输入昵称';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _userEmailController,
                          decoration: InputDecoration(
                            labelText: '邮箱',
                            hintText: '请输入邮箱',
                            prefixIcon: Icon(Icons.email_rounded, color: colorScheme.onSurfaceVariant),
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
                          decoration: InputDecoration(
                            labelText: '一言',
                            hintText: '请输入一言',
                            prefixIcon: Icon(Icons.chat_bubble_outline_rounded, color: colorScheme.onSurfaceVariant),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '请输入一言';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 良人契卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle(context, '良人契', colorScheme.primary),
                        const SizedBox(height: 12),
                        _avatarPicker(context, file: _loverAvatarFile, onTap: () => _pickAvatar(true)),
                        const SizedBox(height: 6),
                        Text(
                          '选填，不选则用默认头像',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _loverEmailController,
                          decoration: InputDecoration(
                            labelText: '良人邮箱',
                            hintText: '请输入良人邮箱',
                            prefixIcon: Icon(Icons.email_rounded, color: colorScheme.onSurfaceVariant),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '请输入良人邮箱';
                            if (!ValidationUtils.isValidEmail(v.trim())) return '请输入正确的邮箱';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _loverUsernameController,
                          decoration: InputDecoration(
                            labelText: '良人昵称',
                            hintText: '请输入良人昵称',
                            prefixIcon: Icon(Icons.person_rounded, color: colorScheme.onSurfaceVariant),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '请输入良人昵称';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _loverDescribeBySelfController,
                          decoration: InputDecoration(
                            labelText: '良人一言',
                            hintText: '请输入良人一言',
                            prefixIcon: Icon(Icons.chat_bubble_outline_rounded, color: colorScheme.onSurfaceVariant),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '请输入良人一言';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 共守之钥卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle(context, '共守之钥', colorScheme.primary),
                        const SizedBox(height: 6),
                        Text(
                          '两账号共用同一登入密码',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: '密码',
                            hintText: '请输入密码',
                            prefixIcon: Icon(Icons.lock_rounded, color: colorScheme.onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                            hintText: '请再次输入一致密码',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword2 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => setState(() => _obscurePassword2 = !_obscurePassword2),
                            ),
                          ),
                          obscureText: _obscurePassword2,
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请再次输入密码';
                            if (v != _passwordController.text) return '两次密码不一致';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          ),
                        )
                      : const Text('同立契'),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      '已有账号？去登入',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, Color color) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _avatarPicker(BuildContext context, {required File? file, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          backgroundImage: file != null ? FileImage(file) : null,
          child: file == null
              ? Icon(Icons.add_a_photo_rounded, size: 36, color: colorScheme.onSurfaceVariant)
              : null,
        ),
      ),
    );
  }
}
