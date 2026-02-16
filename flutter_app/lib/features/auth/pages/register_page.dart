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
  String? _avatarUploadUrl;
  String? _loverAvatarUploadUrl;
  bool _isUploadingAvatar = false;
  bool _isUploadingLoverAvatar = false;
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

  List<String> _collectMissingFields() {
    final missing = <String>[];
    if (_usernameController.text.trim().isEmpty) missing.add('昵称');
    final userEmail = _userEmailController.text.trim();
    if (userEmail.isEmpty) {
      missing.add('邮箱');
    } else if (!ValidationUtils.isValidEmail(userEmail)) {
      missing.add('邮箱（格式不正确）');
    }
    if (_describeBySelfController.text.trim().isEmpty) missing.add('一言');
    final loverEmail = _loverEmailController.text.trim();
    if (loverEmail.isEmpty) {
      missing.add('良人邮箱');
    } else if (!ValidationUtils.isValidEmail(loverEmail)) {
      missing.add('良人邮箱（格式不正确）');
    }
    if (_loverUsernameController.text.trim().isEmpty) missing.add('良人昵称');
    if (_loverDescribeBySelfController.text.trim().isEmpty) missing.add('良人一言');
    final pwd = _passwordController.text;
    if (pwd.isEmpty) {
      missing.add('密码');
    } else if (!ValidationUtils.isValidPassword(pwd)) {
      missing.add('密码（至少6位）');
    }
    final pwd2 = _password2Controller.text;
    if (pwd2.isEmpty) {
      missing.add('确认密码');
    } else if (pwd2 != pwd) {
      missing.add('确认密码（与密码不一致）');
    }
    return missing;
  }

  Future<void> _pickAvatar(bool isLover) async {
    if (isLover && _isUploadingLoverAvatar) return;
    if (!isLover && _isUploadingAvatar) return;
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final file = File(image.path);
      if (isLover) {
        setState(() {
          _loverAvatarFile = file;
          _loverAvatarUploadUrl = null;
          _isUploadingLoverAvatar = true;
        });
      } else {
        setState(() {
          _avatarFile = file;
          _avatarUploadUrl = null;
          _isUploadingAvatar = true;
        });
      }
      final uploadRes = await _uploadService.uploadImage(file);
      if (!mounted) return;
      if (uploadRes.isSuccess && uploadRes.data != null && uploadRes.data!.isNotEmpty) {
        setState(() {
          if (isLover) {
            _loverAvatarUploadUrl = uploadRes.data;
            _isUploadingLoverAvatar = false;
          } else {
            _avatarUploadUrl = uploadRes.data;
            _isUploadingAvatar = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传成功')),
        );
      } else {
        setState(() {
          if (isLover) {
            _loverAvatarFile = null;
            _loverAvatarUploadUrl = null;
            _isUploadingLoverAvatar = false;
          } else {
            _avatarFile = null;
            _avatarUploadUrl = null;
            _isUploadingAvatar = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uploadRes.msg.isNotEmpty ? uploadRes.msg : '头像上传失败')),
        );
      }
    } catch (e) {
      AppLogger.e('选择或上传头像失败', e);
      if (mounted) {
        setState(() {
          if (isLover) {
            _loverAvatarFile = null;
            _loverAvatarUploadUrl = null;
            _isUploadingLoverAvatar = false;
          } else {
            _avatarFile = null;
            _avatarUploadUrl = null;
            _isUploadingAvatar = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择或上传头像失败')),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    final missing = _collectMissingFields();
    if (missing.isNotEmpty) {
      _formKey.currentState!.validate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('请填写或修正：${missing.join('、')}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

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
      // 头像已在上传完成后得到 URL，直接使用
      final response = await _authService.register(
        userEmail: userEmail,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        describeBySelf: _describeBySelfController.text.trim(),
        lover: lover,
        loverUsername: _loverUsernameController.text.trim(),
        loverDescribeBySelf: _loverDescribeBySelfController.text.trim(),
        avatar: _avatarUploadUrl,
        loverAvatar: _loverAvatarUploadUrl,
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
                        _avatarPicker(context, file: _avatarFile, onTap: () => _pickAvatar(false), isUploading: _isUploadingAvatar),
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
                        _avatarPicker(context, file: _loverAvatarFile, onTap: () => _pickAvatar(true), isUploading: _isUploadingLoverAvatar),
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
                  onPressed: (_isLoading || _isUploadingAvatar || _isUploadingLoverAvatar) ? null : _handleRegister,
                  child: (_isLoading || _isUploadingAvatar || _isUploadingLoverAvatar)
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

  Widget _avatarPicker(BuildContext context, {required File? file, required VoidCallback onTap, required bool isUploading}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              backgroundImage: file != null ? FileImage(file) : null,
              child: file == null
                  ? Icon(Icons.add_a_photo_rounded, size: 36, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            if (isUploading)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text('上传中…', style: TextStyle(fontSize: 10, color: colorScheme.onSurface)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
