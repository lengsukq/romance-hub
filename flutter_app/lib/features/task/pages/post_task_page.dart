import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 发布任务页面
class PostTaskPage extends StatefulWidget {
  const PostTaskPage({super.key});

  @override
  State<PostTaskPage> createState() => _PostTaskPageState();
}

class _PostTaskPageState extends State<PostTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _taskDescController = TextEditingController();
  final _taskScoreController = TextEditingController();
  final TaskService _taskService = TaskService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  String? _uploadPhaseHint;

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescController.dispose();
    _taskScoreController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xFile) => File(xFile.path)).toList();
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

  List<String> _collectMissingFields() {
    final missing = <String>[];
    if (_taskNameController.text.trim().isEmpty) missing.add('心诺名称');
    if (_taskDescController.text.trim().isEmpty) missing.add('诺言');
    final scoreStr = _taskScoreController.text.trim();
    final score = int.tryParse(scoreStr);
    if (scoreStr.isEmpty) {
      missing.add('积分');
    } else if (score == null || score < 0) {
      missing.add('积分（须为不小于0的数字）');
    }
    if (_selectedImages.isEmpty) missing.add('任务图片');
    return missing;
  }

  Future<void> _submitTask() async {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _uploadPhaseHint = '上传中…';
    });

    try {
      List<String> imageUrls = [];
      final uploadResponse = await _uploadService.uploadImages(_selectedImages);
      if (!uploadResponse.isSuccess || uploadResponse.data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(uploadResponse.msg)),
          );
        }
        setState(() {
          _isSubmitting = false;
          _uploadPhaseHint = null;
        });
        return;
      }
      imageUrls = uploadResponse.data!;

      if (mounted) {
        setState(() => _uploadPhaseHint = '发布中…');
      }

      // 发布任务
      final response = await _taskService.createTask(
        taskName: _taskNameController.text,
        taskDesc: _taskDescController.text,
        taskImage: imageUrls,
        taskScore: int.parse(_taskScoreController.text),
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布成功')),
          );
          context.go(AppRoutes.tasks);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('发布任务失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布失败，请重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadPhaseHint = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('立一诺'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            TextFormField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: '心诺名称'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入心诺名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taskDescController,
              decoration: const InputDecoration(labelText: '诺言'),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请写下诺言';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taskScoreController,
              decoration: const InputDecoration(labelText: '积分'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入积分';
                }
                final n = int.tryParse(value);
                if (n == null) return '请输入有效的数字';
                if (n < 0) return '积分不能小于0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image_rounded),
              label: const Text('选择图片'),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
                                foregroundColor: colorScheme.surface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_uploadPhaseHint != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _uploadPhaseHint!,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTask,
              child: _isSubmitting
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                  : const Text('发布'),
            ),
          ],
        ),
      ),
    );
  }
}
