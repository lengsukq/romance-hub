import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';

/// 后端地址配置对话框
class ConfigDialog extends StatefulWidget {
  final String initialUrl;
  final Function(String) onSave;

  const ConfigDialog({
    super.key,
    required this.initialUrl,
    required this.onSave,
  });

  @override
  State<ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<ConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl;
    _urlController.addListener(_validateUrl);
  }

  void _validateUrl() {
    final url = _urlController.text.trim();
    setState(() {
      _isValid = url.isEmpty || AppConfig.isValidUrl(url);
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = AppConfig.normalizeUrl(_urlController.text.trim());
    widget.onSave(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings, size: 24),
          SizedBox(width: 8),
          Text('配置云阁'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请输入云阁地址',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: '云阁地址',
                hintText: 'https://r-d.lengsu.top/',
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
                errorText: _isValid ? null : '请输入有效的 URL 地址',
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入云阁地址';
                }
                if (!AppConfig.isValidUrl(value.trim())) {
                  return '请输入有效的 URL（http:// 或 https://）';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _urlController.text = AppConfig.defaultBaseUrl;
                _validateUrl();
              },
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('复为默认云阁'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '提示',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 确保云阁（后端）正在运行\n• 地址格式: http://ip:port 或 https://domain.com\n• 示例: https://r-d.lengsu.top/',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
