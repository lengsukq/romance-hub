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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_rounded, size: 24, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Text('配置云阁'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '请输入云阁地址',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: '云阁地址',
                hintText: 'https://r-d.lengsu.top/',
                prefixIcon: Icon(Icons.link_rounded, color: colorScheme.onSurfaceVariant),
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
              icon: Icon(Icons.restore_rounded, size: 18, color: colorScheme.primary),
              label: const Text('复为默认云阁'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '提示',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 确保云阁正在运行\n• 地址格式：http://ip:port 或 https://domain.com\n• 示例：https://r-d.lengsu.top/',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
          child: const Text('保存'),
        ),
      ],
    );
  }
}
