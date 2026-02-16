import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 添心意页面
class AddGiftPage extends StatefulWidget {
  const AddGiftPage({super.key});

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final _giftNameController = TextEditingController();
  final _giftDetailController = TextEditingController();
  final _scoreController = TextEditingController();
  final _remainedController = TextEditingController(text: '10');
  final GiftService _giftService = GiftService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _giftNameController.dispose();
    _giftDetailController.dispose();
    _scoreController.dispose();
    _remainedController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isUploadingImage) return;
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
        _uploadedImageUrl = null;
        _isUploadingImage = true;
      });
      final uploadResponse = await _uploadService.uploadImage(file);
      if (!mounted) return;
      if (uploadResponse.isSuccess && uploadResponse.data != null && uploadResponse.data!.isNotEmpty) {
        setState(() {
          _uploadedImageUrl = uploadResponse.data;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片上传成功')),
        );
      } else {
        setState(() {
          _selectedImage = null;
          _uploadedImageUrl = null;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uploadResponse.msg.isNotEmpty ? uploadResponse.msg : '图片上传失败')),
        );
      }
    } catch (e) {
      AppLogger.e('选择或上传图片失败', e);
      if (mounted) {
        setState(() {
          _selectedImage = null;
          _uploadedImageUrl = null;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择或上传图片失败')),
        );
      }
    }
  }

  List<String> _collectMissingFields() {
    final missing = <String>[];
    final name = _giftNameController.text.trim();
    if (name.isEmpty) {
      missing.add('赠礼名称');
    } else if (name.length > 10) {
      missing.add('赠礼名称（最多10字）');
    }
    final detail = _giftDetailController.text.trim();
    if (detail.isEmpty) {
      missing.add('心意说明');
    } else if (detail.length > 20) {
      missing.add('心意说明（最多20字）');
    }
    final scoreStr = _scoreController.text.trim();
    final score = int.tryParse(scoreStr);
    if (scoreStr.isEmpty) {
      missing.add('所需积分');
    } else if (score == null || score < 0) {
      missing.add('所需积分（须≥0）');
    }
    final remainedStr = _remainedController.text.trim();
    final remained = int.tryParse(remainedStr);
    if (remainedStr.isEmpty) {
      missing.add('库存数量');
    } else if (remained == null || remained <= 0) {
      missing.add('库存数量（须大于0）');
    }
    return missing;
  }

  Future<void> _submitGift() async {
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
    if (_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请等待图片上传完成')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final needScore = int.parse(_scoreController.text);
      final remained = int.tryParse(_remainedController.text) ?? 0;
      final response = await _giftService.createGift(
        giftName: _giftNameController.text.trim(),
        giftDetail: _giftDetailController.text.trim(),
        needScore: needScore,
        remained: remained,
        giftImg: _uploadedImageUrl,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('添加成功')),
          );
          context.go(AppRoutes.gifts);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('添加礼物失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加失败，请重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
        title: const Text('添心意'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            TextFormField(
              controller: _giftNameController,
              decoration: const InputDecoration(labelText: '赠礼名称（最多10字）'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return '请输入赠礼名称';
                if (value.trim().length > 10) return '名称不能超过10个字';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _giftDetailController,
              decoration: const InputDecoration(labelText: '心意说明（最多20字）'),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return '请填写心意说明';
                if (value.trim().length > 20) return '说明不能超过20个字';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scoreController,
              decoration: const InputDecoration(labelText: '所需积分'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '请输入所需积分';
                final n = int.tryParse(value);
                if (n == null) return '请输入有效的数字';
                if (n < 0) return '积分不能小于0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remainedController,
              decoration: const InputDecoration(labelText: '库存数量'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '请输入库存数量';
                final n = int.tryParse(value);
                if (n == null) return '请输入有效的数字';
                if (n <= 0) return '库存必须大于0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploadingImage ? null : _pickImage,
              icon: _isUploadingImage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : const Icon(Icons.image_rounded),
              label: Text(_isUploadingImage ? '上传中…' : '选择图片（选填）'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_isUploadingImage)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colorScheme.primary),
                          const SizedBox(height: 8),
                          Text('上传中…', style: TextStyle(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isSubmitting || _isUploadingImage) ? null : _submitGift,
              child: _isSubmitting
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                  : const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}
