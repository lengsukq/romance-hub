import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/services/upload_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 添加礼物页面
class AddGiftPage extends StatefulWidget {
  const AddGiftPage({super.key});

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final _giftNameController = TextEditingController();
  final _giftDescController = TextEditingController();
  final _scoreController = TextEditingController();
  final GiftService _giftService = GiftService();
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _giftNameController.dispose();
    _giftDescController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
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

  Future<void> _submitGift() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final uploadResponse = await _uploadService.uploadImage(_selectedImage!);
        if (uploadResponse.isSuccess && uploadResponse.data != null) {
          imageUrl = uploadResponse.data;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(uploadResponse.msg)),
            );
          }
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      final response = await _giftService.createGift(
        giftName: _giftNameController.text,
        giftDesc: _giftDescController.text.isEmpty ? null : _giftDescController.text,
        giftImage: imageUrl,
        score: int.parse(_scoreController.text),
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('添加成功')),
          );
          context.go('/gifts');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加礼物'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _giftNameController,
              decoration: const InputDecoration(
                labelText: '礼物名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入礼物名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _giftDescController,
              decoration: const InputDecoration(
                labelText: '礼物描述（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scoreController,
              decoration: const InputDecoration(
                labelText: '所需积分',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入所需积分';
                }
                if (int.tryParse(value) == null) {
                  return '请输入有效的数字';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('选择图片'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitGift,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('添加礼物'),
            ),
          ],
        ),
      ),
    );
  }
}
